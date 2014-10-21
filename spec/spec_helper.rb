# Testing plan of attack
# - That the right number of thumbnails are created for different parameters.
# - That the WebVTT file includes the text WEBVTT, a NOTE (see issue #1), a first cue that matches the duration given, and the expected cue payload.

Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.formatter = :documentation
end