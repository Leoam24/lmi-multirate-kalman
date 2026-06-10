# lmi-multirate-kalman

> LMI-based multirate Kalman filter synthesis. Research conducted at Kumamoto University (Japan) on discrete-time systems.

## About this project

This repository contains the MATLAB implementations developed during my research internship at **Kumamoto University (Japan)**, under the supervision of Prof. Hiroshi Okajima. 

The project focuses on **observer synthesis for discrete-time systems using LMI (Linear Matrix Inequality) optimization**. The main objective is to design a steady-state **multirate Kalman filter**. 

Through a cyclic reformulation of the system, the code enables the fusion of data from sensors operating at different frequencies (e.g., a 1 Hz GPS and a 10 Hz wheel speed sensor) while guaranteeing robust performance criteria (regional eigenvalue placement, l2-induced norm). This approach allows for the offline computation of optimal observer gains, thereby significantly reducing the computational load for embedded systems.

## Reference & Original Research

This project builds upon the theoretical framework established by Prof. Hiroshi Okajima. For the full mathematical proofs and the core methodology, please refer to the original research:
* **Official Paper:** Okajima, H. "LMI Optimization Based Multirate Steady-State Kalman Filter Design," *IEEE Access* (2026). [Read on IEEE Xplore](https://ieeexplore.ieee.org/document/11460152)
* **Supervisor's Original Repository:** [Hiroshi-Okajima/multirate-kalman-filter](https://github.com/Hiroshi-Okajima/multirate-kalman-filter)
* **Theoretical Explanation (Blog):** [Control Engineering Blog](https://blog.control-theory.com/entry/multirate-kalman-filter-lmi)
