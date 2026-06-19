%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test_run_kalman_milestone2 - Script de test pour la fonction
%                              run_kalman_milestone2.m
%
% Author: Leo Ahmed Mushtaq
% Created with assistance from Claude (Anthropic)
% Date: June 2026
%
% Description:
%   Appelle run_kalman_milestone2 avec les parametres nominaux
%   (N=10, dt=0.1, T=200, Q/R/P0 par defaut) et verifie que les
%   sorties ont les dimensions attendues.
%
% IMPORTANT :
%   Remplacer 'run_kalman_milestone2' ci-dessous par le nom exact
%   de ta fonction si tu en as choisi un autre. Le nom NE DOIT PAS
%   etre 'kalman_recursive' (deja utilise par le fichier moteur).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all; clc;

%% Parametres de test (cas nominal)
N_test  = 10;
dt_test = 0.1;
T_test  = 200;
Q_test  = diag([0.01, 0.1, 0.5]);
R_test  = diag([1.0, 0.1]);
P0_test = eye(3);

%% Appel de la fonction
fprintf('=== Test de run_kalman_milestone2 (cas nominal) ===\n');

[K_history, L_history, P_history, trace_P] = func_kalman_recursive(N_test, dt_test, T_test, Q_test, R_test, P0_test);

%% Verifications basiques
fprintf('\n--- Verification des dimensions ---\n');
fprintf('length(K_history) = %d (attendu : %d)\n', length(K_history), T_test);
fprintf('length(L_history) = %d (attendu : %d)\n', length(L_history), T_test);
fprintf('size(P_history)   = [%s] (attendu : [3 3 %d])\n', ...
    num2str(size(P_history)), T_test+1);
fprintf('length(trace_P)   = %d (attendu : %d)\n', length(trace_P), T_test);

fprintf('\n--- Verification de coherence numerique ---\n');
fprintf('K_history{1} :\n'); disp(K_history{1});
fprintf('trace_P(end) = %.6f (doit etre fini et positif)\n', trace_P(end));

if all(trace_P > 0) && all(isfinite(trace_P))
    fprintf('\nOK : trace_P est positive et finie sur toute la simulation.\n');
else
    fprintf('\nATTENTION : trace_P contient des valeurs negatives ou non finies.\n');
end

fprintf('\n=== Test termine ===\n');