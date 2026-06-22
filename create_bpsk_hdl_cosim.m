% create_bpsk_hdl_cosim.m
% Script to build the BPSK HDL co-simulation model
% Creates bpsk_hdl_cosim.slx with HDL-compatible DUT and testbench
%
% DUT: Pure BPSK modem (bits_in -> modulator -> modulated out;
%                        rx_signal -> demodulator -> bits out)
% Target: AMD Xilinx Zynq-7020 (xc7z020-2clg400)
%
% This script documents the model construction. The model is built
% using Simulink agentic toolkit (model_edit) and MATLAB commands.

disp('=== Creating bpsk_hdl_cosim.slx ===');

%% Step 1: Create empty model
new_system('bpsk_hdl_cosim');
open_system('bpsk_hdl_cosim');

set_param('bpsk_hdl_cosim', ...
    'SolverType', 'Fixed-step', ...
    'Solver', 'FixedStepDiscrete', ...
    'FixedStep', '1/64000', ...
    'StopTime', '10000/64000', ...
    'StartTime', '0.0');

%% Step 2: DUT Subsystem (HDL Generation Target)
% Built using model_edit with these operations:
% - SubSystem "DUT" (atomic)
% - Inports: bits_in (uint8), rx_sig_in (fixdt(1,16,14))
% - BPSK_Mod_HDL: Lookup_n-D LUT + pipeline Delay
% - BPSK_Demod_HDL: CompareToZero + DataTypeConversion
% - Outports: tx_mod_out (fixdt(1,16,14)), bits_out (uint8)
%
% LUT configuration:
%   Table data: fi([1; -1], 1, 16, 14)
%   Breakpoints: {uint8([0; 1])}
%   Output type: fixdt(1,16,14)
%   Extrapolation: Clip
%   Interpolation: Flat (nearest)
%
% CompareToZero: operator '<'
% DataTypeConversion (demod): uint8 output

%% Step 3: Testbench (root level)
% - Random Number source (mean=0.5, variance=0.25, Ts=1/64000)
% - Relational Operator (>= 0.5) → boolean bits
% - DataTypeConversion: boolean → uint8 → DUT/bits_in
% - DataTypeConversion: DUT/tx_mod_out (fixdt) → double
% - AWGN Channel (comm.AWGNChannel MATLAB System, Eb/No=10dB)
% - Delay (length=1): breaks algebraic loop
% - DataTypeConversion: double → fixdt(1,16,14) → DUT/rx_sig_in
% - Tx_Scope, Rx_Scope, BER_Display for visualization

%% Step 4: Data type assignments
% DUT port data types are explicitly set:
%   bits_in:    OutDataTypeStr = 'uint8'
%   rx_sig_in:  inherits from Double2FixPt converter
%   tx_mod_out: OutDataTypeStr = 'fixdt(1,16,14)'
%   bits_out:   OutDataTypeStr = 'uint8'
%
% Internal port data types:
%   BPSK_Mod_HDL/bit_in:   'uint8'
%   BPSK_Mod_HDL/sym_out:  'fixdt(1,16,14)'
%   BPSK_Demod_HDL/rx_sym_in: 'fixdt(1,16,14)'
%   BPSK_Demod_HDL/bit_out:   'uint8'

%% Step 5: Save
save_system('bpsk_hdl_cosim');
disp('=== bpsk_hdl_cosim.slx created ===');
disp(' ');
disp('Run config_hdl_bpsk.m to generate HDL code.');
disp('Run verify_bpsk_hdl.m to compare against reference.');
