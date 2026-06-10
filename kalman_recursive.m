function [K_history, L_history, P_history] = kalman_recursive(A, C, Q, R, S_mat, P0, T)
    % Initialisation
    n = size(A, 1);
    m = size(C, 1);
    N = length(S_mat);
    
    P = P0;
    K_history = cell(T, 1); % saves the gain K for each k
    L_history = cell(T, 1);   % predictor gain L = A*K
    P_history = zeros(n, n, T);

    for k = 1:T
        %--prediction--
        P_pred = A * P * A' + Q;
        
        %--active sensors identification--
        idx = mod(k-1, N) + 1;
        S_k = S_mat{idx};
        
        % We are looking for which sensor lines are active (the 1s on the diagonal of S_k)
        active_idx = find(diag(S_k) == 1); 
        
        %--Extraction du "bloc non-singulier"--
        C_act = C(active_idx, :);
        R_act = R(active_idx, active_idx);
        
        %--Kalman Gain--
        % The gain is calculated only for the sensors that are turned on
        K_act = P_pred * C_act' / (C_act * P_pred * C_act' + R_act);
        
        % reconstruction of the true matrix K (zero where there is no sensor)
        K = zeros(n, m);
        K(:, active_idx) = K_act;
        
        %--Correction phase--
        % Update of the covariance with the information provided by the active sensors
        P = (eye(n) - K * C) * P_pred;
        %--Save--
        K_history{k} = K;
        L_history{k} = A * K;
        P_history(:,:,k) = P;

    end
end