%% 实验3 离散系统的差分方程、冲激响应和卷积分析
clear; close all; clc;

response_length = 40;
n = 0:response_length-1;
delta = [1, zeros(1, response_length-1)];
unit_step = ones(1, response_length);

% 系统一：y[n]+0.75y[n-1]+0.125y[n-2]=x[n]-x[n-1]
b1 = [1, -1];
a1 = [1, 0.75, 0.125];
h1 = filter(b1, a1, delta);
s1 = filter(b1, a1, unit_step);
h1_theory = 6*(-0.5).^n - 5*(-0.25).^n;
s1_theory = 4*((-0.25).^(n+1) - (-0.5).^(n+1));

% 系统二：y[n]=0.25{x[n-1]+x[n-2]+x[n-3]+x[n-4]}
b2 = [0, 0.25, 0.25, 0.25, 0.25];
a2 = 1;
h2 = filter(b2, a2, delta);
s2 = filter(b2, a2, unit_step);
h2_theory = [b2, zeros(1, response_length-numel(b2))];
s2_theory = cumsum(h2_theory);

result_dir = fullfile(fileparts(mfilename('fullpath')), 'results');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

fig1 = figure('Name', '实验3：冲激响应和阶跃响应', 'Color', 'w');
subplot(2,2,1); stem(n, h1, 'filled'); hold on; plot(n, h1_theory, 'r--'); grid on;
title('系统一单位冲激响应'); xlabel('n'); ylabel('h_1[n]'); legend('filter', '理论值');
subplot(2,2,2); stem(n, s1, 'filled'); hold on; plot(n, s1_theory, 'r--'); grid on;
title('系统一单位阶跃响应'); xlabel('n'); ylabel('s_1[n]'); legend('filter', '理论值');
subplot(2,2,3); stem(n, h2, 'filled'); hold on; plot(n, h2_theory, 'r--'); grid on;
title('系统二单位冲激响应'); xlabel('n'); ylabel('h_2[n]'); legend('filter', '理论值');
subplot(2,2,4); stem(n, s2, 'filled'); hold on; plot(n, s2_theory, 'r--'); grid on;
title('系统二单位阶跃响应'); xlabel('n'); ylabel('s_2[n]'); legend('filter', '理论值');
sgtitle('差分方程的理论结果与程序结果');
saveas(fig1, fullfile(result_dir, 'impulse_and_step_responses.png'));

%% 用卷积验证 FIR 系统
test_input = [1, 2, -1, 0.5, zeros(1, 15)];
y_filter = filter(b2, a2, test_input);
y_conv_full = conv(test_input, b2);
y_conv = y_conv_full(1:numel(test_input));

fig2 = figure('Name', '实验3：卷积验证', 'Color', 'w');
stem(0:numel(test_input)-1, y_filter, 'filled'); hold on;
plot(0:numel(test_input)-1, y_conv, 'ro'); grid on;
xlabel('n'); ylabel('y[n]'); title('系统二：filter 与 conv 的结果');
legend('filter', 'conv', 'Location', 'best');
saveas(fig2, fullfile(result_dir, 'convolution_verification.png'));

fprintf('系统一冲激响应最大误差：%.3e\n', max(abs(h1-h1_theory)));
fprintf('系统一阶跃响应最大误差：%.3e\n', max(abs(s1-s1_theory)));
fprintf('系统二冲激响应最大误差：%.3e\n', max(abs(h2-h2_theory)));
fprintf('系统二阶跃响应最大误差：%.3e\n', max(abs(s2-s2_theory)));
fprintf('filter 与 conv 最大误差：%.3e\n', max(abs(y_filter-y_conv)));
