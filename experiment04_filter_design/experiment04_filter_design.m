%% 实验4 基于 MATLAB 的数字滤波器设计
clear; close all; clc;

%% 指导书给定指标（频率均相对 Nyquist 频率归一化）
Wp = [0.45, 0.65];
Ws = [0.30, 0.75];
Rp = 1;                 % 通带峰值起伏/dB
Rs = 40;                % 最小阻带衰减/dB

%% IIR Butterworth 设计
[iir_half_order, Wn_iir] = buttord(Wp, Ws, Rp, Rs);
[b_iir, a_iir] = butter(iir_half_order, Wn_iir, 'bandpass');
[sos_iir, gain_iir] = tf2sos(b_iir, a_iir);

%% FIR Kaiser 窗设计
passband_deviation = (10^(Rp/20)-1) / (10^(Rp/20)+1);
stopband_deviation = 10^(-Rs/20);
deviations = [stopband_deviation, passband_deviation, stopband_deviation];
[fir_order, Wn_fir, beta, fir_type] = kaiserord( ...
    [Ws(1), Wp(1), Wp(2), Ws(2)], [0, 1, 0], deviations, 2);
fir_order = fir_order + mod(fir_order, 2);  % 偶数阶 Type-I 线性相位 FIR
b_fir = fir1(fir_order, Wn_fir, fir_type, kaiser(fir_order+1, beta), 'noscale');
a_fir = 1;

%% 频率响应和指标测量
n_frequency_points = 8192;
[H_iir, w] = freqz(b_iir, a_iir, n_frequency_points);
H_fir = freqz(b_fir, a_fir, n_frequency_points);
normalized_frequency = w/pi;
mag_iir_db = 20*log10(max(abs(H_iir), 1e-12));
mag_fir_db = 20*log10(max(abs(H_fir), 1e-12));

passband = normalized_frequency >= Wp(1) & normalized_frequency <= Wp(2);
stopband = normalized_frequency <= Ws(1) | normalized_frequency >= Ws(2);
iir_ripple = max(mag_iir_db(passband)) - min(mag_iir_db(passband));
fir_ripple = max(mag_fir_db(passband)) - min(mag_fir_db(passband));
iir_stop_attenuation = -max(mag_iir_db(stopband));
fir_stop_attenuation = -max(mag_fir_db(stopband));

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

%% 冲激响应、幅度和相位频响
impulse_length = max(160, fir_order+1);
[h_iir, n_iir] = impz(b_iir, a_iir, impulse_length);
[h_fir, n_fir] = impz(b_fir, a_fir, fir_order+1);

fig1 = figure('Name', '实验4：IIR 与 FIR 带通滤波器', 'Color', 'w');
subplot(2,2,1); stem(n_iir, h_iir, 'filled'); grid on;
title(sprintf('IIR 冲激响应（实际阶数 %d）', length(a_iir)-1)); xlabel('n'); ylabel('h_I_I_R[n]');
subplot(2,2,2); stem(n_fir, h_fir, 'filled'); grid on;
title(sprintf('FIR 冲激响应（阶数 %d）', fir_order)); xlabel('n'); ylabel('h_F_I_R[n]');
subplot(2,2,3); plot(normalized_frequency, mag_iir_db, 'LineWidth', 1.2); hold on;
plot(normalized_frequency, mag_fir_db, '--', 'LineWidth', 1.2); grid on;
yline(-Rp, 'k:'); yline(-Rs, 'k:'); xline(Wp(1), 'k:'); xline(Wp(2), 'k:');
xline(Ws(1), 'k:'); xline(Ws(2), 'k:'); ylim([-100, 5]); xlim([0, 1]);
title('幅度响应'); xlabel('归一化频率 \omega/\pi'); ylabel('幅度/dB');
legend('IIR Butterworth', 'FIR Kaiser', 'Location', 'south');
subplot(2,2,4); plot(normalized_frequency, unwrap(angle(H_iir)), 'LineWidth', 1.1); hold on;
plot(normalized_frequency, unwrap(angle(H_fir)), '--', 'LineWidth', 1.1); grid on;
title('展开相位响应'); xlabel('归一化频率 \omega/\pi'); ylabel('相位/rad');
legend('IIR Butterworth', 'FIR Kaiser', 'Location', 'best');
sgtitle('数字带通滤波器设计');
saveas(fig1, fullfile(result_dir, 'filter_responses.png'));

