%% 实验2 利用 DFT 分析离散时间信号的频谱
clear; close all; clc;

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

%% 1) x[n] = cos(5*pi*n/16), 0 <= n <= 15：16 点与 32 点 DFT
n = 0:15;
x1 = cos(5*pi*n/16);
nfft_cases = [16, 32];

fig1 = figure('Name', '实验2：有限长余弦序列 DFT', 'Color', 'w');
for idx = 1:numel(nfft_cases)
    nfft = nfft_cases(idx);
    X = fft(x1, nfft);
    omega = 2*pi*(0:nfft-1)/nfft;
    subplot(2,1,idx);
    stem(omega/pi, abs(X), 'filled'); grid on;
    xlabel('归一化频率 \omega/\pi'); ylabel('|X[k]|');
    title(sprintf('x[n]=cos(5\\pi n/16) 的 %d 点 DFT', nfft));
    xlim([0, 2]);
end
sgtitle('固定 16 点数据：补零使频率采样更密');
saveas(fig1, fullfile(result_dir, 'sequence_dft_16_and_32.png'));

%% 2) 三频模拟信号在不同观测长度下的 DFT
fs = 64;
sample_counts = [16, 32, 64];
fig2 = figure('Name', '实验2：三频信号 DFT', 'Color', 'w');
for idx = 1:numel(sample_counts)
    N = sample_counts(idx);
    t = (0:N-1) / fs;
    x2 = cos(8*pi*t) + cos(16*pi*t) + cos(20*pi*t);
    X = fft(x2, N);

    positive_bins = 0:floor(N/2);
    amplitude = abs(X(positive_bins + 1)) / N;
    if N > 2
        amplitude(2:end-1) = 2 * amplitude(2:end-1);
    end
    frequency = positive_bins * fs / N;

    subplot(3,1,idx);
    stem(frequency, amplitude, 'filled'); grid on;
    xlabel('频率/Hz'); ylabel('单边幅度');
    title(sprintf('N=%d，观测时间 %.3f s，\\Deltaf=%.1f Hz', N, N/fs, fs/N));
    xlim([0, fs/2]); ylim([0, 1.4]);
end
sgtitle('4 Hz、8 Hz、10 Hz 三频信号的频率分辨率');
saveas(fig2, fullfile(result_dir, 'three_tone_dft_resolution.png'));

fprintf('实验2完成。三种观测长度对应频率分辨率：%.1f、%.1f、%.1f Hz。\n', ...
    fs ./ sample_counts);

