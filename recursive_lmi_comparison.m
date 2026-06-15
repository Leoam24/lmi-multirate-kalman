%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Milestone 3 — LMI vs Recursive Kalman Filter: Gain Comparison
%
% Author: Léo Ahmed Mushtaq
% Supervised by: Hiroshi Okajima
% Created with assistance from Claude (Anthropic)
% Date: June 2026
%
% Description:
%   Quantitative comparison between the offline LMI periodic gains L_k
%   and the recursive steady-state predictor gains L_rec,ss(k) = A*K_ss(k).
%   Computes the Frobenius norm gap Delta_k = ||L_k^LMI - L_k^rec||_F
%   for all k = 0,...,N-1 and produces the report figures.
%
% Reference:
%   H. Okajima, "LMI Optimization Based Multirate Steady-State Kalman Filter
%   Design," IEEE Access, 2025.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;

%% Loading variables from the LMI method
set(0, 'DefaultFigureVisible', 'off'); % deactivate graphics from other scripts
addpath('C:\Users\Ahmed Mushtaq Léo\Desktop\Code\lmi-multirate-kalman\Example_MultirateKF');
silence1 = evalc('MultirateKF_01');
clearvars('-except', 'L', 'copt', 'eig_cl', 'P_ss', 'X_opt');
rmpath('C:\Users\Ahmed Mushtaq Léo\Desktop\Code\lmi-multirate-kalman\Example_MultirateKF');

%% Loading variables from the Recursive Kalman Filter method
silence2 = evalc('main_kalman_recursive');
clearvars('-except', 'L', 'copt', 'eig_cl', 'P_ss', 'X_opt', ...
                   'K_history', 'L_history', 'P_history', 'T', 'trace_P');
set(0, 'DefaultFigureVisible', 'on');

%% Extraction of gains from the LMI method
% L{1}  = L_0 : gain at k mod 10 = 0 (GPS + Wheel active)
% L{2}  = L_1 : gain at k mod 10 = 1 (Wheel only) — representative for k=1..9
L_LMI_GPS   = L{1};   % 3x2 matrix, k=0
L_LMI_Wheel = L{2};   % 3x2 matrix, k=1..9

%% Extraction of gains from the Recursive Kalman Filter method
N    = 10;
T_ss = T - 5*N;   % steady state window start (well past transient at k~30)

L_rec_ss = cell(N, 1);
for ki = 1:N
    % Average over 5 complete periods for robustness
    acc = zeros(3, 2);
    for rep = 0:4
        acc = acc + L_history{T_ss + rep*N + ki};
    end
    L_rec_ss{ki} = acc / 5;
end

% Direct access to the two representative instants
L_rec_GPS   = L_rec_ss{1};   % k mod 10 = 0 (GPS + Wheel) - matches L_LMI_GPS
L_rec_Wheel = L_rec_ss{2};   % k mod 10 = 1 (Wheel only)  - matches L_LMI_Wheel

%% Finding the Gap between the two methods
gap_GPS   = norm(L_rec_GPS   - L_LMI_GPS,   'fro');
gap_Wheel = norm(L_rec_Wheel - L_LMI_Wheel, 'fro');

% Full table: Delta_k for all k = 0,...,N-1
delta = zeros(N, 1);
for ki = 1:N
    delta(ki) = norm(L_rec_ss{ki} - L{ki}, 'fro');
end

fprintf('\n=== MILESTONE 3 : Gap analysis between Recursive Kalman and LMI ===\n');
fprintf('%-4s  %-12s  %-14s  %-14s  %-12s\n', ...
        'k', 'Sensors', '||L_LMI||_F', '||L_rec||_F', 'Delta_k');
fprintf('%s\n', repmat('-',1,60));

for ki = 1:N
    if ki == 1, s = 'GPS+Wheel'; else, s = 'Wheel only'; end
    fprintf('%-4d  %-12s  %-14.6f  %-14.6f  %-12.2e\n', ...
        ki-1, s, norm(L{ki},'fro'), norm(L_rec_ss{ki},'fro'), delta(ki));
end
fprintf('%s\n', repmat('-',1,60));
fprintf('%-4s  %-12s  %-14s  %-14s  %-12.2e\n', 'avg','','','',mean(delta));

%% Display of the Gap (Position) : L(1,1)
figure('Name', 'Milestone 3 : LMI vs Recursive Gap (Position)', 'Position', [150 150 900 500]);

L_rec_11_traj = zeros(T, 1);
for k = 1:T
    L_rec_11_traj(k) = L_history{k}(1,1);
end

plot(1:T, L_rec_11_traj, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 3, ...
     'DisplayName', 'Recursive gain L_{rec}(1,1)');
hold on;
yline(L_LMI_GPS(1,1), 'r--', ...
      sprintf('LMI L_0(1,1) = %.4f', L_LMI_GPS(1,1)), ...
      'LineWidth', 2, 'LabelHorizontalAlignment', 'left', ...
      'DisplayName', 'LMI offline gain L_0(1,1)');

