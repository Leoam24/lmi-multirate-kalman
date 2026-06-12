% MultirateKF_01 % loading variables
%% 10. Visualisation de la structure cyclique de A_cyc
figure('Name', 'Structure de A_cyc', 'Position', [150 150 600 600]);
spy(A_cyc, 'b', 15); % 'b' pour bleu, 15 pour la taille des points
title('Spy A_{cyc}', 'FontSize', 12);
xlabel('Colonnes (États au temps k)');
ylabel('Lignes (États au temps k+1)');

% Ajout d'une grille pour bien distinguer les N blocs de taille n
hold on;
for i = 1:N-1
    xline(i*n + 0.5, 'k:', 'LineWidth', 1);
    yline(i*n + 0.5, 'k:', 'LineWidth', 1);
end
hold off;

% Ajustement des axes pour la propreté visuelle
set(gca, 'XTick', n/2:n:n_cyc, 'XTickLabel', 1:N);
set(gca, 'YTick', n/2:n:n_cyc, 'YTickLabel', 1:N);
xlabel('Column block index (k)');
ylabel('Line block index (k+1)');