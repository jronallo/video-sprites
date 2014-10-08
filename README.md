# Video::Sprites

Exports thumbnail images, thumbnail sprite image, and WebVTT metadata. ffmpeg and ImageMagick are required.

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

Frames: Optional. Time between the snapshots. (Default 5 seconds.)

Width:  Optional. Width of the each thumbnail. (Default 200.)

Columns: Number of columns in the sprite. (Default 5.)

Keep: Keep all the individual images and other intermediate artifacts.

Input: Input file or directory. (Default: Current working directory.)

Output: Output directory. (Default: Current working directory with "output" directory.)

URL base: base URL to use for

Clean: Optional. Clear the output directory for files named like the input file before execution. (Defaults to false)

```shell
video-sprites --interval 5 --width 200 --columns 5 --keepgenerated --input . --output ./output
```

## Test Media Sources

https://www.youtube.com/watch?v=dTCEDG9h9AA

https://www.youtube.com/watch?v=9AGisNPUBqM

https://www.youtube.com/watch?v=Z9To9NOLEPI

https://www.youtube.com/watch?v=Ww4WrcjAOlo

https://www.youtube.com/watch?v=wz-eInv9f7g

## TODO

- Instead of creating one sprite, create multiple sprites and have them appropriately listed in the WebVTT file.
- Allow for setting the base URL to use in the VTT file.
- Consider adding an option to change the output filename.
- Optionally allow for scene change detection and variable length cues. How difficult would this be?