% Gap annotation on the plot
yline(L_rec_GPS(1,1), 'b:', ...
      sprintf('Rec SS = %.4f', L_rec_GPS(1,1)), ...
      'LineWidth', 1.2, 'LabelHorizontalAlignment', 'right', ...
      'DisplayName', 'Recursive SS value');

title('M3 - Comparison of L(1,1): GPS \rightarrow Position (predictor form)');
xlabel('Time step k');
ylabel('Gain value L(1,1)');
xlim([30, 70]);
grid on;
legend('Location', 'northeast');

%% Display of the Gap (Velocity) : L(2,2)
figure('Name', 'Milestone 3 : LMI vs Recursive Gap (Velocity)', ...
       'Position', [150 150 900 500]);

L_rec_22_traj = zeros(T, 1);
for k = 1:T
    L_rec_22_traj(k) = L_history{k}(2,2);
end

plot(1:T, L_rec_22_traj, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 3, ...
     'DisplayName', 'Recursive gain L_{rec}(2,2)');
hold on;

%   - L_LMI_GPS(2,2)   = L{1}(2,2) for k=0 (GPS+Wheel) — upper dashed line
%   - L_LMI_Wheel(2,2) = L{2}(2,2) for k=1..9 (Wheel only) — lower dashed line
yline(L_LMI_GPS(2,2), 'r--', ...
      sprintf('LMI L_0(2,2) = %.4f  [GPS+Wheel]', L_LMI_GPS(2,2)), ...
      'LineWidth', 2, 'LabelHorizontalAlignment', 'left', ...
      'DisplayName', 'LMI L_0(2,2)  [k=0, GPS+Wheel]');
yline(L_LMI_Wheel(2,2), 'g--', ...
      sprintf('LMI L_1(2,2) = %.4f  [Wheel only]', L_LMI_Wheel(2,2)), ...
      'LineWidth', 2, 'LabelHorizontalAlignment', 'left', ...
      'DisplayName', 'LMI L_1(2,2)  [k=1..9, Wheel only]');

title('M3 — Comparison of L(2,2): Wheel \rightarrow Velocity (predictor form)');
xlabel('Time step k');
ylabel('Gain value L(2,2)');
xlim([30, 70]);
grid on;
legend('Location', 'northeast');

%% Complete comparison figure
figure('Name', 'Milestone 3 : Complete comparison', ...
       'Position', [100 100 1400 500]);

% Panel (a): Frobenius norm comparison
subplot(1, 3, 1);
lmi_norms = cellfun(@(Lk) norm(Lk,'fro'), L);
rec_norms  = cellfun(@(Lk) norm(Lk,'fro'), L_rec_ss);
bar(0:N-1, [lmi_norms(:), rec_norms(:)]);
legend({'LMI offline','Recursive SS'}, 'Location','northeast');
xlabel('k mod N'); ylabel('||L_k||_F');
title('(a) Frobenius norm comparison'); grid on;

% Panel (b): Gap Delta_k for all k=0..N-1
subplot(1, 3, 2);
bar(0:N-1, delta, 'FaceColor', [0.8 0.2 0.1]);
yline(mean(delta), 'k--', sprintf('mean = %.2e', mean(delta)), ...
    'LabelHorizontalAlignment', 'right');
xlabel('k mod N'); ylabel('\Delta_k = ||L_k^{LMI} - L_k^{rec}||_F');
title('(b) Gap \Delta_k per period instant'); grid on;

% Panel (c): Scatter of all individual gain entries
subplot(1, 3, 3);
lmi_all = cell2mat(cellfun(@(Lk) Lk(:)', L,         'UniformOutput',false))';
rec_all = cell2mat(cellfun(@(Lk) Lk(:)', L_rec_ss,  'UniformOutput',false))';
scatter(lmi_all(:), rec_all(:), 50, 'filled', ...
    'MarkerFaceColor', [0.18 0.45 0.80]);
hold on;
lims = [min([lmi_all(:);rec_all(:)]) max([lmi_all(:);rec_all(:)])];
plot(lims, lims, 'r--', 'LineWidth', 1.8);
ss_res = sum((rec_all(:) - lmi_all(:)).^2);
ss_tot = sum((rec_all(:) - mean(rec_all(:))).^2);
text(0.05, 0.92, sprintf('R^2 = %.6f', 1 - ss_res/ss_tot), ...
    'Units','normalized','FontSize',10,'Color',[0.1 0.4 0.1],'FontWeight','bold');
xlabel('LMI gain entry'); ylabel('Recursive SS gain entry');
title('(c) Scatter — ideal: y = x'); axis equal; grid on;
legend({'Gain entries','y = x (perfect match)'}, 'Location','southeast');

sgtitle('Milestone 3 — LMI offline gains vs recursive steady-state gains', ...
    'FontSize', 13, 'FontWeight', 'bold');
