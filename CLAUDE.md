# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Digital voice transmission system implemented in Simulink. BPSK modulation over AWGN channel with PCM encoding/decoding and RRC pulse shaping. Two model variants: a floating-point reference (`voice_tx_system.slx`) and an HDL-targeted version (`voice_tx_hdl.slx`) for FPGA synthesis via HDL Coder.

## Signal Chain Architecture

```
Audio Source (.wav) -> PCM Encoder (Quantizer -> Int2Bit) -> BPSK Modulator (BPSK Mod -> RRC Tx Filter) -> AWGN Channel -> BPSK Demodulator (RRC Rx Filter -> BPSK Demod) -> PCM Decoder (Bit2Int -> Dequantizer) -> Audio Output
```

Both models share the same topology. The HDL variant substitutes fixed-point implementations in the BPSK and PCM blocks for HDL Coder compatibility.

## Common Commands

```matlab
% Open and run the reference model
open_system('voice_tx_system');
sim('voice_tx_system');

% Run the HDL-targeted model
sim('voice_tx_hdl');

% BER vs Eb/N0 sweep
run('run_ber_sweep.m');

% Play the reference audio
[audio, fs] = audioread('voice_input.wav');
sound(audio, fs);
```

`run_ber_sweep.m` iterates over Eb/N0 values (0:2:10 dB), runs the simulation at each point, computes reconstructed SNR, MSE, and cross-correlation against the original audio, and saves results to `ber_results.mat`.

## Model Variants and Backups

| File | Purpose |
|------|---------|
| `voice_tx_system.slx` | Floating-point reference model (StopTime=16.2s, full audio) |
| `voice_tx_hdl.slx` | **Active** HDL-targeted model (StopTime=0.5s) |
| `voice_tx_hdl_orig.slx` | Clean backup of the HDL model |
| `voice_tx_hdl.slx.original` | Earlier backup |
| `voice_tx_hdl.slx.broken` | Snapshot of a known-broken state |

The HDL model (`voice_tx_hdl.slx`) is the primary development target. If Simulink reports it as corrupted, restore from `voice_tx_hdl_orig.slx`.

## Environment

- MATLAB R2025b with Simulink, HDL Coder, DSP HDL Toolbox, Communications Toolbox, Signal Processing Toolbox, Audio Toolbox, Fixed-Point Designer
- MCP MATLAB server available for programmatic model inspection and editing
- Project directory: `D:\zizim\Documents\UJN_HW\proj2`

## Generated/Cached Artifacts

- `slprj/` — Simulink cache: rapid-accel code (`_cgxe`), C code (`_cprj`), GRT target build, HDL Coder output, Model Advisor results
- `voice_tx_hdl_cgxe.mexw64` — Compiled MEX for accelerated HDL model simulation
- `.satk/` — Simulink Agentic Toolkit config (no reuse libraries configured)
- `agenticToolkitInstaller.mltbx` — MATLAB toolbox package for the agentic toolkit
