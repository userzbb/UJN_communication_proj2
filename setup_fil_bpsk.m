% setup_fil_bpsk.m
% FPGA-in-the-Loop (FIL) workflow setup for bpsk_hdl_cosim/DUT
% Requires: Vivado installed, HDL Verifier, board connected via JTAG
%
% Prerequisites:
%   1. Run config_hdl_bpsk.m first to generate Verilog HDL
%   2. Vivado must be installed and accessible
%   3. ALINX AX7Z020 board connected via JTAG

disp('=== BPSK FPGA-in-the-Loop Setup ===');

%% Step 1: Register Vivado tool path
% Uncomment and adjust path:
% hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
%     'ToolPath', 'C:\Xilinx\Vivado\2024.1\bin\vivado.bat');

%% Step 2: Register custom board (if needed)
% Uncomment if board not in standard list:
% board = alinx_ax7z020;
% hdlcoder.Board.register(board);

%% Step 3: Open FIL wizard (interactive)
% This opens the FIL wizard GUI to configure:
%   - DUT selection: bpsk_hdl_cosim/DUT
%   - Board selection: ALINX AX7Z020 or ZC702
%   - JTAG clock frequency
%   - Output folder for FIL block
%
% filWizard('bpsk_hdl_cosim/DUT');

%% Step 4: Programmatic FIL setup (alternative to wizard)
% Uncomment to use programmatic setup:
%
% hfil = fil('bpsk_hdl_cosim', 'DUT');
%
% % Generate FIL block
% fil('generate', hfil, ...
%     'BoardName', 'ALINX AX7Z020', ...
%     'Interface', 'JTAG', ...
%     'EnableUserConfigure', 'on');
%
% disp('FIL block generated. Use this block in your model for co-simulation.');

disp('=== FIL setup script ready ===');
disp('Install Vivado and connect board to run FIL co-simulation.');
