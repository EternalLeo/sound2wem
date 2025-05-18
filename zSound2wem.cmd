@echo off
setlocal enabledelayedexpansion
title Soundsfiles to Wwise .wem
chcp 65001>nul
color f
:: Setting current directory to the folder the script is in (just in case).
set "cd=%~dp0"
if "!cd:~-1,1!"=="\" set "cd=!cd:~0,-1!"
cd !cd!

:: [Script Author:   "Leo Pasanen"]
:: [Script Version:  "3"]
:: [Date of version: "27.1.2025"]
:: [Code License:    "Mozilla Public License 2.0"]

::----------------------------------------::
:: [User Section]
:: This script is used to convert audio files (.mp3, .wav, ...) to Wwise Vorbis audio (.wem).
:: By default, this script uses the folder it's placed in! It is not recommended to run it directly from Desktop.
:: To uninstall, simply unistall Wwise, delete the generated conversion project folder, (optional) delete folder containing ffmpeg, and finally delete the script.

:: Requirements: Wwise, FFmpeg
:: IF the requirements are not met, this script will guide you along an installation (so run it anyways).
:: 		Wwise will need to be installed manually, by creating an account on Audiokinetic's site.
:: 		FFmpeg will be automatically installed in the current directory (will not be saved in path).
:: 		To unzip FFmpeg, the script will also temporarily install 7-zip (then remove it), if it's not found in path or its typical locations.
:: (Options will work by default, so only bother with them when you need to)
:: Usage and installation meant for 64-bit computers.

:: [Usage]
:: Choose one of the following
:: [1] Drag n' drop your audio files onto the script. (With drag n' drop, batch has a seizure. See [?4])
:: [2] Run the script with command line arguments consisting of your audio file names.

:: [Tips]
:: I use foobar2000 with the vgmstream extension to play Wwise sound bank (.bnk) audio.
:: Then I convert the desired replacement audio using this script.
:: Lastly, I use wwiseutil-gui to replace the desired original audios with the new ones. Useful for game modding.

:: [Conversion Options]
:: Note that the single quotation mark after the set is intentational and should be kept.
:: See [?1] as for why.

:: Path to Wwise base directory. Simply modify the BASE variable (although we only care about the PATH one). (Uses the environment variables set with wwise installation.)
set "wwiseBASE=%WWISEROOT%
set "wwisePATH=%wwiseBASE%\Authoring\x64\Release\bin\WwiseConsole.exe

:: Path to ffmpeg, (blank = current directory / in path)
set "ffmpeg=

:: Path to 7zip, (blank = current directory / in path) (7zip is only required for automated installation)
set "7zPATH=

:: Audio frequency in Hz. (Do not include the unit, e.g. 8000, 24000, 48000) (blank means same as source)
set samplerate=

:: Audio channels, 1 is mono, 2 is stereo... (blank means same as source)
set channels=

:: Audio Volume, can enter a fraction (1.5 = 150%, 0.5 = 50%), or a decibel value (10dB, -5dB, increasing and decreasing respectively); (blank = no change)
set volume=

:: ffmpeg extra - extra parameters to include for ffmpeg to change your audio, example (loudnorm) to normalize volume. (blank = nothing)
set extra=

:: Conversion (case-sensitive name), specifies the conversion type and the quality affects the size and bitrate of the result. (High, Medium, Low)
set "conversion=Vorbis Quality High

:: Wwise Conversion Project Path (See [?])
set "project=wavtowemscript

:: Output directy, blank = current
set "out=

:: Whether to close the window when the conversion is done [true/false]
set CloseOnExit=true

