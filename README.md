# Voice Transmission over BPSK — HDL Cosimulation Project

Digital voice transmission system over BPSK/AWGN with RRC pulse shaping, targeting Xilinx Zynq-7020 FPGA via HDL Coder and Vivado. Prepared for expansion to D-BPSK and other modulation schemes.

## Directory Structure

```
proj2/
  models/                         # Simulink models
    bpsk/                         # BPSK models
      voice_tx_system.slx         # Floating-point reference (full audio chain)
      voice_tx_hdl_cosim.slx      # HDL-targeted model with cosim blocks
      bpsk_hdl_cosim.slx          # Standalone BPSK modulator/demodulator cosim
    dbpsk/                        # D-BPSK models (future)
  scripts/                        # MATLAB scripts
    bpsk/                         # BPSK-specific
    common/                       # Shared across modulation schemes
      run_ber_sweep.m             # BER vs Eb/N0 sweep (0:2:10 dB)
      board_def/alinx_ax7z020.m   # ALINX AX7Z020 board definition
    dbpsk/                        # D-BPSK (future)
  audio/                          # Audio sample files
    voice_input.wav               # Input (16 kHz mono)
    voice_output_ref.wav          # Reference output for comparison
  data/                           # Experiment results (.mat)
  vivado/                         # Vivado projects
    bpsk/                         # BPSK DUT Vivado project (xc7z020-2clg400)
  hdl_prj/hdlsrc/                 # HDL Coder output (Verilog/VHDL sources)
```

## Signal Chain

```
Audio (.wav) → PCM Encoder → BPSK Modulator → RRC Tx Filter → AWGN Channel → RRC Rx Filter → BPSK Demodulator → PCM Decoder → Audio Output
```

## Quick Start

### MATLAB / Simulink

Add project directories to MATLAB path (run from project root):

```matlab
addpath('models/bpsk', 'scripts/bpsk', 'scripts/common', 'scripts/common/board_def');
```

Run floating-point reference:

```matlab
open_system('voice_tx_system');
sim('voice_tx_system');
```

BER vs Eb/N0 sweep:

```matlab
run('scripts/common/run_ber_sweep.m');
```

### Vivado Behavioral Simulation

Create project (first time):

```cmd
call F:\AMDDesignTools\2025.2\Vivado\settings64.bat
cd /d D:\zizim\Documents\UJN_HW\proj2
vivado -mode batch -source vivado\bpsk\create_project.tcl
```

Run simulation — open `vivado/bpsk/bpsk.xpr` in Vivado GUI, then in Tcl Console:

```tcl
source vivado/bpsk/sim_bpsk.tcl
```

## Environment

| Tool | Version | Path |
|------|---------|------|
| MATLAB | R2025b | + HDL Coder, DSP HDL, Communications, Signal Processing, Audio, Fixed-Point Designer |
| Vivado | 2025.2 | `F:\AMDDesignTools\2025.2\Vivado` |
| Target Board | ALINX AX7Z020 | xc7z020-2clg400 (Zynq-7020) |
