%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate_figures.m
%
% Generates ALL 8 figures required for the internship report.
% Run this script AFTER MultirateKF_01.m so that all workspace variables
% (A, C, Q, R, N, n, m, n_cyc, m_cyc, A_cyc, C_cyc, R_cyc, L, L_cyc,
%  X_opt, P_ss, eig_cl, x_true, x_hat, z_obs, T, dt, S_mat) are in memory.
%
% Alternatively, run:
%   run('MultirateKF_01.m');
%   run('generate_figures.m');
%
% Output: 8 MATLAB figures + saves each as PDF in ./figures/
%
% Author: Léo Ahmed Mushtaq — Kumamoto University internship 2026
% Supervisor: Prof. Hiroshi Okajima
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---- Setup ----
close all;
output_dir = 'figures';
if ~exist(output_dir, 'dir'), mkdir(output_dir); end

% % Helper: save figure as PDF with tight bounding box
% save_fig = @(fig, name) exportgraphics(fig, ...
%     fullfile(output_dir, [name '.pdf']), 'ContentType', 'vector');

fprintf('Generating figures...\n');

%% ================================================================
%% FIGURE 1 — Measurement timing diagram
%% ================================================================
% WHAT: A timeline showing GPS pulses (sparse) vs wheel speed (dense).
% WHY:  Makes the multirate concept concrete before any equation.
%       Reader immediately understands the information asymmetry.
% WHERE IN REPORT: Section 2 "Context and Objectives", Figure 1.
%
% REQUIRES: N, S_mat (from MultirateKF_01.m workspace)
% ================================================================

fig1 = figure('Name','Fig1_TimingDiagram','Position',[50 50 900 350]);

T_disp = 22;   % show slightly more than 2 full periods
hold on; box on;