:: Automatically check for script updates from github [true/false/forced] (forced doesn't ask whether to install, it just does)
set updates=true

:: Script version
set version=4
::----------------------------------------::

:: [Some examples of what some conversion options might look like]
:: set "ffmpeg=C:\Users\myuser\ffmpeg\bin\ffmpeg.exe
:: set samplerate=48000
:: set volume=2.5
:: set channels=1
:: [End examples]

:: [?1] - Why the single quotation mark after the set, before the variable name?
:: Quotations marks aren't actually matched in batch scripts, instead, they are toggles.
:: Effectively, one quotation mark removes the need for the user to add quotation marks of their own, while also preserving special characters.
:: Also, it is standard to put the quotation mark before the variable name, so that it isn't actually included in the contents.

:: [Installation section]

:: Update just installed if this flag is passed
if "%~1"=="installtmp" (
cd..
ren zSound2wem.cmd zSound2wem.cmd.old
echo If you are asked to replace a file, it is recommended to not do so, as it will likely delete your previous script configuration.
copy "installtmp\zSound2wem.cmd" "zSound2wem.cmd" > nul
:: Legacy argument passing file, we're not using it anymore.
if exist "argstmp.txt" del /q /f "argstmp.txt"
echo(
echo Successfully updated^^!
echo You need to manually migrate your script configs from zSound2wem.cmd.old to zSound2wem.cmd.
echo Quiting in 10 seconds or upon keypress...
timeout /t 10 > nul
exit
)
:: Delete update dregs if they exist.
if exist "installtmp\*" rmdir /s /q "installtmp"
:: Check for updates if enabled.
if /i not "!updates!"=="true" if /i not "!updates!"=="forced" goto noupdates
for /f "tokens=1" %%a in ('curl -s "https://raw.githubusercontent.com/EternalLeo/sound2wem/main/version.txt"')do set "cloudver=%%a"
if not "!cloudver::=!"=="!cloudver!" echo [91mWarning:[39m could not fetch online version.&goto noupdates
if !version! GEQ !cloudver! goto noupdates
if /i "!updates!"=="true" (
echo A script update is available. Do you want to install it right now? This will cancel your conversion. [[38;5;35mY[39m/[91mN[39m]
for /f "tokens=*" %%a in ('choice /c YN /n')do if "%%a"=="N" goto noupdates
)
md installtmp
curl -O --output-dir "installtmp" -# "https://raw.githubusercontent.com/EternalLeo/sound2wem/main/zSound2wem.cmd"
if not exist "installtmp\zSound2wem.cmd" echo [91mWarning:[39m Update unsuccessful.&goto noupdates
:: Check filesize of download so that it doesn't just contain a network error or something.
for %%a in ("installtmp\zSound2wem.cmd")do (
	if %%~za LSS 5000 echo [91mWarning:[39m Update unsuccessful.&goto noupdates
	if %%~za GTR 50000 echo [91mWarning:[39m Update likely unsuccessful.&goto noupdates
)
start installtmp\zSound2wem.cmd installtmp
exit
:noupdates

:: Command line lazy argument parsing
for %%a in (%*) do (
	set "validarg=%%~a"
	if "!validarg:~0,2!"=="--" (
		for /f "tokens=1,2 delims=:" %%b in ("!validarg:~2!") do (
			set "argument=%%b"
			set "value=%%c"
		)
		if "!argument!"=="ffmpeg" set "ffmpeg=!value!"
		if "!argument!"=="wwise" set "wwisePATH=!value!"
		if "!argument!"=="samplerate" set "samplerate=!value!"
		if "!argument!"=="channels" set "channels=!value!"
		if "!argument!"=="volume" set "volume=!value!"
		if "!argument!"=="extra" set "extra=!value!"
		if "!argument!"=="conversion" set "conversion=!value!"
		if "!argument!"=="out" set "out=!value!"
		set CloseOnExit=true
	)
) 

:: Save all drive letters (useful if a requirement is not found, to crawl for it in all drives)
for /f "tokens=1*" %%a in ('fsutil fsinfo drives')do set "Drives=%%b"
if "!Drives!"=="" set "Drives=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"%= No drive letters found, so add them all manually to check. (a just in case feature) What is this? See [?2] =%

:: Check for Wwise.
if exist "!wwisePATH!" goto foundwwise
if defined WWISEROOT set "wwiseBASE=%WWISEROOT%"&set "wwisePATH=%wwiseBASE%\Authoring\x64\Release\bin\WwiseConsole.exe"&goto foundwwise

:: Wwise not found at its expected location, try Program Files (x86) at all drive letters before commencing guided installation.
for %%a in (!Drives!)do if exist "%%aProgram Files (x86)" (         %= If exist filters all non-drives =%
	for /f "delims=" %%b in ('dir "%%aProgram Files (x86)" /b /a:d /o:d /t:c ^| findstr "Wwise"')do set "wwiseBASE=%%b"&set "wwisePATH=%wwiseBASE%\Authoring\x64\Release\bin\WwiseConsole.exe
	) %= Criteria is within Program Files (x86) and the folder name contains "Wwise", and selects the newest one. =%
if exist "!wwisePATH!" goto foundwwise
:: Could not find Wwise.
echo [91mCould not find [93mWwise[91m.[39m
if defined WWISEROOT echo The Wwise environment variable exists, perhaps try specifying it's location in the script configs ^(right-click + edit^) or try reinstalling Wwise. 
echo Do you want to go the download site to install it right now? [[38;5;35mY[39m/[91mN[39m]
for /f "tokens=*" %%a in ('choice /c YN /n')do if "%%a"=="N" echo Aborting... &<nul set/p=Press any key to exit... & pause>nul & exit
:: Earlier versions of the script used to curl donwload the installer, until Audiokinetic hid it behind web cookies.
start "" "https://www.audiokinetic.com/en/thank-you/launcher/windows/?ref=download&platform=1"
echo Please restart the script once you have installed Wwise.
<nul set/p=Press any key to exit...
pause>nul
exit

:foundwwise
:: Wwise found, can continue.
:: Check for FFmpeg.

if exist "!ffmpeg!" goto conversion
for /f "tokens=*" %%a in ('dir /b /a:d /o:d /t:c ^| findstr "ffmpeg"')do if exist "%%a\bin\ffmpeg.exe" set "ffmpeg=%%a\bin\ffmpeg.exe"&goto conversion
where /q ffmpeg && (set ffmpeg=ffmpeg&goto conversion)
:: See [?3] for brief explanation on finding process.

echo [91mCould not find [93mffmpeg[91m.[39m
echo Do you want to perform an [36mautomatic installation[39m using [93m7zip[39m? [[38;5;35mY[39m/[91mN[39m]
for /f "tokens=*" %%a in ('choice /c YN /n')do if "%%a"=="N" echo Aborting... &<nul set/p=Press any key to exit... & pause>nul & exit
:: User proceeded with automatic installation of FFmpeg.
:: Check for 7zip.

if exist "!7zPATH!" goto foundzip
where /q 7z && (set 7zPATH=7z&goto foundzip)
for %%a in (!Drives!)do if exist "%%aProgram Files\7-Zip\7z.exe" set 7zPATH="%%a\Program Files\7-Zip\7z.exe"&goto foundzip
if exist "7ztemp\x64\7za.exe" set "7zPATH=7ztemp\x64\7za.exe"&goto foundzip

:: For some reason on my machine, the ffmpeg zip could not be unzipped with just the standalone 32-bit console version (would error out).
:: A standalone is required for convenient installation, so the small standalone is used to unzip the other standalone version, which is in .7z format. 
echo [91mCould not find [93m7zip[91m.[39m Temporarily installing...
if not exist "7zr.exe" curl -O -# "https://www.7-zip.org/a/7zr.exe"
if not exist "7z2201-extra.7z" curl -O -# "https://www.7-zip.org/a/7z2201-extra.7z"
7zr.exe x 7z2201-extra.7z -o7ztemp > nul
del /q /f 7z2201-extra.7z

:: Check OS architecture on whether to use the 32-bit or 64-bit version. (Two for loops to get rid of empty newline.)
:: It will always be AMD64 on 64-bit x86, even if it's an intel processor.
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set "7zPATH=7ztemp\x64\7za.exe")else set "7zPATH=7ztemp\7za.exe"

if not exist "!7zPATH!" echo [91mError: [93m7zip[91m not found by unknown error.[39m&echo If 7zip was successfully installed regardless, try specifying it in the script configs ^(right-click + edit^), or try rerunning the script.&echo Aborting... &<nul set/p=Press any key to exit... & pause>nul & exit

:foundzip
:: 7zip found.

:: I'm too lazy to care about automatically downloading for 32-bit PCs right now, maybe I'll update the script for that one day.
if not exist "ffmpeg-master-latest-win64-gpl-shared.zip" curl -L -O -# "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip"
"!7zPATH!" x "ffmpeg-master-latest-win64-gpl-shared.zip" > nul
:: Remove temporary dregs
if exist "ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe" (set "ffmpeg=ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe")else echo [91mError: [93mFFmpeg[91m not found by unknown error.[39m&echo If FFmpeg was successfully installed regardless, try specifying it in the script configs ^(right-click + edit^).&echo Aborting... &<nul set/p=Press any key to exit... & pause>nul & exit
if exist "ffmpeg-master-latest-win64-gpl-shared.zip" del /q /f ffmpeg-master-latest-win64-gpl-shared.zip
if exist "7zr.exe" del /q /f 7zr.exe
if exist "7ztemp\*" rmdir /s /q 7ztemp

echo [38;5;35mInstallation Success^^![39m
:: [Installation section end]
:conversion
if "%~1"=="" echo [91mError: [95mNo arguments[39m were provided, unable to convert [36mnull[39m. ^(No sound files given^) &<nul set/p=Press any key to exit... & pause>nul & exit
:: %* Contains all arguments, from this point on, the script needs audio files to convert.

:: Create Project for conversion
if not exist "!project!\*" "!wwisePATH!" create-new-project "!project!\!project!.wproj" --quiet

:: ffmpeg conversion
md audiotemp
:: Setting flags
if not "!samplerate!"=="" set "samplerate=-ar !samplerate! "
if not "!channels!"=="" set "channels=-ac !channels! "
if not "!volume!"=="" set "volume=!volume:db=dB!" & set volume=-filter:a "volume=!volume!" 
if not "!extra!"=="" set "extra=!extra! " 
:: Convert audio files to (.wav) using preferred user settings, to then convert with Wwise.
for %%a in (%*)do set "validarg=%%~a" & if not "!validarg:~0,2!"=="--" "!ffmpeg!" -hide_banner -loglevel warning -i %%a !samplerate!!channels!!volume!!extra!"audiotemp\%%~na.wav"

:: Create wsources file for Wwise conversion. See [?5] to view the format more clearly.
if exist "list.wsources" del /q /f "list.wsources"
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<ExternalSourcesList SchemaVersion="1" Root="!cd!\audiotemp"^>
) > "list.wsources"
for /f "tokens=* delims=" %%a in ('dir audiotemp /b ')do echo 	^<Source Path="%%a" Conversion="!conversion!"/^>>> "list.wsources"
echo ^</ExternalSourcesList^>>> "list.wsources"
if "!out!"=="" set "out=!cd!"
"!wwisePATH!" convert-external-source "!project!\!project!.wproj" --source-file "!cd!\list.wsources" --output "!out!" --quiet
for %%a in (%*)do if exist "audiotemp\%%~na.akd" del /f /q "audiotemp\%%~na.akd"
for %%a in (%*)do if exist "audiotemp\%%~na.wav" del /f /q "audiotemp\%%~na.wav"
move "!cd!\Windows\*" "!cd!" >nul
rmdir /s /q "!out!\Windows"
rmdir /q "audiotemp"
del /f /q list.wsources
:: No we did not just delete Windows, do not worry. Funny naming sense, Audiokinetic.
echo [38;5;35mDone.[39m
if /i not "!CloseOnExit!"=="true" pause
exit
:: [END OF MAIN]


:: [?2] - Inline comments
:: An inline comment %= Comment here! =% is actually a variable denoted by the two percent signs.
:: But it is a variable that can never be defined, and empty variables expand to nothing (thus not affecting runtime).
%= So effectively, this serves as a comment. =%
:: They are an alternative to double colons comments since these can only be at the beginning of a line.

:: [?3] - Finding process
:: If the path to ffmpeg is directly in the variable, it means the user has specified it explitictly.
:: Loops through the folders of the current directory with "ffmpeg" in their names, and chooses the most recent one's executable.
:: This one's the most interesting - uses the where command and it's returned errorlevel to find it if it's in the path environment variable.
:: where /q "target" && echo Success || echo Fail

:: [?4] - Drag 'n drop
:: Dragging and dropping files onto a batch file only adds quotes if the file names has spaces in it.
:: This means that special characters within filenames like "&^!" will probably not work, and break things. 
:: If this is a problem, use the second method, adding quotes, and even escaping characters if necessary.

:: [?5] - .wsources format
:: <?xml version="1.0" encoding="UTF-8"?>
:: <ExternalSourcesList SchemaVersion="1" Root="[Directory for audio files]">
:: [Repeat the following source line for all audio files]
:: 	<Source Path="[filename]" Conversion="[Case Sensitive Name for conversion target]"/>
:: </ExternalSourcesList>
