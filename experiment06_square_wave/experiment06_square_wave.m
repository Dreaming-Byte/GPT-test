%% 实验6 方波信号分解与合成
clear; close all; clc;

%% 参数
fs = 40;                       % 采样频率/Hz
Ts = 1/fs;
T = 2;                         % 方波周期/s
f0 = 1/T;
omega0 = 2*pi*f0;
period_count = 10;
t = 0:Ts:period_count*T-Ts;

% 指导书定义：前半周期为 0.5，后半周期为 -0.5
phase_in_period = mod(t, T);
square_wave = 0.5 * ones(size(t));
square_wave(phase_in_period >= T/2) = -0.5;

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

%% 时域波形和频谱
analysis_sample_count = round(4*T*fs);  % 截取整数个周期以避免频谱泄漏
x_analysis = square_wave(1:analysis_sample_count);
X = fft(x_analysis) / analysis_sample_count;
frequency = (0:floor(analysis_sample_count/2))*fs/analysis_sample_count;
one_sided = abs(X(1:floor(analysis_sample_count/2)+1));
one_sided(2:end-1) = 2*one_sided(2:end-1);

fig1 = figure('Name', '实验6：方波的时域和频谱', 'Color', 'w');
subplot(2,1,1); plot(t(t < 2*T), square_wave(t < 2*T), 'LineWidth', 1.2); grid on;
ylim([-0.7, 0.7]); xlabel('时间/s'); ylabel('x(t)'); title('周期方波时域波形');
subplot(2,1,2); stem(frequency, one_sided, 'filled'); grid on;
xlim([0, 6]); xlabel('频率/Hz'); ylabel('单边幅度');
title('整数周期截取后的幅度谱（仅含奇次谐波）');
saveas(fig1, fullfile(result_dir, 'square_wave_time_and_spectrum.png'));

%% 傅里叶级数合成与吉布斯现象
term_counts = [1, 3, 9, 25];   % 使用的奇次谐波项数
display_range = t < 2*T;
fig2 = figure('Name', '实验6：傅里叶级数合成', 'Color', 'w');
overshoot_percent = zeros(size(term_counts));
for idx = 1:numel(term_counts)
    reconstruction = zeros(size(t));
    for m = 0:term_counts(idx)-1
        harmonic = 2*m + 1;
        reconstruction = reconstruction + (2/pi) * sin(harmonic*omega0*t) / harmonic;
    end
    overshoot_percent(idx) = 100 * max(0, max(abs(reconstruction))-0.5);
    subplot(2,2,idx);
    plot(t(display_range), square_wave(display_range), 'k--', 'LineWidth', 1.0); hold on;
    plot(t(display_range), reconstruction(display_range), 'LineWidth', 1.2); grid on;
    ylim([-0.75, 0.75]); xlabel('时间/s'); ylabel('幅度');
    title(sprintf('%d 个奇次谐波项，过冲 %.2f%%', term_counts(idx), overshoot_percent(idx)));
    legend('理想方波', '级数合成', 'Location', 'best');
end
sgtitle('级数项数对方波合成及吉布斯现象的影响');
saveas(fig2, fullfile(result_dir, 'fourier_series_reconstruction.png'));

%% 中心频率为 k*f0 (k=1,...,5) 的带通滤波分解
harmonic_indices = 1:5;
center_frequencies = harmonic_indices * f0;
filter_order = 200;
half_bandwidth = 0.18;
filtered_components = zeros(numel(center_frequencies), numel(square_wave));
filter_coefficients = cell(size(center_frequencies));

for idx = 1:numel(center_frequencies)
    fc = center_frequencies(idx);
    passband = ([fc-half_bandwidth, fc+half_bandwidth])/(fs/2);
    filter_coefficients{idx} = fir1(filter_order, passband, 'bandpass', hamming(filter_order+1));
    filtered_components(idx, :) = filtfilt(filter_coefficients{idx}, 1, square_wave);
end

fig3 = figure('Name', '实验6：方波滤波分解', 'Color', 'w');
central_range = t >= 4*T & t < 6*T;
for idx = 1:numel(center_frequencies)
    subplot(numel(center_frequencies),1,idx);
    plot(t(central_range), filtered_components(idx, central_range), 'LineWidth', 1.1); grid on;
    ylabel(sprintf('%d f_0', harmonic_indices(idx)));
    title(sprintf('中心频率 %.1f Hz 的带通输出', center_frequencies(idx)));
end
xlabel('时间/s'); sgtitle('方波的逐次带通滤波分解');
saveas(fig3, fullfile(result_dir, 'bandpass_decomposition.png'));

fig4 = figure('Name', '实验6：带通滤波器幅频响应', 'Color', 'w'); hold on;
for idx = 1:numel(filter_coefficients)
    [H, f] = freqz(filter_coefficients{idx}, 1, 4096, fs);
    plot(f, 20*log10(max(abs(H), 1e-10)), 'LineWidth', 1.0);
end
grid on; xlim([0, 4]); ylim([-100, 5]); xlabel('频率/Hz'); ylabel('幅度/dB');
title('中心频率为 f_0 至 5f_0 的带通滤波器');
legend('f_0', '2f_0', '3f_0', '4f_0', '5f_0', 'Location', 'best');
saveas(fig4, fullfile(result_dir, 'bandpass_filter_bank.png'));

fprintf('实验6完成。基频为 %.2f Hz。\n', f0);
for idx = 1:numel(term_counts)
    fprintf('%2d 个奇次谐波项：相对跳变量的最大过冲 %.2f%%。\n', ...
        term_counts(idx), overshoot_percent(idx));
end

