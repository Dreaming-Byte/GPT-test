%% 实验1 常见离散时间信号的产生和图形显示
clear; close all; clc;

%% 参数（可按实验要求修改）
N = 32;                 % 序列长度
k = 5;                  % 单位抽样的延迟
A = 1;                  % 正弦幅度
f0 = 5;                 % 正弦频率/Hz
fs = 64;                % 采样频率/Hz
phi = pi/6;             % 初相位/rad
omega = pi/4;           % 复正弦数字角频率/rad/sample
a = 0.9;                % 指数序列底数

assert(N >= 1 && fix(N) == N, 'N 必须是正整数。');
assert(k >= 0 && k < N && fix(k) == k, 'k 必须是 0 到 N-1 之间的整数。');

n = 0:N-1;
impulse = zeros(1, N);
impulse(k + 1) = 1;     % MATLAB 下标从 1 开始
step_sequence = ones(1, N);
sine_sequence = A * sin(2*pi*f0*n/fs + phi);
complex_sine = exp(1j * omega * n);
exponential_sequence = a .^ n;

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

fig1 = figure('Name', '实验1：五种离散时间信号', 'Color', 'w');
subplot(3,2,1); stem(n, impulse, 'filled'); grid on;
title(sprintf('单位抽样序列 \\delta[n-%d]', k)); xlabel('n'); ylabel('幅度');
subplot(3,2,2); stem(n, step_sequence, 'filled'); grid on;
title('单位阶跃序列 u[n]'); xlabel('n'); ylabel('幅度');
subplot(3,2,3); stem(n, sine_sequence, 'filled'); grid on;
title(sprintf('正弦序列：f_0=%g Hz, f_s=%g Hz', f0, fs)); xlabel('n'); ylabel('幅度');
subplot(3,2,4); stem(n, real(complex_sine), 'filled'); hold on;
stem(n, imag(complex_sine), 'r.'); grid on;
title(sprintf('复正弦序列：\\omega=%.2f\\pi', omega/pi));
xlabel('n'); ylabel('幅度'); legend('实部', '虚部', 'Location', 'best');
subplot(3,2,5); stem(n, exponential_sequence, 'filled'); grid on;
title(sprintf('指数序列：a=%.2f', a)); xlabel('n'); ylabel('幅度');
subplot(3,2,6); axis off;
text(0, 0.8, sprintf('长度 N = %d', N), 'FontSize', 11);
text(0, 0.6, sprintf('归一化频率 f_0/f_s = %.4f', f0/fs), 'FontSize', 11);
text(0, 0.4, '复正弦模值恒为 1', 'FontSize', 11);
sgtitle('常见离散时间信号');
saveas(fig1, fullfile(result_dir, 'five_discrete_signals.png'));

%% 改变 f0 和 fs，观察离散频率与混叠
frequency_cases = [5, 27, 37];
sampling_cases = [64, 32, 16];
fig2 = figure('Name', '实验1：频率参数的影响', 'Color', 'w');
for idx = 1:numel(frequency_cases)
    current_f0 = frequency_cases(idx);
    x = sin(2*pi*current_f0*n/fs);
    subplot(2,3,idx); stem(n, x, 'filled'); grid on; ylim([-1.2 1.2]);
    title(sprintf('f_0=%g Hz, f_s=%g Hz', current_f0, fs));
    xlabel('n'); ylabel('x[n]');
end
for idx = 1:numel(sampling_cases)
    current_fs = sampling_cases(idx);
    x = sin(2*pi*f0*n/current_fs);
    subplot(2,3,3+idx); stem(n, x, 'filled'); grid on; ylim([-1.2 1.2]);
    title(sprintf('f_0=%g Hz, f_s=%g Hz', f0, current_fs));
    xlabel('n'); ylabel('x[n]');
end
sgtitle('改变 f_0（上排）和 f_s（下排）的影响');
saveas(fig2, fullfile(result_dir, 'frequency_and_sampling_effects.png'));

fprintf('实验1完成。f0=37 Hz 在 fs=64 Hz 时混叠为 -27 Hz。\n');

