# wav

Allocation-free streaming RIFF/WAVE for Sysl firmware and applications.
No filesystem, OS, heap, audio hardware or Benchtop dependency.

Supports little-endian unsigned PCM8, signed PCM16/24/32 and IEEE float32,
channel-interleaved frames, arbitrary valid channel counts and sample rates.
Multichannel/masked and >16-bit integer output uses WAVEFORMATEXTENSIBLE.
Float output includes a fact chunk. Extensible input requires all container
bits to be valid; compressed codecs, float64, RF64 and RIFX are unsupported.

Implement `Source` (size/read_at) or `Sink` (write_at/sync). Partial reads/writes
are handled; zero progress and impossible byte counts fail. Callbacks must bound
their own waits. `reader` scans RIFF chunks, skipping unknown chunks and padding,
validates lengths and frame alignment, and exposes frame reads/seeking. Samples
remain raw encoded bytes: no resampling, mixing, integer/float conversion or
codec decoding is implied.

```sysl
import sh.sysl.wav as wav
var output = wav.writer(&sink,wav.format(48000,2,wav.Encoding.Pcm16)).unwrap()
output.append(&sink,interleaved_pcm_bytes).unwrap()
output.finish(&sink).unwrap()
```

The sink must be an empty/truncated object dedicated to this WAV, with exclusive
access until finalization. `finish` pads odd payloads, updates RIFF/data/fact
lengths, and syncs. I/O failures poison the writer: an unfinished/failed recording
is not promised readable. Size overflow is rejected before writing. Classic
RIFF limits files to approximately 4 GiB; the filesystem can impose a lower
limit. Streaming uses fixed headers up to 80 bytes and caller-owned payloads.

Development branch `dev`, no release tag yet. Dependency: git
`github.com/sysl-lang/wav` with an exact `rev`. Run `scripts/gate.sh`: protocol
regressions and instantiated builds for five freestanding targets. Compile
probes do not execute on physical hardware.

References: [Microsoft WAVEFORMATEXTENSIBLE](https://learn.microsoft.com/en-us/windows/win32/api/mmreg/ns-mmreg-waveformatextensible)
and [Microsoft wave formats](https://github.com/microsoft/DirectXTK/wiki/Wave-Formats).
