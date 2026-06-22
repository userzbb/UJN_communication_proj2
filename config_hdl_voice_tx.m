% config_hdl_voice_tx.m
% HDL Coder configuration and generation for voice_tx_hdl_cosim/DUT
% Target: AMD Xilinx Zynq-7020 (xc7z020-2clg400)
% Output: Verilog HDL
%
% Generated files (in hdl_prj/hdlsrc/voice_tx_hdl_cosim/voice_tx_hdl_cosim/):
%   DUT.v              - Top-level BPSK modem
%   BPSK_Mod_HDL.v     - LUT-based BPSK modulator (sfix16_En14) with pipeline
%   BPSK_Demod_HDL.v   - CompareToZero-based BPSK demodulator
%   CmpZero.v          - Sign detection component

disp('=== Voice Tx HDL Code Generation ===');

%% Step 1: Open model
open_system('voice_tx_hdl_cosim');

%% Step 2: Run design check
fprintf('\n--- Running design check ---\n');
checkhdl('voice_tx_hdl_cosim/DUT');

%% Step 3: Generate HDL code
fprintf('\n--- Generating HDL code ---\n');
makehdl('voice_tx_hdl_cosim/DUT', ...
    'TargetDirectory', fullfile(pwd, 'hdl_prj/hdlsrc/voice_tx_hdl_cosim'));

%% Step 4: Generate HDL testbench (optional)
% Uncomment to generate testbench:
% makehdltb('voice_tx_hdl_cosim/DUT');

disp('=== HDL code generation complete ===');
disp(['Output: ' fullfile(pwd, 'hdl_prj/hdlsrc/voice_tx_hdl_cosim/voice_tx_hdl_cosim')]);
