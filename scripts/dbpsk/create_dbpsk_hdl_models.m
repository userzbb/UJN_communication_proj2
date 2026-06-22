% create_dbpsk_hdl_models.m
% Create D-BPSK HDL-cosim models (dbpsk_hdl_cosim.slx and voice_tx_hdl_cosim.slx)
% from BPSK templates by inserting differential encoder/decoder (XOR + feedback reg).
%
% D-BPSK algorithm:
%   Encoder: enc[n] = bit[n] XOR enc[n-1]  (init=0)
%   Decoder: bit[n] = enc[n] XOR enc[n-1]
%
% Model structure changes:
%   Mod_HDL:   bit_in → [XOR] → LUT → [Delay?] → sym_out
%   Demod_HDL: rx_sym_in → CmpZero → DTConv → [XOR] → bit_out

proj = 'D:\zizim\Documents\UJN_HW\proj2';
rmpath(fullfile(proj, 'models/bpsk'));

%% Helper: insert differential encoder (XOR + feedback reg) into Mod_HDL
function insert_diff_encoder(ss)
    % Insert XOR between bit_in and LUT. Works for both DUT path
    % (bit_in→LUT→Delay→sym_out) and main path (bit_in→LUT→sym_out).

    % Delete line from bit_in to LUT (always the first connection)
    ph_in = get_param([ss '/bit_in'], 'PortHandles');
    ln = get_param(ph_in.Outport(1), 'Line');
    if ln ~= -1, delete_line(ln); end

    % Add XOR + feedback reg
    add_block('simulink/Logic and Bit Operations/Logical Operator', ...
        [ss '/Diff_Enc_XOR'], 'Operator', 'XOR', ...
        'Position', [80, 35, 115, 65]);
    add_block('simulink/Discrete/Unit Delay', ...
        [ss '/Diff_Enc_Reg'], 'InitialCondition', '0', ...
        'SampleTime', '-1', 'Position', [80, 95, 115, 125]);

    ph_xor = get_param([ss '/Diff_Enc_XOR'], 'PortHandles');
    ph_reg = get_param([ss '/Diff_Enc_Reg'], 'PortHandles');
    ph_lut = get_param([ss '/LUT'], 'PortHandles');

    add_line(ss, ph_in.Outport(1), ph_xor.Inport(1), 'autorouting', 'on');
    add_line(ss, ph_xor.Outport(1), ph_lut.Inport(1), 'autorouting', 'on');
    add_line(ss, ph_xor.Outport(1), ph_reg.Inport(1), 'autorouting', 'on');
    add_line(ss, ph_reg.Outport(1), ph_xor.Inport(2), 'autorouting', 'on');

    set_param(ss, 'Name', 'DBPSK_Mod_HDL');
end

%% Helper: insert differential decoder (XOR + feedback reg) into Demod_HDL
function insert_diff_decoder(ss)
    % Insert XOR between DTConv and bit_out.
    dtcs = find_system(ss, 'SearchDepth', 1, 'BlockType', 'DataTypeConversion');
    ph_dtc = get_param(dtcs{1}, 'PortHandles');
    ln = get_param(ph_dtc.Outport(1), 'Line');
    if ln ~= -1, delete_line(ln); end

    add_block('simulink/Logic and Bit Operations/Logical Operator', ...
        [ss '/Diff_Dec_XOR'], 'Operator', 'XOR', ...
        'Position', [320, 35, 355, 65]);
    add_block('simulink/Discrete/Unit Delay', ...
        [ss '/Diff_Dec_Reg'], 'InitialCondition', '0', ...
        'SampleTime', '-1', 'Position', [320, 95, 355, 125]);

    ph_xor = get_param([ss '/Diff_Dec_XOR'], 'PortHandles');
    ph_reg = get_param([ss '/Diff_Dec_Reg'], 'PortHandles');
    ph_out = get_param([ss '/bit_out'], 'PortHandles');

    add_line(ss, ph_dtc.Outport(1), ph_xor.Inport(1), 'autorouting', 'on');
    add_line(ss, ph_xor.Outport(1), ph_out.Inport(1), 'autorouting', 'on');
    add_line(ss, ph_xor.Outport(1), ph_reg.Inport(1), 'autorouting', 'on');
    add_line(ss, ph_reg.Outport(1), ph_xor.Inport(2), 'autorouting', 'on');

    set_param(ss, 'Name', 'DBPSK_Demod_HDL');
end

%% Model 1: dbpsk_hdl_cosim (BER testbench)
fprintf('=== [1/2] D-BPSK BER testbench ===\n');
delete(fullfile(proj, 'models/dbpsk/dbpsk_hdl_cosim.slx'));
copyfile(fullfile(proj, 'models/bpsk/bpsk_hdl_cosim.slx'), ...
         fullfile(proj, 'models/dbpsk/dbpsk_hdl_cosim.slx'));
cd(fullfile(proj, 'models/dbpsk'));
load_system('dbpsk_hdl_cosim');

try
    insert_diff_encoder('dbpsk_hdl_cosim/DUT/BPSK_Mod_HDL');
    fprintf('  -> DBPSK_Mod_HDL OK\n');
catch e
    fprintf(2, '  ERROR Mod: %s\n', e.message);
end
try
    insert_diff_decoder('dbpsk_hdl_cosim/DUT/BPSK_Demod_HDL');
    fprintf('  -> DBPSK_Demod_HDL OK\n');
catch e
    fprintf(2, '  ERROR Demod: %s\n', e.message);
end
save_system('dbpsk_hdl_cosim');
close_system('dbpsk_hdl_cosim');
fprintf('  Model 1 saved.\n\n');

%% Model 2: voice_tx_hdl_cosim (audio with HDL-cosim)
fprintf('=== [2/2] D-BPSK HDL-cosim audio ===\n');
delete(fullfile(proj, 'models/dbpsk/voice_tx_hdl_cosim.slx'));
copyfile(fullfile(proj, 'models/bpsk/voice_tx_hdl_cosim.slx'), ...
         fullfile(proj, 'models/dbpsk/voice_tx_hdl_cosim.slx'));
cd(fullfile(proj, 'models/dbpsk'));
load_system('voice_tx_hdl_cosim');

mods = find_system('voice_tx_hdl_cosim', 'Name', 'BPSK_Mod_HDL');
for i = 1:length(mods)
    try
        insert_diff_encoder(mods{i});
        fprintf('  -> DBPSK_Mod_HDL: %s\n', strrep(mods{i}, sprintf('\n'), '\\n'));
    catch e
        fprintf(2, '  ERROR: %s\n', e.message);
    end
end

demods = find_system('voice_tx_hdl_cosim', 'Name', 'BPSK_Demod_HDL');
for i = 1:length(demods)
    try
        insert_diff_decoder(demods{i});
        fprintf('  -> DBPSK_Demod_HDL: %s\n', strrep(demods{i}, sprintf('\n'), '\\n'));
    catch e
        fprintf(2, '  ERROR: %s\n', e.message);
    end
end

save_system('voice_tx_hdl_cosim');
close_system('voice_tx_hdl_cosim');
fprintf('  Model 2 saved.\n\n');
fprintf('=== All D-BPSK HDL models ready. ===\n');
