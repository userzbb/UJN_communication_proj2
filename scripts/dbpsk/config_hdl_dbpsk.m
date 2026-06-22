% config_hdl_dbpsk.m
% HDL Coder configuration and generation for dbpsk_hdl_cosim/DUT
% Target: AMD Xilinx Zynq-7020 (xc7z020-2clg400)
% Output: Verilog HDL
%
% Generated files (in hdl_prj/hdlsrc/dbpsk_hdl_cosim/dbpsk_hdl_cosim/):
%   DUT.v                - Top-level D-BPSK modem
%   DBPSK_Mod_HDL.v      - Differential BPSK modulator (XOR + LUT + pipeline)
%   DBPSK_Demod_HDL.v    - Differential BPSK demodulator (CmpZero + XOR)
%   CmpZero.v            - Sign detection component

disp('=== D-BPSK HDL Code Generation ===');

%% Step 1: Open model
open_system('dbpsk_hdl_cosim');

%% Step 2: Run design check
fprintf('\n--- Running design check ---\n');
checkhdl('dbpsk_hdl_cosim/DUT');

%% Step 3: Generate HDL code
fprintf('\n--- Generating HDL code ---\n');
makehdl('dbpsk_hdl_cosim/DUT', ...
    'TargetDirectory', fullfile(pwd, 'hdl_prj/hdlsrc/dbpsk_hdl_cosim'));

disp('=== D-BPSK HDL code generation complete ===');
disp(['Output: ' fullfile(pwd, 'hdl_prj/hdlsrc/dbpsk_hdl_cosim/dbpsk_hdl_cosim')]);
