#!/usr/bin/env ruby

module VideoSprites 

  require 'slop'
  require 'fileutils'

  # remove all JPEG and VTT files, but leave the directories in place.
  def remove_files(output_directory, verbose)
    deadfiles = Dir.glob(File.join(output_directory, '**', '*.jpg'))
    puts "list of dead files will be #{deadfiles}" if verbose
    deadfiles.each do | deadfile |
      puts "removing file #{deadfile}" if verbose
      File.unlink(deadfile)
    end
    deadfiles = Dir.glob(File.join(output_directory, '**', '*.vtt'))
    puts "list of dead files will be #{deadfiles}" if verbose
    deadfiles.each do | deadfile |
      puts "removing file #{deadfile}" if verbose
      File.unlink(deadfile)
    end
  end

  # Format a WebVTT timestamp according to the specification using hours, minutes, seconds, and fractional seconds.
  def timestamp(total_seconds)
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)

    format("%02d:%02d:%02d.000", hours, minutes, seconds)
  end

  opts = Slop.new(strict: true, help: true) do
    banner 'Usage: video-sprites [options]'
    on 'i', 'input=', 'Input file or directory', required: true
    on 'o', 'output=', 'Output file or directory', argument: :optional
    on 's', 'seconds=', 'Seconds interval between snapshots', argument: :optional, as: Integer, default: 5
    on 'w', 'width=', 'Width of each thumbnail', argument: :optional, as: Integer, default: 200
    on 'c', 'columns=', 'Number of columns in the image sprite', argument: :optional, as: Integer, default: 5
    on 'r', 'rows=', 'Maximum number of rows to put into each sprite', argument: :optional, as: Integer
    # on 'k', 'keep', 'Keep all the individual images and other intermediate artifacts.', argument: :optional
    on 't', 'start', 'Start time to begin from in seconds or hh:mm:ss[.xxx]', argument: :optional
    on 'd', 'duration', 'Duration of the clip to extract stills from in seconds or hh:mm:ss[.xxx] and can only be set if --start is also set.', argument: :optional
    on 'u', 'url=', "Base url to use for webvtt", default: 'http://example.com'
    on 'g', 'gif', "Create a GIF animation as well?"
    on 'v', 'verbose', 'Enable verbose mode'
    on 'z', 'clean', 'Clean up the output directory'
  end

  begin
    opts.parse
  rescue Slop::Error => e
    puts e.message
    puts opts
    exit
  end

  verbose = opts[:verbose]
  input   = File.expand_path(opts[:input])
  output  = opts[:output]
  seconds  = opts[:seconds]
  columns = opts[:columns]
  width   = opts[:width]
  clean   = opts[:clean]

  unless File.exist?(input)
    puts 'File or directory does not exist!'
    exit
  end

  if verbose
    puts "Input file: #{input}"
  end

  if File.directory?(input)
    files = Dir.glob(File.join(input, '*.{avi,drc,flv,mkv,mov,mpg,mp2,mpeg,mpe,mpv,mp4,m4a,m4p,m4v,mxf,ogg,ogv,webm}'))
  else
    files = [input]
  end

  # Since we allow for input to be either a file or a directory we need to set file paths
  # for use later appropriately.
  if output
    output_directory = File.expand_path(output)
    puts "output dir is #{output_directory}" if verbose
    if File.directory?(output_directory)
      remove_files(output_directory, verbose) if clean
    elsif File.exist?(output_directory)
      raise "Output directory must be a directory, was: #{output}"
    else
      FileUtils.mkdir_p(output_directory)
    end
  else
    output_directory = input
    if File.directory?(output_directory)
      puts "output dir is #{output_directory}" if verbose
      remove_files(output_directory, verbose) if clean
    else
      output_directory = File.dirname(input)
      puts "output dir is #{output_directory}" if verbose
      remove_files(output_directory, verbose) if clean
    end
  end

  # This is the main loop where we go through video files.
  files.each do | file |

    # for repeated runs, skip any directories in this directory
    if File.directory?(file)
      next
    end

    puts "Processing file: #{file}" if verbose
    extension = File.extname(file)
    basename =  File.basename(file, extension)
    puts "Basename is: #{basename}" if verbose

    output_path = File.join(output_directory, basename)

    if File.directory?(input)
      FileUtils.mkdir_p(output_path)
      output_file_path = File.join(output_directory, basename, basename)
    else
      output_file_path = File.join(output_directory, basename)
    end

    puts "#{output_file_path} output file path"
    # FIXME: check if the files exist already and maybe don't process anything

    # Use ffprobe to discover the frames per second.
    ffprobe_cmd = 'ffprobe -i "' + "#{file}" +  '" 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p"'
    puts ffprobe_cmd if verbose
    # Frames per second can be fractional so round up
    frames_per_sec=`#{ffprobe_cmd}`.to_f.ceil.to_i
    frames_value=frames_per_sec * seconds
    puts "frames_per_sec #{frames_per_sec}, frames_value #{frames_value}" if verbose

    # Using select allows for more exact selection of a frame at the times we want
    ffmpeg_cmd = %Q|ffmpeg -i "#{file}" -vf select='lt(mod(n\\,#{frames_value})\\,1),fps=1/#{seconds}' |
    if opts[:start]
      ffmpeg_cmd += " -ss #{opts[:start]} "
      if opts[:duration]
        ffmpeg_cmd += " -t #{opts[:duration]} "
      end
    end
    ffmpeg_cmd += %Q| "#{output_file_path}-%05d.jpg" |
    puts ffmpeg_cmd if verbose
    `#{ffmpeg_cmd}`

    # We drop the first snapshot because it is the first frame which will either be useless or already in our poster
    # image for the video. This also allows the WebVTT to show the thumbnail of a frame that will come some time after
    # the time selected/clicked on.
    jpegs = Dir.glob(output_file_path + '*.jpg').sort
    FileUtils.rm(jpegs.first)
    jpegs.shift

    if opts[:gif]
      `convert -delay 20 -loop 0 "#{output_file_path}*.jpg" #{output_file_path}.gif`
    end

    # Montage concatenates all the images into an image sprite.
    # TODO: Instead of creating a single sprite take a slice of the output jpegs and create a number of different
    # sprites.
    slice_size = jpegs.length
    if opts[:rows]
      slice_size = opts[:columns] * opts[:rows]
    end
    jpegs.each_slice(slice_size).with_index do | jpeg_slice, index |
      montage_files = jpeg_slice.map{|jpeg| %Q|"#{jpeg}"|}.join(" ")
      padded_index = (index + 1).to_s.rjust(5, "0")
      montage_cmd = %Q|montage #{montage_files} -tile #{columns}x -geometry #{width}x "#{output_file_path}-sprite-#{padded_index}.jpg"|
      puts montage_cmd if verbose
      `#{montage_cmd}`
    end

    # Prepare to create WebVTT file
    if verbose
      puts 'Processing a WebVTT file from these images:'
      puts jpegs
    end
    # place all the cues into an array of hashes like this:
    # {start: 0, end: 5, x: 0, y: 0, w: 200, h: 150}
    cues = []
    start = 0

    # Use the first jpeg to determine the height of the resulting thumbs. We already know the width from the
    # passed in option or the default width.
    first_jpeg = jpegs.first

    original_height = `identify -format "%h" -ping "#{first_jpeg}"`
    original_width = `identify -format "%w" -ping "#{first_jpeg}"`
    processed_height = (original_height.to_f / original_width.to_f * width).to_i
    height = processed_height

    # For each jpeg create a cue
    jpegs.each_slice(slice_size) do | jpeg_slice |
      jpeg_slice.each_with_index do |jpeg, index|
        puts "Index: #{index}" if verbose
        cue = {}

        cue[:start] = start
        cue[:end] = start + opts[:seconds]

        cue[:x] = ((index % opts[:columns]) * opts[:width])
        puts "x #{cue[:x]}" if verbose

        cue[:y] = (index.to_f / opts[:columns].to_f).floor * height
        puts "y #{cue[:y]}" if verbose

        cue[:w] = opts[:width]
        cue[:h] = height

        start += opts[:seconds]
        puts if verbose

        cues << cue
      end
    end

    puts cues if verbose

    # Create a WebVTT file.
    # TODO: When multiple sprites are created use the correct filename for each sprite.
    # media fragment order: x,y,w,h
    webvtt_file_name = output_file_path + '-sprite.vtt'
    puts "Creating WebVTT: #{webvtt_file_name}" if verbose
    File.open(webvtt_file_name, 'w') do |fh|
      fh.puts "WEBVTT\n\nNOTE This file was automatically generated by https://github.com/jronallo/video-sprites\n\n"

      cues.each_slice(slice_size).with_index do |cue_slice, index|
        cue_slice.each do |cue|
          puts cue if verbose
          start_timestamp = timestamp(cue[:start])
          end_timestamp = timestamp(cue[:end])
          fh.print start_timestamp
          fh.print ' --> '
          fh.puts end_timestamp

          padded_index = (index + 1).to_s.rjust(5, "0")

          url = File.join(opts[:url], basename + "-sprite-#{padded_index}.jpg#xywh=#{cue[:x]},#{cue[:y]},#{cue[:w]},#{cue[:h]}")

          fh.puts url
          fh.puts
        end
      end

    end

  end
end
