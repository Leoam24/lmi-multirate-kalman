%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Milestone 2 - Recursive Multirate Kalman Filter Implementation
%
% Author: Léo AHMED MUSHTAQ
% Supervised by: Hiroshi OKAJIMA
% Created with assistance from Claude (Anthropic)
% Date: June 2026
%
% Description:
%   This code implements a time-varying, recursive multirate Kalman filter 
%   for automotive navigation systems. It is designed to evaluate the transient 
%   and periodic steady-state convergence (Milestone 2) prior to LMI synthesis.
%   The system fuses GPS measurements (1 Hz) with wheel speed sensor data (10 Hz)
%   to estimate vehicle position, velocity, and acceleration.
% 
%   Deterministic gain property: K(k) depends only on A, C, Q, R, S_k
%   and P(0), NOT on the realized noise. The gain trajectory is therefore
%   identical across all noise realizations — no state simulation required.
%
%   Key Features:
%   - Dynamic sensor dimension handling (active/inactive states)
%   - Avoids numerical singularities by extracting active sub-matrices
%   - Recursive tracking of Predictor (L) and Filter (K) gains
%   - Visual verification of error covariance P(k) periodicity
%
% System Configuration:
%   - State: [position; velocity; acceleration]
%   - Measurements: GPS position (1 Hz, active every N=10 steps) + Wheel speed (10 Hz, active every step)
%   - Period: N = 10, Sampling time: dt = 0.1s
%
% Recursive Formulation:
%   Prediction:   P_pred = A * P * A' + Q
%   Active block: C_act = C(active_idx,:),  R_act = R(active_idx,active_idx)
%   Filter gain:  K_act = P_pred * C_act' / (C_act * P_pred * C_act' + R_act)
%                 K = zeros(n,m);  K(:,active_idx) = K_act   (full n×m matrix)
%   Correction:   P = (I - K*C) * P_pred
%   Predictor:    L = A * K   (for comparison with LMI gains in Milestone 3)
%
% Reference:
%   H. Okajima, "LMI Optimization Based Multirate Steady-State Kalman Filter 
%   Design," IEEE Access, 2025. 
%
% Usage:
%   Run this script directly to perform:
%   1. System and measurement pattern definition
%   2. Recursive Kalman filter execution over T steps
%   3. Gain component extraction over time
%   4. Visual evaluation of convergence and periodicity
%
% Output:
%   - Console: P(k) trace values verifying N=10 periodicity
%   - Figures: Kalman filter/predictor gains, Covariance matrix convergence
%
% Required MATLAB Toolboxes:
%   - Base MATLAB
%
% Repository:
%   https://github.com/Leoam24/lmi-multirate-kalman
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear;
close all; clc;
%% System Definition
N = 10; p = 1; dt = 0.1; T = 200;

% State-space model: x = [position; velocity; acceleration]
A = [1  dt  0.5*dt^2;
     0  1   dt;
     0  0   0.8];

B = [0; 0; 1];

% Output: position and velocity
C = [1 0 0;   % GPS position
     0 1 0];  % Wheel speed sensor

Q = diag([0.01, 0.1, 0.5]);  % Process noise
R = diag([1.0, 0.1]);        % GPS accuracy ±1m, wheel speed accuracy ±0.1m/s
P0 = eye(3,3);

% Measurement pattern (2×2 diagonal matrix)
% GPS (position): every 10 steps (k mod 10 = 0)
% Wheel speed (velocity): every step
S_mat = cell(N, 1);
S_mat{1} = diag([1, 1]);   % k mod 10 = 0: GPS + wheel speed
for i = 2:N
    S_mat{i} = diag([0, 1]);  % k mod 10 = 1-9: wheel speed only
end

%% run Recursive Filter
[K_history, L_history, P_history] = kalman_recursive(A, C, Q, R, S_mat, P0, T);

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
figure('Name','Milestone 2: Gain convergence',...
      'Position',[150 150 1000 700]);

subplot(2,2,1);
plot(1:T, K_gps_pos, 'b-', 'LineWidth', 1.5);
title('K(1,1) - Filter : GPS --> Position');
ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end

subplot(2,2,2);
plot(1:T, K_wheel_vel, 'r-', 'LineWidth', 1.5);
title('K(2,2) - Filter : Wheel --> Velocity');
ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end

subplot(2,2,3);
plot(1:T, L_gps_pos, 'b-', 'LineWidth', 1.5);
title('L(1,1) = A·K(1,1) - Predictor : GPS --> Position');
xlabel('Step k'); ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end

subplot(2,2,4);
plot(1:T, L_wheel_vel, 'r-', 'LineWidth', 1.5);
title('L(2,2) = A·K(2,2) - Predictor : Wheel --> Velocity');
xlabel('Step k'); ylabel('Gain value'); grid on;
for i = 1:N:T, xline(i, 'k:', 'HandleVisibility','off'); end

sgtitle('Milestone 2 - Recursive Kalman filter convergence', 'FontSize', 13);


%% Error Covariance Convergence (P_k)
trace_P = zeros(T, 1);
for k = 1:T
    trace_P(k) = trace(P_history(:,:,k));
end

%% Error Covariance Convergence display
figure('Name', 'Milestone 2: Covariance Matrix Convergence', 'Position', [200 200 800 450]);
plot(1:T, trace_P, 'b-s', 'LineWidth', 2, 'MarkerFaceColor', 'b', 'MarkerSize', 4);
hold on;

% Threshold marking the end of the initial transient phase (e.g., k = 20)
xline(20, 'r--', 'Transient End', 'LabelVerticalAlignment', 'bottom', 'LineWidth', 1.5);

% Grid indicators for each full cycle period (N = 10 steps)
for i = 1:N:T
    xline(i, 'k:', 'HandleVisibility', 'off');
end

title('Evolution of trace(P(k)) Over Time', 'FontSize', 12);
xlabel('Time Step k');
ylabel('trace(P(k)) (Total Estimation Uncertainty)');
grid on;

fprintf('\n========================================\n');
fprintf('   P(k) Periodicity Verification\n');
fprintf('========================================\n');
fprintf('trace(P(41)) = %.6f\n', trace_P(41));
fprintf('trace(P(51)) = %.6f\n', trace_P(51));
fprintf('trace(P(61)) = %.6f\n', trace_P(61));
fprintf('========================================\n');

