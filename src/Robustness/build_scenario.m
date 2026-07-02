function [N_test, dt_test, T_test, Q_test, R_test, P0_test, label, ...
    param_family, multiplier] = build_scenario(input_number)

switch input_number
    case 1 % Test 1: Nominal Case (N=10)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3);
        label   = 'Nominal (N=10)';
        param_family = 'N';
        multiplier = 1;
case 2  % Test 2: N=1 (GPS active with every step)
        N_test  = 1;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3);
        label        = 'N=1 (GPS every step)';
        param_family = 'N';
        multiplier   = 1;
case 3 % Test 3 : N=5
        N_test  = 5;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3);
        label        = 'N=5';
        param_family = 'N';
        multiplier   = 1;
case 4 % Test 4 : N=20
        N_test  = 20;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3);
        label   = 'N=20';
        param_family = 'N';
        multiplier = 1;
case 5 % Test 5 : Q x10 (high process noise )
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]) * 10;
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3);
        label        = 'Q x10 (high process noise)';
        param_family = 'Q';
        multiplier   = 10;
case 6 % Test 6 : Q x0.1 (low process noise)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]) * 0.1;
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3);
        label        = 'Q x0.1 (low process noise)';
        param_family = 'Q';
        multiplier   = 0.1;
case 7 % Test 7 : R x10 (unreliable sensors)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]) * 10;
        P0_test = eye(3);
        label        = 'R x10 (unreliable sensors)';
        param_family = 'R';
        multiplier   = 10;
case 8 % Test 8 : R x0.1 (reliable sensors)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]) * 0.1;
        P0_test = eye(3);
        label        = 'R x0.1 (reliable sensors)';
        param_family = 'R';
        multiplier   = 0.1;
case 9 % Test 9 : P0 x10 (significant initial uncertainty)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3) * 10;
        label        = 'P0 x10 (high initial uncertainty)';
        param_family = 'P0';
        multiplier   = 10;
case 10 % Test 10 : P0 x0.1 (low initial uncertainty)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]);
        R_test  = diag([1.0, 0.1]);
        P0_test = eye(3) * 0.1;
        label        = 'P0 x0.1 (low initial uncertainty)';
        param_family = 'P0';
        multiplier   = 0.1;
    case 11 % Test 11 : high Q and R (lot of noise)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]) * 10;
        R_test  = diag([1.0, 0.1]) * 10;
        P0_test = eye(3);
        label        = 'R x10 & Q x10 (high noise)';
        param_family = 'R&Q';
        multiplier   = 10;
    case 12 % Test 12 : low Q and R (reliable sensor and model)
        N_test  = 10;
        dt_test = 0.1;
        T_test  = 200;
        Q_test  = diag([0.01, 0.1, 0.5]) * 0.1;
        R_test  = diag([1.0, 0.1]) * 0.1;
        P0_test = eye(3);
        label        = 'R x0.1 & Q x0.1 (small noise)';
        param_family = 'R&Q';
        multiplier   = 0.1;
end
end