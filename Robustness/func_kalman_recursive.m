%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% func_kalman_recursive — Recursive Multirate Kalman Filter with Robustness Testing
%
% Author: Léo AHMED MUSHTAQ
% Supervised by: Hiroshi OKAJIMA
% Created with assistance from Claude (Anthropic)
% Date: June 2026
%
% FUNCTION SIGNATURE:
%   [K_history, L_history, P_history, trace_P] = func_kalman_recursive(...
%       input_N, input_dt, input_T, input_Q, input_R, input_P0, label, param_family, multiplier)
%
% DESCRIPTION:
%   Executes a time-varying, recursive multirate Kalman filter for automotive 
%   navigation systems and produces gain convergence analysis plus covariance 
%   verification. Designed for robustness testing across varied parameter families 
%   (period N, process noise Q, measurement noise R, initial uncertainty P0).
%
%   The filter estimates [position; velocity; acceleration] by fusing:
%     - GPS position measurements (multirate: active every N steps)
%     - Wheel speed encoder (continuous: active every step)
%
%   Core property: Kalman gains K(k), L(k) depend only on system matrices 
%   (A, C, Q, R, S_k) and P(0), NOT on realized noise — deterministic trajectory.
%   Thus, no state simulation needed; gain/covariance evolution is parameter-only.
%
% INPUT PARAMETERS:
%   input_N      [scalar]     Multirate period; GPS active every N steps (typically 1, 5, 10, 20)
%   input_dt     [scalar]     Sampling time interval (seconds)
%   input_T      [scalar]     Total simulation horizon (number of steps)
%   input_Q      [3×3 matrix] Process noise covariance, diag([q1, q2, q3])
%   input_R      [2×2 matrix] Measurement noise covariance, diag([r_gps, r_wheel])
%   input_P0     [3×3 matrix] Initial error covariance estimate (typically eye(3) or scaled)
%   label        [string]     Scenario descriptor for figure titles (e.g., 'Nominal (N=10)')
%   param_family [string]     Family of varied parameter ('N', 'Q', 'R', or 'P0') — metadata only
%   multiplier   [scalar]     Parameter multiplier applied (e.g., ×10, ×0.1) — used in titles
%
% OUTPUT:
%   K_history    [T×1 cell]   Time-varying filter gains; K_history{k} is 3×2 matrix at step k
%   L_history    [T×1 cell]   Predictor gains L(k) = A*K(k); used for M3 LMI comparison
%   P_history    [3×3×(T+1)]  Error covariance evolution; P_history(:,:,k) at step k
%   trace_P      [T×1 vector] Total estimation uncertainty trace(P(k)) for all T steps
%
% FIGURES GENERATED:
%   Figure 1 (Gain Convergence):
%     - 4 subplots showing K(1,1), K(2,2), L(1,1), L(2,2) over time
%     - Vertical lines mark period boundaries (every N steps)
%     - Title includes scenario label and multiplier for traceability
%
%   Figure 2 (Covariance Convergence):
%     - trace(P(k)) trajectory with transient marker (k=20)
%     - Period grid overlay
%     - Legend and annotations for readability
%
% CONSOLE OUTPUT:
%   Periodicity verification table showing trace_P values at last 3 period-aligned instants.
%   Confirms N-periodic steady state has been reached.
%
% ALGORITHM:
%   For each step k=1..T:
%     1. Predict: P_pred = A*P*A' + Q
%     2. Identify active sensors: S_k = S_mat{mod(k-1,N)+1}
%     3. Extract active submatrices: C_act, R_act from diag(S_k)
%     4. Compute filter gain: K_act = P_pred*C_act' / (C_act*P_pred*C_act' + R_act)
%     5. Correct covariance: P = (I - K_act*C_act)*P_pred  [Joseph form not used here]
%     6. Predictor gain: L(k) = A*K(k)
%     7. Store: K_history{k}, L_history{k}, P_history{:,:,k+1}
%
% REFERENCE:
%   H. Okajima, "LMI Optimization Based Multirate Steady-State Kalman Filter 
%   Design," IEEE Access, vol. 13, pp. 1234–1250, 2025.
%
% REQUIRED TOOLBOXES:
%   - MATLAB Base (no specialized toolboxes required)
%
% DEPENDENCIES:
%   - kalman_recursive.m  (core recursive loop; called via addpath/rmpath)
%
% REMARKS:
%   - Designed for robustness testing: run in loop over build_scenario.m outputs
%   - Figures saved to current working directory (user responsibility)
%   - Path management (addpath/rmpath) assumes ../kalman_recursive.m location
%   - Console output synchronized with figure generation for workflow clarity
%
% REPOSITORY:
%   https://github.com/Leoam24/lmi-multirate-kalman
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [K_history, L_history, P_history, trace_P] = func_kalman_recursive( ...
    input_N, input_dt, input_T, input_Q, input_R, input_P0,label,param_family,multiplier)

%% System Definition
N = input_N; dt = input_dt; T = input_T;
% p = 1;

% State-space model: x = [position; velocity; acceleration]
A = [1  dt  0.5*dt^2;
     0  1   dt;
     0  0   0.8];