% Draw wheel speed markers (every step) — row 1
for k = 0:T_disp-1
    fill([k-0.1 k+0.1 k+0.1 k-0.1], [0.6 0.6 1.4 1.4], ...
        [0.2 0.6 1.0], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
end

% Draw GPS markers (every N steps) — row 2
for k = 0:N:T_disp-1
    fill([k-0.3 k+0.3 k+0.3 k-0.3], [1.6 1.6 2.4 2.4], ...
        [0.1 0.7 0.1], 'EdgeColor', 'none');
    text(k, 2.5, sprintf('k=%d',k), 'HorizontalAlignment','center', ...
        'FontSize', 8, 'Color', [0.1 0.5 0.1]);
end

% Period delimiter lines
for k = 0:N:T_disp
    xline(k-0.5, 'k--', 'LineWidth', 0.8, 'Alpha', 0.4);
end

% Annotations
text(-0.5, 1.0, 'Wheel speed (10 Hz)', 'HorizontalAlignment','right', ...
    'FontSize', 10, 'FontWeight','bold', 'Color', [0.2 0.4 0.8]);
text(-0.5, 2.0, 'GPS (1 Hz)', 'HorizontalAlignment','right', ...
    'FontSize', 10, 'FontWeight','bold', 'Color', [0.1 0.5 0.1]);

% S_k labels
text(0,  0.2, 'S_0=diag(1,1)', 'FontSize',8, 'Color','k','HorizontalAlignment','center');
text(1,  0.2, 'S_1=diag(0,1)', 'FontSize',8, 'Color','k','HorizontalAlignment','center');
text(5,  0.2, 'S_5=diag(0,1)', 'FontSize',8, 'Color','k','HorizontalAlignment','center');

% Period brace
annotation('doublearrow', [0.09 0.29], [0.08 0.08], ...
    'Head1Length',6,'Head2Length',6);
text(N/2-0.5, -0.4, 'One period N = 10 steps (1 s)', ...
    'HorizontalAlignment','center', 'FontSize', 9);

xlim([-1 T_disp]); ylim([-0.7 3.0]);
xticks(0:T_disp-1);
set(gca, 'YTick', [], 'XGrid', 'off');
xlabel('Time step k', 'FontSize', 11);
title(sprintf('Measurement availability pattern (N=%d, \\Deltat=%.1fs)', N, dt), ...
    'FontSize', 12, 'FontWeight', 'bold');

legend({'Wheel speed (always active)', 'GPS (active at k=0,10,20,...)'}, ...
    'Location','northeast', 'FontSize', 9);
% 
% save_fig(fig1, 'Fig1_TimingDiagram');
fprintf('  Fig 1 saved: timing diagram\n');

%% ================================================================
%% FIGURE 2 — Structure of R_cyc (imagesc)
%% ================================================================
% WHAT: Color map of the 20x20 R_cyc matrix showing the semidefinite structure.
% WHY:  The core motivation of the whole paper. Visually proves that standard
%       DARE cannot be used (9 out of 10 diagonal blocks are rank-deficient).
% WHERE IN REPORT: Section 3 "Theoretical Background", Figure 2.
%
% REQUIRES: R_cyc, m_cyc, m, N (from workspace)
% ================================================================

fig2 = figure('Name','Fig2_Rcyc_Structure','Position',[50 50 650 600]);

imagesc(R_cyc);
colormap(flipud(gray(256)));
colorbar;
clim([0 max(R_cyc(:))]);

% Draw block grid lines
hold on;
for i = 1:N
    xline(i*m + 0.5, 'r-', 'LineWidth', 0.8, 'Alpha', 0.5);
    yline(i*m + 0.5, 'r-', 'LineWidth', 0.8, 'Alpha', 0.5);
end

% Label the special block at k=0
rectangle('Position',[0.5 0.5 m m], 'EdgeColor','g', 'LineWidth', 2.5);
text(m/2+0.5, m/2+0.5, {'k=0','GPS+','Wheel'}, ...
    'HorizontalAlignment','center', 'FontSize', 7.5, ...
    'Color','g', 'FontWeight','bold');

% Label a wheel-only block
rectangle('Position',[m+0.5 m+0.5 m m], 'EdgeColor', [0.8 0.2 0.1], 'LineWidth', 2);
text(m+m/2+0.5, m+m/2+0.5, {'k=1','Wheel','only'}, ...
    'HorizontalAlignment','center', 'FontSize', 7.5, ...
    'Color',[0.8 0.2 0.1], 'FontWeight','bold');

axis equal tight;
xlabel('Column index', 'FontSize', 11);
ylabel('Row index',    'FontSize', 11);
title(sprintf(['\\check{R}_{cyc} \\in \\mathbb{R}^{%d\\times%d}  '...
    '(rank = %d / %d)'], m_cyc, m_cyc, rank(R_cyc), m_cyc), ...
    'FontSize', 12, 'FontWeight', 'bold');

annotation('textbox',[0.55 0.18 0.38 0.08],'String', ...
    {'rank(\check{R}) = 11 < 20', '→ DARE cannot be used', '→ LMI approach required'}, ...
    'FitBoxToText','on','BackgroundColor',[1 0.95 0.8], ...
    'EdgeColor',[0.8 0.5 0],'FontSize',9);

% save_fig(fig2, 'Fig2_Rcyc_Structure');
fprintf('  Fig 2 saved: R_cyc structure\n');

%% ================================================================
%% FIGURE 3 — Sparsity of A_cyc (spy plot)
%% ================================================================
% WHAT: Sparsity pattern of the 30x30 cyclic matrix A_cyc.
% WHY:  Shows the mathematical structure of the cyclic reformulation.
%       The subdiagonal + top-right corner pattern is the key structural fact.
% WHERE IN REPORT: Section 4 "Technical Contribution", Figure 3.
%
% REQUIRES: A_cyc, n_cyc, n, N (from workspace)
% ================================================================

fig3 = figure('Name','Fig3_Acyc_Spy','Position',[50 50 550 520]);

spy(A_cyc, 14);
hold on;

% Highlight the cyclic corner block (rows 1:n, cols n_cyc-n+1:n_cyc)
% spy uses (col, row) convention so rectangle is at:
rectangle('Position', [n_cyc-n+0.5, 0.5, n, n], ...
    'EdgeColor', [0.8 0.1 0.1], 'LineWidth', 2.5, 'LineStyle', '--');
text(n_cyc-n/2, n/2, 'Cyclic\ncorner', ...
    'HorizontalAlignment','center', 'FontSize', 7, ...
    'Color', [0.8 0.1 0.1], 'FontWeight','bold');

% Highlight one subdiagonal block
rectangle('Position', [0.5, n+0.5, n, n], ...
    'EdgeColor', [0.1 0.4 0.8], 'LineWidth', 2, 'LineStyle', '--');
text(n/2, n+n/2, 'A block\n(subdiag)', ...
    'HorizontalAlignment','center', 'FontSize', 7, ...
    'Color', [0.1 0.4 0.8], 'FontWeight','bold');

% Block grid
for i = 1:N
    xline(i*n+0.5, 'k-', 'LineWidth', 0.5, 'Alpha', 0.3);
    yline(i*n+0.5, 'k-', 'LineWidth', 0.5, 'Alpha', 0.3);
end

xlabel('Column (block index × n)', 'FontSize', 11);
ylabel('Row (block index × n)',    'FontSize', 11);
title(sprintf('Sparsity of \\check{A}_{cyc} \\in \\mathbb{R}^{%d\\times%d}  (n=%d, N=%d)', ...
    n_cyc, n_cyc, n, N), 'FontSize', 12, 'FontWeight','bold');

legend({'Nonzero entries', 'Cyclic corner block', 'Subdiagonal block'}, ...
    'Location','northeast', 'FontSize', 8);

% save_fig(fig3, 'Fig3_Acyc_Spy');
fprintf('  Fig 3 saved: A_cyc sparsity\n');

%% ================================================================
%% FIGURE 4 — State estimation trajectories (Milestone 1 main result)
%% ================================================================
% WHAT: 3-panel plot: position, velocity, acceleration — true vs estimated.
% WHY:  The main validation result of Milestone 1. Shows the filter works
%       despite sparse GPS. Computes and displays RMSE per state.
% WHERE IN REPORT: Section 5 "Results", Figure 4.
%
% REQUIRES: x_true, x_hat, z_obs, T, dt, N, n (from workspace)
% ================================================================

fig4 = figure('Name','Fig4_Estimation','Position',[50 50 1300 700]);

state_labels = {'Position  [m]', 'Velocity  [m/s]', 'Acceleration  [m/s^2]'};
colors_true = [0 0 0];
colors_hat  = [0.18 0.45 0.80];

time_axis = (0:T-1) * dt;   % seconds

for i = 1:3
    subplot(1, 3, i);
    
    % True state
    plot(time_axis, x_true(i,:), '-', 'Color', colors_true, ...
        'LineWidth', 2.0, 'DisplayName', 'True state'); hold on;
    
    % Estimated state
    plot(time_axis, x_hat(i,:), '-', 'Color', colors_hat, ...
        'LineWidth', 1.5, 'DisplayName', 'LMI estimate');
    
    % Sensor observations
    if i == 1
        % GPS: only at k=0,10,20,...
        gps_idx = find(mod(0:T-1, N) == 0);
        plot((gps_idx-1)*dt, z_obs(1, gps_idx), 'o', ...
            'Color', [0.1 0.7 0.1], 'MarkerSize', 6, ...
            'MarkerFaceColor', [0.3 0.9 0.3], ...
            'DisplayName', 'GPS observation');
    elseif i == 2
        % Wheel speed: every step (plot subsample for readability)
        step = 2;
        plot(time_axis(1:step:end), z_obs(2, 1:step:end), '.', ...
            'Color', [0.85 0.25 0.1], 'MarkerSize', 5, ...
            'DisplayName', 'Wheel speed obs.');
    end
    
    % RMSE annotation
    rmse_i = sqrt(mean((x_true(i,:) - x_hat(i,:)).^2));
    units = {'m', 'm/s', 'm/s^2'};
    text(0.97, 0.97, sprintf('RMSE = %.3f %s', rmse_i, units{i}), ...
        'Units','normalized', 'HorizontalAlignment','right', ...
        'VerticalAlignment','top', 'FontSize', 10, ...
        'BackgroundColor', [0.95 0.95 1.0], 'EdgeColor', colors_hat);
    
    xlabel('Time [s]', 'FontSize', 11);
    ylabel(state_labels{i}, 'FontSize', 11);
    title(state_labels{i}, 'FontSize', 12, 'FontWeight','bold');
    legend('Location','best', 'FontSize', 9);
    grid on; box on;
end

sgtitle(sprintf(['Milestone 1 — LMI multirate Kalman filter: state estimation\n'...
    '(GPS 1 Hz + Wheel speed 10 Hz,  N=%d,  T=%.0f s)'], N, T*dt), ...
    'FontSize', 13, 'FontWeight', 'bold');

% save_fig(fig4, 'Fig4_Estimation');
fprintf('  Fig 4 saved: state estimation\n');

%% ================================================================
%% FIGURE 5 — Periodic Kalman gains L_k
%% ================================================================
% WHAT: Bar chart of ||L_k||_F for k=0..9, plus individual entries stem plot.
% WHY:  Validates the extracted gains against the paper's Table values.
%       Shows the zero-first-column structure (no GPS → no position correction).
% WHERE IN REPORT: Section 5 "Results", Figure 5.
%
% REQUIRES: L (cell{N}), N, n, m (from workspace)
% ================================================================

fig5 = figure('Name','Fig5_PeriodicGains','Position',[50 50 1200 750]);

% Compute Frobenius norms
L_norms = cellfun(@(Lk) norm(Lk,'fro'), L);

% Panel (a): Frobenius norm bar chart
subplot(2, 1, 1);
bar_h = bar(0:N-1, L_norms, 0.6);
bar_h.FaceColor = 'flat';
for k = 1:N
    if k == 1
        bar_h.CData(k,:) = [0.15 0.55 0.85];   % GPS+wheel: blue
    else
        bar_h.CData(k,:) = [0.75 0.75 0.75];   % wheel only: gray
    end
end
xlabel('k mod N', 'FontSize', 11);
ylabel('||L_k||_F  (Frobenius norm)', 'FontSize', 11);
title('Frobenius norm of periodic Kalman gains L_k', ...
    'FontSize', 12, 'FontWeight','bold');
xticks(0:N-1);
xticklabels(arrayfun(@(k) sprintf('k=%d', k), 0:N-1, 'UniformOutput', false));
grid on; box on;
text(0, L_norms(1)*0.5, {'GPS +','Wheel'}, ...
    'HorizontalAlignment','center', 'FontSize', 8, 'Color','w', 'FontWeight','bold');
text(1, L_norms(2)*1.15, 'Wheel\nonly', ...
    'HorizontalAlignment','center', 'FontSize', 8, 'Color', [0.4 0.4 0.4]);
legend({'GPS + Wheel (k=0)', 'Wheel speed only (k=1..9)'}, 'Location','northeast');

% Panel (b): Individual entries stem plots
subplot(2, 1, 2);
hold on;
entry_labels = {'[1,1] pos\leftarrowGPS', '[1,2] pos\leftarrowWheel', ...
                '[2,1] vel\leftarrowGPS', '[2,2] vel\leftarrowWheel', ...
                '[3,1] acc\leftarrowGPS', '[3,2] acc\leftarrowWheel'};
rows_e = [1 1 2 2 3 3];
cols_e = [1 2 1 2 1 2];
colors_e = lines(6);
h_stems = gobjects(6,1);
for e = 1:6
    vals = arrayfun(@(i) L{i}(rows_e(e), cols_e(e)), 1:N);
    h_stems(e) = stem(0:N-1, vals, 'Color', colors_e(e,:), ...
        'LineWidth', 1.6, 'MarkerSize', 7, ...
        'MarkerFaceColor', colors_e(e,:), 'DisplayName', entry_labels{e});
end
xlabel('k mod N', 'FontSize', 11);
ylabel('Gain entry value', 'FontSize', 11);
title('Individual entries of L_k  (first column = GPS channel)', ...
    'FontSize', 12, 'FontWeight','bold');
xticks(0:N-1);
xticklabels(arrayfun(@(k) sprintf('k=%d',k), 0:N-1, 'UniformOutput',false));
legend(h_stems, entry_labels, 'Location','eastoutside', 'FontSize', 8);
grid on; box on;
yline(0, 'k-', 'LineWidth', 0.8, 'Alpha', 0.4);

% Annotation: zero column for k>=1
annotation('textbox',[0.18 0.03 0.32 0.06], ...
    'String','[*,1] entries (GPS channel) = 0 for k=1..9 → no position correction', ...
    'FitBoxToText','on','FontSize',8,'EdgeColor',[0.7 0 0],'Color',[0.7 0 0]);

% save_fig(fig5, 'Fig5_PeriodicGains');
fprintf('  Fig 5 saved: periodic gains\n');

%% ================================================================
%% FIGURE 6 — Recursive gain convergence (Milestone 2)
%% ================================================================
% WHAT: Time series of L_rec(k) = A*K(k) for all 6 gain entries,
%       with the LMI steady-state values overlaid as dashed lines.
% WHY:  Central result of Milestone 2. Shows that the time-varying gain
%       becomes periodic and converges toward the LMI target.
% WHERE IN REPORT: Section 5.2, Figure 6.
%
% REQUIRES: A, C, Q, R, S_mat, L, N, n, m (from workspace)
%           (computes the recursive Kalman recursion internally)
% ================================================================

%% --- Compute the recursive gain ---
T_rec   = 150;               % number of steps
P       = 10 * eye(n);      % initial covariance (arbitrary, large)
L_rec   = zeros(n, m, T_rec);
trace_P = zeros(1, T_rec);

for k = 1:T_rec
    idx   = mod(k-1, N) + 1;
    Ck    = S_mat{idx} * C;            % active measurement matrix
    Ppred = A * P * A' + Q;            % prediction step

    if norm(Ck, 'fro') > 1e-10        % measurement available
        Sk = Ck * Ppred * Ck' + S_mat{idx} * R * S_mat{idx}';
        Kk = Ppred * Ck' / Sk;        % filter gain (only active block inverted)
        P  = (eye(n) - Kk * Ck) * Ppred;
    else                               % no measurement: pure prediction
        Kk = zeros(n, m);
        P  = Ppred;
    end

    L_rec(:,:,k) = A * Kk;            % convert to predictor form: L = A*K
    trace_P(k)   = trace(P);
end

%% --- Extract recursive steady-state gains (last complete period) ---
T_ss_start = T_rec - N + 1;           % start of last period
L_rec_ss   = L_rec(:,:, T_ss_start:T_rec);   % (n x m x N)

%% --- Plot ---
fig6 = figure('Name','Fig6_RecursiveConvergence','Position',[50 50 1400 900]);

rows_e = [1 1 2 2 3 3];
cols_e = [1 2 1 2 1 2];
entry_labels = {'[1,1]  pos\leftarrowGPS', '[1,2]  pos\leftarrowWheel', ...
                '[2,1]  vel\leftarrowGPS', '[2,2]  vel\leftarrowWheel', ...
                '[3,1]  acc\leftarrowGPS', '[3,2]  acc\leftarrowWheel'};

for e = 1:6
    subplot(3, 2, e);

    % Recursive time series
    rec_series = squeeze(L_rec(rows_e(e), cols_e(e), :));
    plot(1:T_rec, rec_series, 'b-', 'LineWidth', 1.3, ...
        'DisplayName', 'Recursive  L_{rec}(k)=A\cdotK(k)'); hold on;

    % LMI steady-state target lines (one per k mod N)
    y_min = min(rec_series); y_max = max(rec_series);
    for ki = 1:N
        lmi_val = L{ki}(rows_e(e), cols_e(e));
        % Only draw if within visible range
        if lmi_val >= y_min - 0.05*abs(y_max-y_min+1e-8) && ...
           lmi_val <= y_max + 0.05*abs(y_max-y_min+1e-8)
            yline(lmi_val, 'r--', 'LineWidth', 1.5, 'Alpha', 0.8);
        end
    end
    % Add one legend entry for LMI lines
    plot(NaN, NaN, 'r--', 'LineWidth', 1.5, 'DisplayName', 'LMI steady-state');

    % Mark transient end
    xline(3*N, 'k:', 'LineWidth', 1.2, 'Alpha', 0.6);
    text(3*N+1, y_min + 0.1*(y_max-y_min+1e-8), ...
        '← transient end', 'FontSize', 7.5, 'Color', [0.3 0.3 0.3]);

    xlabel('Time step k', 'FontSize', 10);
    ylabel(sprintf('L_{rec}(%s)', entry_labels{e}), 'FontSize', 10);
    title(entry_labels{e}, 'FontSize', 10.5, 'FontWeight','bold');
    grid on; box on;
    if e == 1, legend('Location','northeast','FontSize',8); end
end

sgtitle(['Milestone 2 — Recursive Kalman gain convergence  '...
    '(L_{rec}(k) = A \cdot K(k),  predictor form)'], ...
    'FontSize', 13, 'FontWeight','bold');

% save_fig(fig6, 'Fig6_RecursiveConvergence');
fprintf('  Fig 6 saved: recursive convergence\n');

%% ================================================================
%% FIGURE 7 — LMI vs recursive gain comparison (Milestone 3)
%% ================================================================
% WHAT: 3-panel comparison: norm bar chart, gap Delta_k, scatter plot.
% WHY:  Answers the central scientific question of the internship:
%       do the two gains coincide when R_cyc is semidefinite?
% WHERE IN REPORT: Section 5.3 "Milestone 3", Figure 7.
%
% REQUIRES: L (cell{N}), L_rec_ss (computed in Fig 6 block above), N
% ================================================================

fig7 = figure('Name','Fig7_GainComparison','Position',[50 50 1400 520]);

%% Compute comparison quantities
lmi_norms = cellfun(@(Lk) norm(Lk,'fro'), L);
rec_norms  = arrayfun(@(ki) norm(L_rec_ss(:,:,ki),'fro'), 1:N);
delta      = arrayfun(@(ki) norm(L{ki} - L_rec_ss(:,:,ki),'fro'), 1:N);

%% Panel (a): Frobenius norm comparison
subplot(1, 3, 1);
bar_data = [lmi_norms(:), rec_norms(:)];
hb = bar(0:N-1, bar_data, 0.75);
hb(1).FaceColor = [0.18 0.45 0.80];
hb(2).FaceColor = [0.85 0.33 0.10];
xlabel('k mod N', 'FontSize', 11);
ylabel('||L_k||_F', 'FontSize', 11);
title({'(a) Frobenius norm', 'LMI vs Recursive SS'}, 'FontSize', 11);
xticks(0:N-1); grid on; box on;
legend({'LMI offline', 'Recursive SS'}, 'Location','northeast', 'FontSize', 9);

%% Panel (b): Gap Delta_k
subplot(1, 3, 2);
bar(0:N-1, delta, 0.6, 'FaceColor', [0.75 0.15 0.10]);
hold on;
yline(mean(delta), 'k--', 'LineWidth', 1.8);
text(N-0.5, mean(delta)*1.08, ...
    sprintf('mean = %.2e', mean(delta)), ...
    'HorizontalAlignment','right', 'FontSize', 9);
xlabel('k mod N', 'FontSize', 11);
ylabel('\Delta_k = ||L_k^{LMI} - L_k^{rec}||_F', 'FontSize', 11);
title({'(b) Gap per period instant', '\Delta_k  (Frobenius norm)'}, 'FontSize', 11);
xticks(0:N-1); grid on; box on;

%% Panel (c): Scatter of all individual entries
subplot(1, 3, 3);
lmi_all = cell2mat(cellfun(@(Lk) Lk(:)', L, 'UniformOutput',false))';  % (N*n*m x 1)
rec_all = reshape(permute(L_rec_ss,[3 1 2]), N, [])';                   % same shape
rec_all = rec_all(:);

scatter(lmi_all, rec_all, 55, 'filled', ...
    'MarkerFaceColor', [0.18 0.45 0.80], 'MarkerEdgeColor','none', ...
    'MarkerFaceAlpha', 0.7);
hold on;
all_vals = [lmi_all; rec_all];
lims = [min(all_vals)*1.05, max(all_vals)*1.05];
plot(lims, lims, 'r--', 'LineWidth', 1.8, 'DisplayName', 'y = x (ideal)');

% R-squared
ss_res = sum((rec_all - lmi_all).^2);
ss_tot = sum((rec_all - mean(rec_all)).^2);
R2 = 1 - ss_res / ss_tot;
text(0.05, 0.92, sprintf('R^2 = %.6f', R2), 'Units','normalized', ...
    'FontSize', 10, 'Color', [0.1 0.4 0.1], 'FontWeight','bold');

xlabel('LMI gain entry', 'FontSize', 11);
ylabel('Recursive SS gain entry', 'FontSize', 11);
title({'(c) Entry-wise scatter', 'LMI vs Recursive (ideal: y=x)'}, 'FontSize', 11);
axis equal; grid on; box on;
legend({'Gain entries', 'y = x (perfect match)'}, 'Location','southeast', 'FontSize', 9);
xlim(lims); ylim(lims);

sgtitle(['Milestone 3 — Quantitative comparison: LMI offline gains vs '...
    'recursive steady-state gains'], 'FontSize', 12, 'FontWeight','bold');

% save_fig(fig7, 'Fig7_GainComparison');
fprintf('  Fig 7 saved: gain comparison\n');

%% ================================================================
%% FIGURE 8 — Covariance trace convergence (bonus)
%% ================================================================
% WHAT: trace(P(k)) from the recursive Kalman over time, vs the LMI bound.
% WHY:  Physical interpretation of the gap. If trace(P_rec_ss) < trace(X^-1),
%       the LMI bound is conservative. If equal, LMI is tight.
%       Directly connects the numerical gap to estimation uncertainty.
% WHERE IN REPORT: Section 5.3 or Appendix, Figure 8.
%
% REQUIRES: trace_P (computed in Fig 6 block), X_opt, P_ss, N, dt
% ================================================================

fig8 = figure('Name','Fig8_CovarianceTrace','Position',[50 50 950 450]);

time_rec = (1:T_rec) * dt;

%% Main plot: recursive trace over time
plot(time_rec, trace_P, 'b-', 'LineWidth', 1.6, ...
    'DisplayName', 'trace(P_{rec}(k))  [recursive]'); hold on;

%% LMI bound: trace(X^{-1}) = trace(P_ss)
lmi_bound = trace(P_ss);
yline(lmi_bound, 'r--', 'LineWidth', 2.2, ...
    'DisplayName', sprintf('LMI bound: trace(X^{-1}) = %.4f', lmi_bound));

%% Recursive steady-state trace (mean over last period)
rec_ss_trace = mean(trace_P(T_ss_start:T_rec));
yline(rec_ss_trace, 'g-.', 'LineWidth', 1.8, ...
    'DisplayName', sprintf('Rec. SS mean = %.4f', rec_ss_trace));

%% Gap annotation
gap_trace = abs(lmi_bound - rec_ss_trace);
rel_gap   = gap_trace / lmi_bound * 100;
text(0.65, 0.30, ...
    sprintf('|LMI bound - Rec. SS| = %.4f\n(relative gap = %.2f%%)', ...
    gap_trace, rel_gap), ...
    'Units','normalized', 'FontSize', 10, ...
    'BackgroundColor', [1 0.97 0.85], 'EdgeColor', [0.8 0.5 0]);

%% Mark transient
xline(3*N*dt, 'k:', 'LineWidth', 1.2);
text(3*N*dt + 0.1, max(trace_P)*0.85, 'Transient\nend', ...
    'FontSize', 9, 'Color', [0.4 0.4 0.4]);

xlabel('Time [s]', 'FontSize', 12);
ylabel('trace(P)', 'FontSize', 12);
title(['Covariance trace convergence: recursive P(k) vs LMI upper bound' newline ...
    '(If gap > 0: LMI is conservative due to semidefinite \check{R})'], ...
    'FontSize', 12, 'FontWeight','bold');
legend('Location','northeast', 'FontSize', 10);
grid on; box on;

% save_fig(fig8, 'Fig8_CovarianceTrace');
fprintf('  Fig 8 saved: covariance trace\n');

%% ================================================================
%% Summary
%% ================================================================
fprintf('\n========================================\n');
fprintf('All 8 figures generated and saved in ./%s/\n', output_dir);
fprintf('========================================\n');
fprintf('  Fig1_TimingDiagram.pdf    — Measurement pattern\n');
fprintf('  Fig2_Rcyc_Structure.pdf   — R_cyc semidefinite structure\n');
fprintf('  Fig3_Acyc_Spy.pdf         — A_cyc sparsity pattern\n');
fprintf('  Fig4_Estimation.pdf       — State estimation result (M1)\n');
fprintf('  Fig5_PeriodicGains.pdf    — Periodic gains L_k (M1)\n');
fprintf('  Fig6_RecursiveConvergence — Gain convergence (M2)\n');
fprintf('  Fig7_GainComparison.pdf   — LMI vs recursive (M3)\n');
fprintf('  Fig8_CovarianceTrace.pdf  — Covariance bound (M3 bonus)\n');
fprintf('\nKey numerical results:\n');
fprintf('  trace(W) LMI       = %.4f\n', trace(W_opt));
fprintf('  trace(P_ss) LMI    = %.4f\n', trace(P_ss));
fprintf('  trace(P) recursive = %.4f\n', rec_ss_trace);
fprintf('  Relative gap       = %.2f%%\n', rel_gap);
fprintf('  max|eig(A_cl)|     = %.6f\n', max(abs(eig_cl)));
fprintf('  Mean gap Delta_k   = %.2e\n', mean(delta));