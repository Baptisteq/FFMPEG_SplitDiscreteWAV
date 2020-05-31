@echo off

::ffprobe detecte le nombre de canaux audio du fichier entrant
ffprobe -select_streams a -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 %1% > ChannelNumber.txt
for /f %%i in (ChannelNumber.txt) do set "Tracks=%%i"
echo Number of tracks is: %Tracks%
set /a TracksMinusOne=%Tracks%-1
echo Number of tracks - 1 is: %TracksMinusOne%

::3 Scenarii //
:: Master mono - pas de processing
:: Master stereo devient 2 pistes mono .L .R 
:: Master 5.1 devient 6 pistes mono .L .R .C .LFE .LS .RS
:: Si ni 1, 2 et 6 => pistes pistes mono .n.wav .n+1.wav .. .n+%Tracks% 
if %Tracks% == 1 goto Mono 
if %Tracks% == 2 goto FFMPEGSplitLR
if %Tracks% == 6 goto FFMPEGSplitLRCLFELSRS
if %Tracks% neq 1 if %Tracks% neq 2 if %Tracks% neq 6 goto FFMPEGSplitPoly

:Mono
echo mono track; no output file has been processed
goto END
:FFMPEGSplitLR
ffmpeg -i %1 -acodec pcm_s24le -map_channel 0.0.0 "%~n1.L.wav" -acodec pcm_s24le -map_channel 0.0.1 "%~n1.R.wav"
echo Stereo stem; embedded tracks have been splitted to two discrete channels labelled 1.L 2.R
goto END
:FFMPEGSplitLRCLFELSRS
ffmpeg -i %1 -acodec pcm_s24le -map_channel 0.0.0 "%~n1.L.wav" -acodec pcm_s24le -map_channel 0.0.1 "%~n1.R.wav" -acodec pcm_s24le -map_channel 0.0.2 "%~n1.C.wav" -acodec pcm_s24le -map_channel 0.0.3 "%~n1.LFE.wav" -acodec pcm_s24le -map_channel 0.0.4 "%~n1.LS.wav" -acodec pcm_s24le -map_channel 0.0.5 "%~n1.RS.wav"
echo 5.1 stem; embedded tracks have been splitted to 6 discrete channels labelled 1.L 2.R 3.C 4.LFE 5.LS 6.RS
goto END
:FFMPEGSplitPoly
for /l %%a in (0, 1, %TracksMinusOne%) do (
ffmpeg -i %1 -acodec pcm_s24le -map_channel 0.0.%%a "%~n1.%%a.wav"
echo TrackProcess: %%a
)
echo Polyphonic stem; embedded tracks have been splitted to n discrete channels numericly labelled.
:END
:: supprime le fichier temporaire channelnumber.txt
del ChannelNumber.txt
REM pause