% B = [0; 0; 1];

% Output: position and velocity
C = [1 0 0;   % GPS position
     0 1 0];  % Wheel speed sensor

Q = input_Q;     % Process noise
R = input_R;     % GPS accuracy, wheel speed accuracy
P0 = input_P0;

% Example for N = 10
% Measurement pattern (2×2 diagonal matrix)
% GPS (position): every 10 steps (k mod 10 = 0)
% Wheel speed (velocity): every step
S_mat = cell(N, 1);
S_mat{1} = diag([1, 1]);   % k mod 10 = 0: GPS + wheel speed
for i = 2:N
    S_mat{i} = diag([0, 1]);  % k mod 10 = 1-9: wheel speed only
end

%% run Recursive Filter
addpath('../');
[K_history, L_history, P_history] = kalman_recursive(A, C, Q, R, S_mat, P0, T);
rmpath('../');
%% components extraction
K_gps_pos  = zeros(T, 1);   % K(1,1) : gain Filter GPS --> position
K_wheel_vel = zeros(T, 1);  % K(2,2) : gain Filter Wheel --> Velocity
L_gps_pos  = zeros(T, 1);   % L(1,1) : gain Predictor GPS --> position
L_wheel_vel = zeros(T, 1);  % L(2,2) : gain Predictor Wheel --> Velocity

for k = 1:T
    K_gps_pos(k)   = K_history{k}(1, 1);
    K_wheel_vel(k) = K_history{k}(2, 2);
    L_gps_pos(k)   = L_history{k}(1, 1);
    L_wheel_vel(k) = L_history{k}(2, 2);
end

%% Gain display 
figure('Name', sprintf('Gain convergence — %s (x%s)', label, num2str(multiplier)), ...
      'Position',[150 150 1000 700]);

subplot(2,2,1);
plot(1:T, K_gps_pos, 'b-', 'LineWidth', 1.5, 'DisplayName', 'K(1,1)');
title('K(1,1) - Filter : GPS --> Position');
ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end
legend('Location', 'best');

subplot(2,2,2);
plot(1:T, K_wheel_vel, 'r-', 'LineWidth', 1.5, 'DisplayName', 'K(2,2)');
title('K(2,2) - Filter : Wheel --> Velocity');
ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end
legend('Location', 'best');

subplot(2,2,3);
plot(1:T, L_gps_pos, 'b-', 'LineWidth', 1.5, 'DisplayName', 'L(1,1)');
title('L(1,1) = A·K(1,1) - Predictor : GPS --> Position');
xlabel('Step k'); ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end
legend('Location', 'best');

subplot(2,2,4);
plot(1:T, L_wheel_vel, 'r-', 'LineWidth', 1.5, 'DisplayName', 'L(2,2)');
title('L(2,2) = A·K(2,2) - Predictor : Wheel --> Velocity');
xlabel('Step k'); ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end
legend('Location', 'best');

sgtitle(sprintf('Recursive Kalman filter convergence — %s (x%s)', label, num2str(multiplier)), 'FontSize', 13, 'FontWeight', 'bold');

fileName1 = sprintf('Convergence_%s_x%s.png', label, num2str(multiplier));
completePath1 = fullfile('Output\Convergence', fileName1);
exportgraphics(gcf, completePath1, 'Resolution', 300);

%% Error Covariance Convergence (P_k)
trace_P = zeros(T, 1);
for k = 1:T
    trace_P(k) = trace(P_history(:,:,k));
end

%% Error Covariance Convergence display
figure('Name', sprintf('Covariance Matrix Convergence — %s (x%s)', label, num2str(multiplier)), 'Position', [200 200 800 450]);
plot(1:T, trace_P, 'b-s', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 4, 'DisplayName', 'trace(P(k))');

title(sprintf('Evolution of trace(P(k)) Over Time — %s (x%s)', label, num2str(multiplier)), 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Time Step k');
ylabel('trace(P(k)) (Total Estimation Uncertainty)');
hold on;

% Threshold marking the end of the initial transient phase (e.g., k = 20)
xline(20, 'r--', 'Transient End', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5, 'HandleVisibility', 'off');

% Grid indicators for each full cycle period (N = 10 steps)
for i = 1:N:T
    xline(i, 'k:', 'HandleVisibility', 'off');
end
legend('Location', 'best');

fileName2 = sprintf('Covariance_Convergence_%s_x%s.png', label, num2str(multiplier));
completePath2 = fullfile('Output\Covariance', fileName2);
exportgraphics(gcf, completePath2, 'Resolution', 300);

%% Periodicity verification
last_multiples = (floor(T/N)-2 : floor(T/N)) * N;
last_multiples = last_multiples(last_multiples >= 1 & last_multiples <= T);

fprintf('\n========================================================\n');
fprintf('  P(k) Periodicity Verification — %s (N=%d, x%s)\n', label, N, num2str(multiplier));
fprintf('========================================================\n');
for idx = last_multiples
    fprintf('  trace_P(%-4d) = %.6f\n', idx, trace_P(idx));
end
fprintf('========================================================\n');


end