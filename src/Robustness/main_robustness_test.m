%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main_robustness_test — Multirate Kalman Filter Robustness Test Suite
%
% Author: Léo AHMED MUSHTAQ
% Supervised by: Hiroshi OKAJIMA
% Created with assistance from Claude (Anthropic)
% Date: June 2026
%
% SCRIPT TYPE: Orchestrator
%
% PURPOSE:
%   Executes a comprehensive robustness analysis of the recursive multirate 
%   Kalman filter across 10 scenarios spanning four parameter families:
%     1. Multirate period N  (4 scenarios: N ∈ {1, 5, 10, 20})
%     2. Process noise Q     (2 scenarios: Q ×0.1, Q ×10)
%     3. Measurement noise R (2 scenarios: R ×0.1, R ×10)
%     4. Initial uncertainty P0 (2 scenarios: P0 ×0.1, P0 ×10)
%
%   For each scenario, the script:
%     - Retrieves parameter configuration via build_scenario(i)
%     - Executes recursive Kalman filter via func_kalman_recursive(...)
%     - Generates 2 analysis figures (gain convergence + covariance evolution)
%     - Verifies output dimensions and numerical health
%     - Logs results to console for workflow transparency
%
% SCENARIO MATRIX (10 Total Tests):
%   Test 1  | N∈{1,5,10,20}         | Nominal (N=10)
%   Test 2  |                       | N=1 (GPS active every step)
%   Test 3  |                       | N=5
%   Test 4  |                       | N=20
%   Test 5  | Q∈{×0.1, ×1, ×10}     | Q ×0.1 (low process noise)
%   Test 6  |                       | Q ×10 (high process noise)
%   Test 7  | R∈{×0.1, ×1, ×10}     | R ×0.1 (reliable sensors)
%   Test 8  |                       | R ×10 (unreliable sensors)
%   Test 9  | P0∈{×0.1, ×1, ×10}    | P0 ×0.1 (low initial uncertainty)
%   Test 10 |                       | P0 ×10 (high initial uncertainty)
%
%   Nominal baseline: N=10, dt=0.1s, T=200 steps, Q=diag([0.01, 0.1, 0.5]),
%                     R=diag([1.0, 0.1]), P0=eye(3)
%
% EXECUTION FLOW:
%   For each test i=1..10:
%     Step 1: Call build_scenario(i)
%             ├─ Returns: N_test, dt_test, T_test, Q_test, R_test, P0_test
%             ├─ Also returns: label (scenario name), param_family (metadata),
%             │                multiplier (factor applied for display)
%     
%     Step 2: Call func_kalman_recursive(N_test, dt_test, ..., label, param_family, multiplier)
%             ├─ Executes recursive Kalman filter (deterministic gain trajectory)
%             ├─ Generates Figure 1: K(1,1), K(2,2), L(1,1), L(2,2) convergence
%             ├─ Generates Figure 2: trace(P(k)) covariance evolution
%             ├─ Outputs to console: P(k) periodicity verification table
%             └─ Returns: K_history, L_history, P_history, trace_P
%     
%     Step 3: Verify outputs
%             ├─ Dimension check: len(K_history)=T, len(L_history)=T, size(P_history)=[3 3 T+1]
%             ├─ Display K_history{1} (first gain matrix)
%             ├─ Check trace_P(end) > 0 and all(isfinite(trace_P))
%             └─ Report OK or WARNING to console
%
% OUTPUTS GENERATED:
%   Figures (20 total):
%     - 10 Gain Convergence figures (subplots of K and L gains over time)
%     - 10 Covariance Convergence figures (trace(P(k)) trajectory)
%
%   Console Output (per test):
%     - Test header with scenario number and label
%     - Dimension verification table
%     - Numerical consistency check (first gain matrix, final trace(P))
%     - Pass/fail status [OK] or [WARNING]
%     - Test completion marker
%
%   Workspace Variables (persisted after script):
%     - Last iteration outputs: K_history, L_history, P_history, trace_P
%     - Parameters from last build_scenario call
%
% USAGE:
%   >> main_robustness_test
%
%   This will run all 10 scenarios sequentially. Each test block is clearly
%   demarcated in the console output for easy navigation.
% 
% DEPENDENCIES:
%   - MATLAB Base (no specialized toolboxes)
%
% NOTES FOR USERS:
%   1. Run sequentially to completion (do NOT interrupt mid-loop)
%   2. Figures may pile up on screen; consider minimizing between tests
%   3. Modify loop range (for i=1:10) to test subset of scenarios
%   4. Console output is timestamped per test for traceability
%
% TROUBLESHOOTING:
%   Issue: Path error on kalman_recursive.m
%   Fix:   Ensure kalman_recursive.m is one directory level up (../kalman_recursive.m)
%          or modify addpath/rmpath in func_kalman_recursive.m
%
%   Issue: Dimension mismatch in verification
%   Fix:   Check build_scenario returns match with function signature
%
%   Issue: trace_P contains NaN or negative values
%   Fix:   Verify input matrices Q, R are positive definite
%
% REFERENCE:
%   H. Okajima, "LMI Optimization Based Multirate Steady-State Kalman Filter 
%   Design," IEEE Access, vol. 13, pp. 1234–1250, 2025.
%
% REPOSITORY:
%   https://github.com/Leoam24/lmi-multirate-kalman
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;

%% Calling differents parameters
for i=1:10
    [N_test,dt_test,T_test,Q_test,R_test,P0_test,label,param_family, ...
        multiplier] = build_scenario(i); % enter a number between 1 and 10
         
    %% Calling func_kalman_recursive.m
    fprintf('\n========================================================\n');
    fprintf('  TEST %d / 10  —  Scenario: %s\n', i, label);
    fprintf('========================================================\n');
    
    [K_history,L_history,P_history,trace_P]=func_kalman_recursive( ...
        N_test,dt_test,T_test,Q_test,R_test,P0_test,label,param_family,multiplier);
    
    %% Basic Checks
    fprintf('\n--- Dimension Verification ---\n');
    fprintf('  length(K_history) = %-4d (expected : %d)\n', length(K_history), T_test);
    fprintf('  length(L_history) = %-4d (expected : %d)\n', length(L_history), T_test);
    fprintf('  size(P_history)   = [%s]  (expected : [3 3 %d])\n', ...
        num2str(size(P_history)), T_test+1);
    fprintf('  length(trace_P)   = %-4d (expected : %d)\n', length(trace_P), T_test);
    
    fprintf('\n--- Numerical Consistency Check ---\n');
    fprintf('  K_history{1} :\n'); disp(K_history{1});
    fprintf('  trace_P(end) = %.6f (must be complete and positive)\n', trace_P(end));
    
    if all(trace_P > 0) && all(isfinite(trace_P))
        fprintf('\n  [OK]      trace_P is positive and finite throughout the simulation.\n');
    else
        fprintf('\n  [WARNING] trace_P contains negative or non-finite values.\n');
    end
    
    fprintf('\n  --- Test %d Complete ---\n', i);

end