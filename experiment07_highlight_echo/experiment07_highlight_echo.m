%% 实验7 基于亮点模型的目标回波信号分析
clear; close all; clc;

%% 发射信号参数
fs = 500e3;
T = 0.5e-3;
sample_count = round(T*fs);
n = 0:sample_count-1;
t = n/fs;

cw_frequency = 30e3;
cw = cos(2*pi*cw_frequency*t);

lfm_start_frequency = 20e3;
lfm_bandwidth = 20e3;
chirp_rate = lfm_bandwidth/T;
lfm = cos(2*pi*lfm_start_frequency*t + pi*chirp_rate*t.^2);

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

%% CW 和 LFM 的波形与频谱
fig1 = figure('Name', '实验7：发射信号', 'Color', 'w');
subplot(2,2,1); plot(t*1e3, cw); grid on;
xlabel('时间/ms'); ylabel('幅度'); title('CW 脉冲波形（30 kHz）');
subplot(2,2,2); plot(t*1e3, lfm); grid on;
xlabel('时间/ms'); ylabel('幅度'); title('LFM 脉冲波形（20–40 kHz）');
[f_cw, S_cw] = normalized_spectrum(cw, fs);
[f_lfm, S_lfm] = normalized_spectrum(lfm, fs);
subplot(2,2,3); plot(f_cw/1e3, S_cw, 'LineWidth', 1.1); grid on;
xlim([0, 80]); xlabel('频率/kHz'); ylabel('归一化幅度'); title('CW 频谱');
subplot(2,2,4); plot(f_lfm/1e3, S_lfm, 'LineWidth', 1.1); grid on;
xlim([0, 80]); xlabel('频率/kHz'); ylabel('归一化幅度'); title('LFM 频谱');
sgtitle('两种发射脉冲');
saveas(fig1, fullfile(result_dir, 'transmitted_signals.png'));

%% 两个角度的几何亮点回波
angle1_amplitudes = [1, 0.65];
angle1_delays = [0, 150];
angle2_amplitudes = [1, 0.75, 0.4];
angle2_delays = [0, 100, 650];

cw_angle1 = geometric_echo(cw, angle1_amplitudes, angle1_delays);
lfm_angle1 = geometric_echo(lfm, angle1_amplitudes, angle1_delays);
cw_angle2 = geometric_echo(cw, angle2_amplitudes, angle2_delays);
lfm_angle2 = geometric_echo(lfm, angle2_amplitudes, angle2_delays);

plot_echo_comparison(cw_angle1, lfm_angle1, fs, '角度1：2个几何亮点', ...
    fullfile(result_dir, 'angle1_echoes.png'));
plot_echo_comparison(cw_angle2, lfm_angle2, fs, '角度2：3个几何亮点', ...
    fullfile(result_dir, 'angle2_echoes.png'));

%% 选作：2 个几何亮点 + 2 个弹性亮点的 LFM 回波
optional_geometry_amplitudes = [1, 0.7];
optional_geometry_delays = [0, 175];
elastic_amplitudes = [0.35, 0.2];
elastic_delays = [500, 750];
elastic_center_frequencies = [34e3, 37e3];
elastic_frequency_sigmas = [3e3, 2e3];

optional_echo = geometric_echo(lfm, optional_geometry_amplitudes, optional_geometry_delays);
required_length = numel(lfm) + max(elastic_delays);
optional_echo(end+1:required_length) = 0;
for idx = 1:numel(elastic_amplitudes)
    shaped_echo = gaussian_band_echo(lfm, fs, elastic_center_frequencies(idx), ...
        elastic_frequency_sigmas(idx));
    delayed = delay_signal(shaped_echo, elastic_delays(idx), required_length);
    optional_echo = optional_echo + elastic_amplitudes(idx)*delayed;
end

fig4 = figure('Name', '实验7：几何与弹性亮点', 'Color', 'w');
echo_time = (0:numel(optional_echo)-1)/fs;
subplot(2,1,1); plot(echo_time*1e3, optional_echo); grid on;
xlabel('时间/ms'); ylabel('幅度'); title('LFM 条件下 2 个几何 + 2 个弹性亮点回波');
[f_optional, S_optional] = normalized_spectrum(optional_echo, fs);
subplot(2,1,2); plot(f_optional/1e3, S_optional, 'LineWidth', 1.1); grid on;
xlim([0, 80]); xlabel('频率/kHz'); ylabel('归一化幅度');
title('混合亮点回波频谱（弹性散射在中高频局部增强）');
saveas(fig4, fullfile(result_dir, 'optional_elastic_echo.png'));

