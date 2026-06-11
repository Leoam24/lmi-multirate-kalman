# LMI-Based Multirate Kalman Filter Synthesis

> As part of the SRI program, I conducted research on discrete-time systems during my second-year internship at Upssitech, in collaboration with Kumamoto University. My work focused on the synthesis of LMI-based multirate Kalman filters and the comparison of their recursive gains.

## About This Project

This repository contains the MATLAB implementations developed during my research internship at **Kumamoto University (Japan)**, under the supervision of Prof. Hiroshi Okajima. 

The project focuses on **observer synthesis for discrete-time systems using LMI (Linear Matrix Inequality) optimization**. The main objective is to design and analyze a steady-state **multirate Kalman filter**. 

Through a cyclic reformulation of the system, the code enables the fusion of data from sensors operating at different frequencies (e.g., a 1 Hz GPS and a 10 Hz wheel speed sensor) while guaranteeing robust performance criteria (regional eigenvalue placement, l2-induced norm). This approach allows for the offline computation of optimal observer gains, thereby significantly reducing the computational load for embedded systems.

## Project Goals & Milestones

The core objective of this repository is to compare the offline periodic steady-state Kalman gains (proposed in Okajima, 2026) with the gains obtained by recursively updating a standard Kalman filter, evaluating their convergence and residual gaps.

* **Milestone 1 — Reproduction:** Reproduce the numerical example from the original paper (GPS 1 Hz + wheel speed 10 Hz, N=10, n=3, q=2) using the provided MATLAB LMI framework. This includes verifying the cyclic construction, the semidefinite covariance, the steady-state gains, and the reported stability/RMSE results.
* **Milestone 2 — Recursive Gain Tracking:** Run the standard time-varying Kalman recursion for the same periodic system. The gain is updated at each step from the error covariance matrix using the active measurement matrix (inverting only the active, nonsingular block). The deterministic gain trajectory over time is plotted to observe its evolution.
* **Milestone 3 — Convergence Comparison:** Convert both the LMI-based gains and recursive gains to the same predictor form to compare them. The goal is to check if the recursive gain becomes periodic after the transient phase and whether it converges to the LMI optimal periodic gains, analyzing any residual gaps due to the LMI upper-bound minimization.

## Repository Structure

* `main_kalman_recursive.m`: Main execution script configuring the multirate system (GPS/Wheel speed) and evaluating the recursive Kalman filter.
* `kalman_recursive.m`: Implementation of the standard time-varying Kalman recursion for multirate active sensors.
* `Acyc_show.m` : Structure observation of the matrix A_cyc in `MultirateKF_01.m` code.

Code given by Prof. Okajima (In Example_MultirateKF) :
* `MultirateKF_01.m`: Core LMI optimization implementation for the multirate Kalman filter design (DARI formulation).
* `MultirateKF_02_eig.m`: Multi-objective design combining optimal Kalman filtering with eigenvalue placement constraints.
* `MultirateKF_03_l2.m`: Mixed design combining the Kalman filter with l2-induced norm constraints.
* `MultirateKF_Simple.m`: Simplified 1D version of the multirate filter for easy periodic testing.

## Reference & Original Research

This project builds upon the theoretical framework established by Prof. Hiroshi Okajima. For the full mathematical proofs and the core methodology, please refer to the original research:

* **Official Paper:** Okajima, H. "LMI Optimization Based Multirate Steady-State Kalman Filter Design," *IEEE Access* (2026). [Read on IEEE Xplore](https://ieeexplore.ieee.org/document/11460152)
* **Supervisor's Original Repository:** [Hiroshi-Okajima/multirate-kalman-filter](https://github.com/Hiroshi-Okajima/multirate-kalman-filter)
* **Theoretical Explanation (Blog):** [Control Engineering Blog](https://blog.control-theory.com/entry/multirate-kalman-filter-lmi)
