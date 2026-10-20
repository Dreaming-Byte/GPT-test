%% 实验5 数字滤波器的应用
clear; close all; clc;

fs = 64;
duration = 8;                   % 较长记录用于减小零相位滤波的边界影响
t = (0:round(duration*fs)-1) / fs;
component_frequencies = [4, 8, 10];
x = cos(2*pi*component_frequencies(1)*t) + ...
    cos(2*pi*component_frequencies(2)*t) + ...
    cos(2*pi*component_frequencies(3)*t);

filter_order = 128;
passband_half_width = 0.5;      % 每个通带为 fc +/- 0.5 Hz
window = hamming(filter_order+1);
filters = cell(1, numel(component_frequencies));
outputs = zeros(numel(component_frequencies), numel(x));

for idx = 1:numel(component_frequencies)
    fc = component_frequencies(idx);
    normalized_band = ([fc-passband_half_width, fc+passband_half_width]) / (fs/2);
    filters{idx} = fir1(filter_order, normalized_band, 'bandpass', window);
    outputs(idx, :) = filtfilt(filters{idx}, 1, x);
end

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

%% 各滤波器的冲激响应、幅度和相位响应
fig1 = figure('Name', '实验5：三个带通滤波器', 'Color', 'w');
for idx = 1:numel(component_frequencies)
    b = filters{idx};
    [H, w] = freqz(b, 1, 4096, fs);
    subplot(3,3,3*(idx-1)+1); stem(0:filter_order, b, 'filled'); grid on;
    title(sprintf('%g Hz 滤波器冲激响应', component_frequencies(idx)));
    xlabel('n'); ylabel('h[n]');
    subplot(3,3,3*(idx-1)+2); plot(w, 20*log10(max(abs(H), 1e-10))); grid on;
    xlim([0, 16]); ylim([-100, 5]); xlabel('频率/Hz'); ylabel('幅度/dB');
    title('幅度响应');
    subplot(3,3,3*(idx-1)+3); plot(w, unwrap(angle(H))); grid on;
    xlim([0, 16]); xlabel('频率/Hz'); ylabel('相位/rad'); title('相位响应');
end
sgtitle('分离 4 Hz、8 Hz、10 Hz 的 FIR 带通滤波器');
saveas(fig1, fullfile(result_dir, 'bandpass_filter_responses.png'));

%% 时域波形（避开记录两端）
display_range = t >= 2 & t < 3;
fig2 = figure('Name', '实验5：滤波结果时域波形', 'Color', 'w');
subplot(4,1,1); plot(t(display_range), x(display_range)); grid on;
title('原始三频组合信号'); xlabel('时间/s'); ylabel('x(t)');
for idx = 1:numel(component_frequencies)
    subplot(4,1,idx+1);
    plot(t(display_range), outputs(idx, display_range), 'LineWidth', 1.1); grid on;
    title(sprintf('滤出的 %g Hz 分量', component_frequencies(idx)));
    xlabel('时间/s'); ylabel('幅度');
end
sgtitle('三个单频分量的时域分离结果');
saveas(fig2, fullfile(result_dir, 'filtered_time_waveforms.png'));

%% 滤波前后频谱
N = numel(x);
frequency = (0:floor(N/2))*fs/N;
fig3 = figure('Name', '实验5：滤波前后频谱', 'Color', 'w');
signals = [x; outputs];
signal_names = {'原始信号', '4 Hz 输出', '8 Hz 输出', '10 Hz 输出'};
for idx = 1:size(signals, 1)
    spectrum = abs(fft(signals(idx, :))) / N;
    one_sided = spectrum(1:floor(N/2)+1);
    one_sided(2:end-1) = 2*one_sided(2:end-1);
    subplot(4,1,idx); plot(frequency, one_sided, 'LineWidth', 1.1); grid on;
    xlim([0, 16]); ylim([0, 1.2]); ylabel('幅度'); title(signal_names{idx});
end
xlabel('频率/Hz'); sgtitle('滤波前后的单边幅度谱');
saveas(fig3, fullfile(result_dir, 'filtered_spectra.png'));

fprintf('实验5完成：已从组合信号中分别提取 4 Hz、8 Hz 和 10 Hz 分量。\n');

