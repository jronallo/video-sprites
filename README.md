# Video::Sprites

Exports thumbnail images, thumbnail sprite image, and WebVTT metadata.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'video-sprites'
```

## Requirements

- ffmpeg
- imagemagick (montage)

## Usage

### Options

* -f for frames. Optional. Time between the snapshots. (Default 5 seconds.)
* -w for width. Optional. Width of the each thumbnail. (Default 200.)
* -c for columns. Number of columns in the sprite. (Default 5.)
* -k for keep. Keep all the individual images and other intermediate artifacts.
* -i for input. This is the only required field. (Default: Current working directory.)
* -o for output. Output directory. (Default: Current working directory with "output" directory.)
* -v for verbose. Detailed comments when processing.
* -z for clean. Optional. Clear the output directory for files named like the input file before execution. (Defaults to false)
* -h for help. Explains each flag.

```shell
video-sprites --interval 5 --width 200 --columns 5 --keepgenerated --input . --output ./output
```

# TODO

- Consider adding an option to change the output filename