fprintf('实验7完成。CW/LFM 脉冲均为 %d 点（%.3f ms）。\n', sample_count, T*1e3);
fprintf('角度1回波长度 %d 点；角度2回波长度 %d 点。\n', ...
    numel(cw_angle1), numel(cw_angle2));
fprintf('选作混合亮点回波长度 %d 点。\n', numel(optional_echo));

function echo = geometric_echo(signal, amplitudes, delays)
    assert(numel(amplitudes) == numel(delays), '亮点幅度和时延数量必须一致。');
    output_length = numel(signal) + max(delays);
    echo = zeros(1, output_length);
    for index = 1:numel(amplitudes)
        echo = echo + amplitudes(index)*delay_signal(signal, delays(index), output_length);
    end
end

function output = delay_signal(signal, delay_samples, output_length)
    assert(delay_samples >= 0 && fix(delay_samples) == delay_samples, '时延必须为非负整数点。');
    output = zeros(1, output_length);
    last_index = min(output_length, delay_samples + numel(signal));
    copied_count = last_index - delay_samples;
    if copied_count > 0
        output(delay_samples+1:last_index) = signal(1:copied_count);
    end
end

function shaped = gaussian_band_echo(signal, sampling_frequency, center_frequency, sigma_frequency)
    transform_length = 2^nextpow2(max(1024, 4*numel(signal)));
    frequency = (0:transform_length-1)*sampling_frequency/transform_length;
    signed_frequency = frequency;
    signed_frequency(frequency > sampling_frequency/2) = ...
        frequency(frequency > sampling_frequency/2)-sampling_frequency;
    gaussian_envelope = exp(-((abs(signed_frequency)-center_frequency).^2) / ...
        (2*sigma_frequency^2));
    shaped_full = real(ifft(fft(signal, transform_length).*gaussian_envelope));
    shaped = shaped_full(1:numel(signal));
    peak = max(abs(shaped));
    if peak > 0, shaped = shaped/peak; end
end

function [frequency, magnitude] = normalized_spectrum(signal, sampling_frequency)
    transform_length = 2^nextpow2(max(4096, 4*numel(signal)));
    spectrum = fft(signal, transform_length);
    frequency = (0:floor(transform_length/2))*sampling_frequency/transform_length;
    magnitude = abs(spectrum(1:floor(transform_length/2)+1));
    peak = max(magnitude);
    if peak > 0, magnitude = magnitude/peak; end
end

function plot_echo_comparison(cw_echo, lfm_echo, sampling_frequency, figure_title, file_name)
    fig = figure('Name', figure_title, 'Color', 'w');
    cw_time = (0:numel(cw_echo)-1)/sampling_frequency;
    lfm_time = (0:numel(lfm_echo)-1)/sampling_frequency;
    subplot(2,2,1); plot(cw_time*1e3, cw_echo); grid on;
    xlabel('时间/ms'); ylabel('幅度'); title('CW 回波时域波形');
    subplot(2,2,2); plot(lfm_time*1e3, lfm_echo); grid on;
    xlabel('时间/ms'); ylabel('幅度'); title('LFM 回波时域波形');
    [f_cw, S_cw] = normalized_spectrum(cw_echo, sampling_frequency);
    [f_lfm, S_lfm] = normalized_spectrum(lfm_echo, sampling_frequency);
    subplot(2,2,3); plot(f_cw/1e3, S_cw, 'LineWidth', 1.1); grid on;
    xlim([0, 80]); xlabel('频率/kHz'); ylabel('归一化幅度'); title('CW 回波频谱');
    subplot(2,2,4); plot(f_lfm/1e3, S_lfm, 'LineWidth', 1.1); grid on;
    xlim([0, 80]); xlabel('频率/kHz'); ylabel('归一化幅度'); title('LFM 回波频谱');
    sgtitle(figure_title);
    saveas(fig, file_name);
end
