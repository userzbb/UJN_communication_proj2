% config_hdl_bpsk.m
% HDL Coder configuration and generation for bpsk_hdl_cosim/DUT
% Target: AMD Xilinx Zynq-7020 (xc7z020-2clg400)
% Output: Verilog HDL
%
% Generated files (in hdl_prj/hdlsrc/bpsk_hdl_cosim/bpsk_hdl_cosim/):
%   DUT.v              - Top-level BPSK modem
%   BPSK_Mod_HDL.v     - LUT-based BPSK modulator (sfix16_En14)
%   BPSK_Demod_HDL.v   - CompareToZero-based BPSK demodulator
%   CmpZero.v          - Sign detection component

disp('=== BPSK HDL Code Generation ===');

%% Step 1: Open model
open_system('bpsk_hdl_cosim');

%% Step 2: Run design check
fprintf('\n--- Running design check ---\n');
checkhdl('bpsk_hdl_cosim/DUT');

%% Step 3: Generate HDL code
% Note: HDL Coder parameters are set via the model's Configuration Parameters
% (HDL Code Generation pane). Configure target device, clock, and optimization
% settings in the Simulink UI or via hdlset_param on the model.
fprintf('\n--- Generating HDL code ---\n');
makehdl('bpsk_hdl_cosim/DUT', ...
    'TargetDirectory', fullfile(pwd, 'hdl_prj/hdlsrc/bpsk_hdl_cosim'));

%% Step 4: Generate HDL testbench (optional)
% Uncomment to generate testbench:
% makehdltb('bpsk_hdl_cosim/DUT');

disp('=== HDL code generation complete ===');
disp(['Output: ' fullfile(pwd, 'hdl_prj/hdlsrc/bpsk_hdl_cosim/bpsk_hdl_cosim')]);
