# Voxtype model choice (2026-10-21)

Switched dictation from Parakeet TDT 0.6B v3 to v2 (English-only).

## Timeline

- Until 2026-10-19: Whisper large-v3-turbo.
- 2026-10-20: tested engines, switched to Parakeet v3. Faster and better than Whisper.
- 2026-10-21: three reboots. Dictation felt worse after them. Every boot loaded Parakeet v3 on CUDA; mic was the OBSBOT Meet 2 at 100%, not muted. No cause found.
- 2026-10-21: switched to Parakeet v2.

## Benchmark

Same 9.6 s speech clip (not Dylan's voice), RTX 5070 Ti, CUDA 13. All three gave the same text.

| Model | Transcribe | Peak VRAM | Disk |
|---|---|---|---|
| Parakeet v3 | 0.21 s | 3,846 MiB | 2.4 GB |
| Parakeet v2 | 0.23-0.25 s | 3,656 MiB | 2.4 GB |
| Cohere Transcribe fp16 | 1.4-1.5 s | not measured | 3.9 GB |

- Reported English average WER: v2 6.05%, v3 about 6.3%. v3 trades some English accuracy for 25 languages.
- Cohere Transcribe has no English-only build (one model, `cohere.language = "en"`). Too slow for dictation.
- Model load takes about 0.8 s, so `on_demand_loading` would add that to every dictation.

## Not checked

- Whether v2 is more accurate than v3 on Dylan's voice.
- The int8 Parakeet variants (less VRAM, possibly lower accuracy).

## Revert

Set `[parakeet] model = "parakeet-tdt-0.6b-v3"` in `voxtype/config.toml`, then `systemctl --user restart voxtype`. Both models are installed in `~/.local/share/voxtype/models/`.

## Test commands

```sh
voxtype -v transcribe test.wav            # active engine, logs "completed in"
voxtype -v -c alt.toml transcribe test.wav
```

Input must be 16 kHz mono WAV: `ffmpeg -i in.wav -ac 1 -ar 16000 test.wav`.
