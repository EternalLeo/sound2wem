<meta name="google-site-verification" content="mmqd6lA3evrEOJplJUyTIFXyR1YhLTW4_bvnIE7qN1c" />
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

## Extra

Internally, it uses both FFmpeg and Wwise for conversion. I documended the script as much as I had patience to.

I use `foobar2000` with `vgmstream extension` to listen to Wwise format audio files.

I use `Wwiseutil-gui` to replace the desired audio files in Wwise sound banks (.bnk).

## Future to do list
 - Currently automatic updates reset the script configs, fix that.

And since the only `to do` is fixing the `to do`, then there's nothing to do for now.
