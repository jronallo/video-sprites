# Testing plan of attack
# creation_spec.rb - That the files we expect to be created are created and have a size larger than 0.
# input_spec.rb - That not adding an input parameter shows the help message and any other cases where it should bomb out.
# - That the right number of thumbnails are created for different parameters.
# - That the WebVTT file includes the text WEBVTT, a NOTE (see issue #1), a first cue that matches the duration given, and the expected cue payload.

Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.formatter = :documentation
end

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end