%% 零极点分布
fig2 = figure('Name', '实验4：零极点分布', 'Color', 'w');
subplot(1,2,1); zplane(b_iir, a_iir); title('IIR 零极点图');
subplot(1,2,2); zplane(b_fir, a_fir); title('FIR 零极点图');
saveas(fig2, fullfile(result_dir, 'pole_zero_plots.png'));

%% 实现结构示意图
fig3 = figure('Name', '实验4：实现结构', 'Color', 'w');
subplot(2,1,1); draw_iir_sos_structure(sos_iir, gain_iir);
subplot(2,1,2); draw_fir_structure(fir_order);
saveas(fig3, fullfile(result_dir, 'implementation_structures.png'));

save(fullfile(result_dir, 'filter_coefficients.mat'), ...
    'b_iir', 'a_iir', 'sos_iir', 'gain_iir', 'b_fir', 'a_fir');

fprintf('IIR：实际阶数 %d，通带起伏 %.3f dB，阻带衰减 %.2f dB。\n', ...
    length(a_iir)-1, iir_ripple, iir_stop_attenuation);
fprintf('FIR：阶数 %d，通带起伏 %.3f dB，阻带衰减 %.2f dB。\n', ...
    fir_order, fir_ripple, fir_stop_attenuation);

function draw_iir_sos_structure(sos, gain_value)
    cla; axis([0, 10, 0, 2]); axis off; hold on;
    section_count = size(sos, 1);
    text(0.2, 1, 'x[n]', 'FontSize', 11, 'HorizontalAlignment', 'center');
    plot([0.5, 1.1], [1, 1], 'k-', 'LineWidth', 1.2);
    rectangle('Position', [1.1, 0.65, 1.0, 0.7]);
    text(1.6, 1, sprintf('g=%.3g', gain_value), 'HorizontalAlignment', 'center');
    x_previous = 2.1;
    shown_sections = min(section_count, 4);
    for section = 1:shown_sections
        x_left = 2.3 + (section-1)*1.65;
        plot([x_previous, x_left], [1, 1], 'k-', 'LineWidth', 1.2);
        rectangle('Position', [x_left, 0.55, 1.35, 0.9]);
        text(x_left+0.675, 1.12, sprintf('SOS %d', section), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
        text(x_left+0.675, 0.82, '二阶直接型 II', 'HorizontalAlignment', 'center', 'FontSize', 8);
        x_previous = x_left + 1.35;
    end
    if section_count > shown_sections
        text(x_previous+0.4, 1, sprintf('... 共 %d 节', section_count), 'FontSize', 10);
        x_previous = x_previous + 1.4;
    end
    plot([x_previous, min(9.5, x_previous+0.6)], [1, 1], 'k-', 'LineWidth', 1.2);
    text(min(9.7, x_previous+0.9), 1, 'y[n]', 'FontSize', 11);
    title('IIR 推荐实现：增益与二阶节级联');
end

function draw_fir_structure(order)
    cla; axis([0, 10, 0, 3]); axis off; hold on;
    plot([0.6, 9.2], [2.2, 2.2], 'k-', 'LineWidth', 1.2);
    text(0.25, 2.2, 'x[n]', 'FontSize', 11);
    block_x = [2.0, 4.0, 6.0];
    labels = {'z^{-1}', 'z^{-1}', '... z^{-1}'};
    taps = {'b_0', 'b_1', 'b_N'};
    for idx = 1:numel(block_x)
        rectangle('Position', [block_x(idx), 1.9, 1.0, 0.6]);
        text(block_x(idx)+0.5, 2.2, labels{idx}, 'HorizontalAlignment', 'center');
        plot([block_x(idx)+0.5, block_x(idx)+0.5], [1.9, 1.15], 'k-');
        text(block_x(idx)+0.5, 0.95, taps{idx}, 'HorizontalAlignment', 'center');
        plot([block_x(idx)+0.5, 8.2], [0.75, 0.75], 'k-');
    end
    text(8.3, 0.75, '\Sigma', 'FontSize', 18, 'HorizontalAlignment', 'center');
    plot([8.55, 9.2], [0.75, 0.75], 'k-');
    text(9.55, 0.75, 'y[n]', 'FontSize', 11);
    title(sprintf('FIR 直接型抽头延迟线（N=%d，系数关于中心对称）', order));
end

