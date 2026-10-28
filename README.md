# wav

Allocation-free streaming RIFF/WAVE for Sysl firmware and applications.
No filesystem, OS, heap, audio hardware or Benchtop dependency.

Supports little-endian unsigned PCM8, signed PCM16/24/32 and IEEE float32,
channel-interleaved frames, arbitrary valid channel counts and sample rates.
Multichannel/masked and >16-bit integer output uses WAVEFORMATEXTENSIBLE.
Float output includes a fact chunk. Extensible input with fewer valid bits than
its container (24 in 32) reads as the container; compressed codecs, float64,
RF64 and RIFX are unsupported.

The store is any `sysl.io` `ReadAt` (reading) or `WriteAt` (writing), such as a
file, flash or `slice_at` over a caller's buffer. Errors are `Error[E]`, where
`E` is the store's own error, carried as `Io(cause)`; functions that touch no
store (`validate`, `header`, `Reader.seek_frame`) answer `Error[never]`, which
`?` converts into any store's error. `reader` and `writer` hold the store
pointer, so it is passed once. `reader` scans RIFF chunks, skipping unknown
chunks and padding, and validates lengths and frame alignment. It accepts what
recorders leave behind: a RIFF or data size of 0 or `0xFFFFFFFF` runs to the end
of the store, a RIFF size larger than the store is clamped to it, and a final
odd chunk may lack its pad byte. A chunk claiming bytes the store lacks is
`Truncated`. Samples remain raw encoded bytes: no resampling, mixing,
integer/float conversion or codec decoding is implied.

```sysl
import sh.sysl.wav as wav
var output = wav.writer(&store,wav.format(48000,2,wav.Encoding.Pcm16)).unwrap()
output.append(interleaved_pcm_bytes).unwrap()
output.finish().unwrap()
```

The store must be an empty/truncated object dedicated to this WAV, with exclusive
access until finalization, and must outlive the reader or writer. `finish` pads
odd payloads, updates RIFF/data/fact lengths, and syncs. I/O failures poison the
writer: an unfinished/failed recording is not promised readable. Size overflow is
rejected before writing. Classic RIFF limits files to approximately 4 GiB; the
filesystem can impose a lower limit. Streaming uses fixed headers up to 80 bytes
and caller-owned payloads.

```hocon
dependencies {
  wav { git = "github.com/sysl-lang/wav", version = "0.1.0" }
}
```

Needs sysl 0.7.6. Run `scripts/gate.sh`: the tests, and instantiated builds for
five freestanding targets. Compile probes do not execute on physical hardware.

References: [Microsoft WAVEFORMATEXTENSIBLE](https://learn.microsoft.com/en-us/windows/win32/api/mmreg/ns-mmreg-waveformatextensible)
and [Microsoft wave formats](https://github.com/microsoft/DirectXTK/wiki/Wave-Formats).
