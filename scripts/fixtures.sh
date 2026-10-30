#!/bin/sh
# Regenerates the WAV files the tests read, with three tools that share no code with this package:
# sox turns the sample text in stereo.dat / six.dat into WAV, and afconvert (macOS), sox and ffmpeg
# each re-encode that. A test compares wav's own header bytes against ffmpeg's and sox's, and reads
# every file back. The files are committed; this script is how they were made.
set -eu
cd "$(dirname "$0")/../sh/sysl/wav/fixtures"
work=$(mktemp -d)
sox stereo.dat -b 16 -e signed-integer "$work/stereo.wav"
sox six.dat -b 24 -e signed-integer "$work/six.wav"

afconvert -f WAVE -d UI8 "$work/stereo.wav" af-pcm8-stereo.wav
afconvert -f WAVE -d LEI16 "$work/stereo.wav" af-pcm16-stereo.wav
afconvert -f WAVE -d LEI32 "$work/stereo.wav" af-pcm32-stereo.wav
afconvert -f WAVE -d LEF32 "$work/stereo.wav" af-float32-stereo.wav
afconvert -f WAVE -d LEI24 "$work/six.wav" af-pcm24-six.wav

sox "$work/stereo.wav" -b 16 -e signed-integer sox-pcm16-stereo.wav
sox "$work/six.wav" -b 24 -e signed-integer sox-pcm24-six.wav

ff() { ffmpeg -loglevel error -y -i "$1" -bitexact -map_metadata -1 -c:a "$2" "$3"; }
ff "$work/stereo.wav" pcm_s24le ff-pcm24-stereo.wav
ff "$work/stereo.wav" pcm_f32le ff-float32-stereo.wav
ff "$work/six.wav" pcm_s24le ff-pcm24-six.wav
ff "$work/six.wav" pcm_f32le ff-float32-six.wav
rm -r "$work"
