# Review findings (2026-10-28 code-quality review of wav and fat)

The wav findings, numbered as in the review. Findings 2, 3, 4, 6, 7 and 12, and the fat halves of
8, 9, 13 and 14, belong to `sysl-lang/fat`.

| # | finding | status | commit |
|---|---|---|---|
| 1 | own `Source`/`Sink` traits duplicate `sysl.io` and flatten store errors to `Io` | already fixed: `ReadAt`/`WriteAt` bounds, `Error[E]` with `Io(cause: E)`, `read_exact_at`/`write_all_at`, `extent(*self)`; `append` and `finish` both pass the store's error through | `2c571e2` (v0.1.0) |
| 5 | no independent oracle for the riskiest bytes; reader stricter than real files | lenient reader and pinned error variants already fixed in `2c571e2`; fixed now: WAVs made by afconvert, sox and ffmpeg (`scripts/fixtures.sh`) are read with afinfo's format, frames and offset, three tools' conversions of one source read back alike, and wav's own output equals ffmpeg's and sox's byte for byte (PCM16, PCM24 stereo and 5.1 extensible, float stereo and 5.1 extensible with `fact`). 24-in-32 stays a hand-written fixture: none of the three tools writes it | `2c571e2`, `b1c9176` |
| 8 | error enum: `seek_frame` past the end is `InvalidBuffer`; `Io` means three things | already fixed: `OutOfRange`; `Io` carries only the store's own error, and zero progress or over-reporting is `sysl.io`'s contract | `2c571e2` |
| 9 | hand-rolled helpers | fixed now: the header is `@packed @byte_order(little)` structs, so `get16`/`get32`/`put16`/`put32`/`tag`/`put_tag` are gone; `count_ones`, `sysl.slices.fill`, `sysl.math.min` | `b1c9176` |
| 10 | `append` builds an 80-byte header to check overflow | already fixed (`fits`, shared with `header`); fixed now: `append`'s refusal is tested at the exact boundary | `2c571e2`, `b1c9176` |
| 11 | `Reader` not tied to its source | already fixed: `Reader` and `Writer` hold `*S`, as fat's `Volume` does | `2c571e2` |
| 13 | magic numbers | fixed now: format tags, the KSDATAFORMAT GUID tail, `cbSize`, speaker bits, the 32-bit size limits and the chunk ids are named once, shared by writer and parser | `b1c9176` |
| 14 | idiom and style | fixed now: org style (spaces, one statement per line), no redundant suffixes, the portable probe uses `as_ptr`/`as_mut_ptr` rather than `&x[0]` | `b1c9176` |
