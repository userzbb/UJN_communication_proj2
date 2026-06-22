% BER vs Eb/N0 sweep for voice_tx_system
% BPSK over AWGN with RRC pulse shaping

EbN0_dB_vec = 0:2:10;
numBits = 8000 * 8;  % 1 second of audio, 8 bits per sample
ber_results = zeros(size(EbN0_dB_vec));

% Load model and set simulation mode
load_system('voice_tx_system');

% Disable audio file I/O during BER test - use random test bits instead
% For now, sweep Eb/N0 on the AWGN channel and measure audio quality

snr_audio = zeros(size(EbN0_dB_vec));
mse_audio = zeros(size(EbN0_dB_vec));
corr_audio = zeros(size(EbN0_dB_vec));

% Audio reference
[orig_audio, ~] = audioread('audio/voice_input.wav');
test_len = 8000;  % 1 second

fprintf('=== BER / Audio Quality Sweep ===\n');
fprintf('Eb/N0 (dB) | SNR (dB) | MSE       | Correlation\n');
fprintf('----------------------------------------------\n');

for i = 1:length(EbN0_dB_vec)
    % Set AWGN Eb/N0
    set_param('voice_tx_system/AWGN\nChannel', 'EbNo', num2str(EbN0_dB_vec(i)));

    % Run simulation
    simOut = sim('voice_tx_system', 'StopTime', '1');

    % Read output
    if exist('voice_output.wav', 'file')
        [recon, ~] = audioread('voice_output.wav');

        % Find delay via cross-correlation
        min_len = min(test_len, length(recon));
        [c, lags] = xcorr(orig_audio(1:min_len), recon(1:min_len), 50, 'coeff');
        [~, idx] = max(abs(c));
        delay = lags(idx);

        % Align
        if delay > 0
            oa = orig_audio(1+delay:min_len);
            ra = recon(1:min_len-delay);
        elseif delay < 0
            oa = orig_audio(1:min_len+delay);
            ra = recon(1-delay:min_len);
        else
            oa = orig_audio(1:min_len);
            ra = recon(1:min_len);
        end

        mse_val = mean((oa - ra).^2);
        sig_power = mean(oa.^2);
        snr_val = 10*log10(sig_power / mse_val);
        corr_val = corr(oa, ra);

        snr_audio(i) = snr_val;
        mse_audio(i) = mse_val;
        corr_audio(i) = corr_val;

        fprintf('  %5.0f dB   |  %6.2f dB | %.6f  | %.4f\n', ...
            EbN0_dB_vec(i), snr_val, mse_val, corr_val);
    end
end

fprintf('----------------------------------------------\n');

% Plot results
figure('Position', [100, 100, 900, 400]);

subplot(1, 2, 1);
plot(EbN0_dB_vec, snr_audio, 'b-o', 'LineWidth', 2);
xlabel('Eb/N0 (dB)');
ylabel('Reconstructed SNR (dB)');
title('Audio SNR vs Eb/N0');
grid on;

subplot(1, 2, 2);
plot(EbN0_dB_vec, corr_audio, 'r-o', 'LineWidth', 2);
xlabel('Eb/N0 (dB)');
ylabel('Correlation');
title('Audio Correlation vs Eb/N0');
grid on;
ylim([0, 1.05]);

sgtitle('Voice Transmission Quality over AWGN Channel');

% Save results
save('data/ber_results.mat', 'EbN0_dB_vec', 'snr_audio', 'mse_audio', 'corr_audio');
fprintf('\nResults saved to data/ber_results.mat\n');
