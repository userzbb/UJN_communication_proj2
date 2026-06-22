% alinx_ax7z020.m
% Custom board registration for ALINX AX7Z020
% FPGA: Xilinx Zynq-7020 (xc7z020-2clg400)
%
% Usage:
%   board = alinx_ax7z020;
%   hdlcoder.Board.register(board);

function board = alinx_ax7z020
    board = hdlcoder.Board;
    board.BoardName = 'ALINX AX7Z020';
    board.FPGAVendor = 'Xilinx';
    board.FPGAFamily = 'Zynq';
    board.FPGADevice = 'xc7z020';
    board.FPGAPackage = 'clg400';
    board.FPGASpeed = '-2';

    % JTAG chain - adjust based on board configuration
    % The AX7Z020 typically has a single device in the JTAG chain
    board.JTAGChainPosition = 1;

    % Clock settings - AX7Z020 has a 50 MHz oscillator on PS_CLK
    % The FPGA logic can be clocked from the PL fabric clock
    % board.FPGAClockFrequency = 50;  % MHz (if using PS clock)

    % Interface - JTAG is the standard programming interface
    % board.Interface = 'JTAG';
end
