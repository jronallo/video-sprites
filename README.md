# Video Sprites

Exports thumbnail images, thumbnail sprite image, and WebVTT metadata. 

## Installation

```ruby
gem 'video-sprites'
```

## Requirements

- ffmpeg
- imagemagick (montage)

## Usage

```shell
video-sprites --help
```

```shell
video-sprites --seconds 5 --width 200 --columns 5 --input . --output ./output
```

## Test Media Sources

https://www.youtube.com/watch?v=dTCEDG9h9AA

https://www.youtube.com/watch?v=9AGisNPUBqM

https://www.youtube.com/watch?v=Z9To9NOLEPI

https://www.youtube.com/watch?v=Ww4WrcjAOlo

https://www.youtube.com/watch?v=wz-eInv9f7g

## TODO

- Consider adding an option to change the output filename.
- Optionally allow for scene change detection and variable length cues. How difficult would this be?
- Should the first timestamp after the first cue not be on the second but be a fractional second instead?

## Authors

- Ashley Blewer
- Jay Brown 
- Jason Ronallo
- Nicholas Zoss
