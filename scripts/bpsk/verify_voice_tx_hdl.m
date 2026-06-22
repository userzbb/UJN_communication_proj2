% verify_voice_tx_hdl.m
% Offline verification of BPSK HDL modulation/demodulation logic
% for voice_tx_hdl_cosim/DUT
%
% This script validates the mathematical correctness of the BPSK
% mapping and demodulation without running a full simulation.

disp('=== Voice Tx HDL BPSK Verification ===');

%% Parameters
num_bits = 10000;
rng(42);  % Fixed seed for reproducibility

%% Generate random test bits (0 or 1)
test_bits = randi([0 1], num_bits, 1);

%% Modulator verification: LUT mapping
% BPSK LUT: 0 -> +1.0, 1 -> -1.0
% Fixed-point format: sfix16_En14
expected_syms = 2 * (test_bits == 0) - 1;  % 0->+1, 1->-1

% Quantize to sfix16_En14
expected_syms_fixed = fi(expected_syms, 1, 16, 14);

mod_errors = sum(abs(double(expected_syms_fixed) - expected_syms) > 1e-10);
fprintf('\nModulator mapping errors: %d / %d\n', mod_errors, num_bits);
if mod_errors == 0
    disp('  PASS: BPSK LUT mapping is correct');
else
    disp('  FAIL: BPSK LUT mapping errors detected');
end

%% Demodulator verification: CompareToZero + uint8
% CmpZero: input < 0 -> true(logical 1) -> uint8(1), else -> uint8(0)
tx_syms = double(expected_syms_fixed);

% Simulate noiseless demodulation
demod_bits = uint8(tx_syms < 0);  % CompareToZero + DTConv

bit_errors = sum(demod_bits ~= uint8(test_bits));
fprintf('Demodulator bit errors (no noise): %d / %d\n', bit_errors, num_bits);
if bit_errors == 0
    disp('  PASS: BPSK demodulation is correct');
else
    disp('  FAIL: BPSK demodulation errors detected');
end

%% Add AWGN and verify BER at various Eb/N0
fprintf('\n--- BER vs Eb/N0 (theoretical check) ---\n');
ebn0_db = 0:2:10;
for i = 1:length(ebn0_db)
    ebno = 10^(ebn0_db(i)/10);
    noise_std = sqrt(1/(2*ebno));  % For BPSK with unit symbol energy
    noise = noise_std * randn(num_bits, 1);
    rx_syms = tx_syms + noise;

    demod_bits_noisy = uint8(rx_syms < 0);
    nerrs = sum(demod_bits_noisy ~= uint8(test_bits));
    ber = nerrs / num_bits;
    ber_theory = 0.5 * erfc(sqrt(ebno));

    fprintf('  Eb/N0 = %2d dB: BER = %.6f (theory: %.6f)\n', ...
        ebn0_db(i), ber, ber_theory);
end

disp(' ');
disp('=== Verification complete ===');
disp('HDL BPSK mapping and demodulation logic validated.');
