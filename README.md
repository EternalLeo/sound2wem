<div align="center">

# sound2wem
Converts audio files to Wwise Audio (.wem)

</div>

- What is this?

sound2wem is a script to automatically convert any audio file type (.mp3, .wav, .ogg, ...) to Wwise Audio formats.

This script is both the most convenient, complete, and fastest tool for this job right now. And there are no existing online converters yet.

## Installation
Simply download `zSound2wem.cmd` and place it into a folder of your choice. (Desktop is not recommended, all dependencies will be installed into the script folder)

Or if you're a terminal hacker.
1. Create a folder for the script in your desired location and enter it
    ```terminal
    md sound2wem
    cd sound2wem
    ```
2. Install using curl
    ```terminal
    curl -O -# "https://raw.githubusercontent.com/EternalLeo/sound2wem/main/zSound2wem.cmd"
    ```

Now you're set! It is recommended to `right-click` then `edit` to read the informative comments within the script.
It is also where you'll find the script configs.

## Usage
Simply drag n' drop your audio files onto the script!

Or if you're a terminal hacker, pass them as arguments.

## Information about installation

Upon running the script for the first time, you'll be prompted to install Wwise, and FFmpeg, unless you already have them.
If installing FFmpeg is required, the script will temporarily install 7zip if not found to unzip it.
The script has automatic updates straight from this github (which can be turned off in the configs).

## Features

Easy configuration achieved with ffmpeg, all accessible in the configuration section of the script.\
Set `bitrate`, `audio channels`, `volume`, and custom flags.

Intuitive drag 'n drop conversion process – converts any audio format to .wav which is then converted to .wem

Script updates, very rare, will require manual configuration migration, due to the choice of not creating a config file for superior portability.

## Extra

Internally, it uses both FFmpeg and Wwise for conversion. I documented the script as much as I had patience to.

I use `foobar2000` with `vgmstream extension` to listen to Wwise format audio files.

I use `Wwiseutil-gui` or `BNKReplacer` to replace the desired audio files in Wwise sound banks (.bnk). The output format differs a bit I believe, since in some applications one will work but not the other.

## Future Development

- For more customizable automated workflows, it could be a future update to configuration as flags, or even a custom optional config file ruleset.\
e.g. `zSound2wem.cmd --volume 1.5 audio.mp3` out: `audio.wem`\
When and if this is implemented, potentially re-include temporarily storing arguments in case of script update.

## Changelog

### - Version 3

Made automatic updates `true` by default instead of `forced`.\
Including handling errors better. Does not try to re-run the conversion task by storing arguments in a temp file anymore.

Bug fixes:\
\- fixed errors that occured if paths to ffmpeg or audio files had special characters like spaces
(still, don't try to break it too hard)

Deprecated wmic for a niche part of installation and replaced with a better alternative.  

Fixed a few typos, perhaps added more, renamed the default wwise project it creates for conversion.

### - Version 2 (Release)

ffmpeg and wwise conversion features, automatic installation and updates, 

### - Version 1 (Pre-release)

Development proof of concept.

## Special thanks

veksha
