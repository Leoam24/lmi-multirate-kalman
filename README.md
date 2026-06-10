# lmi-multirate-kalman

> LMI-based multirate Kalman filter synthesis. Research conducted at Kumamoto University (Japan) on discrete-time systems.

## About this project

This repository contains the MATLAB implementations developed during my research internship at **Kumamoto University (Japan)**, under the supervision of Prof. Hiroshi Okajima. 

The project focuses on **observer synthesis for discrete-time systems using LMI (Linear Matrix Inequality) optimization**. The main objective is to design a steady-state **multirate Kalman filter**. 

Through a cyclic reformulation of the system, the code enables the fusion of data from sensors operating at different frequencies (e.g., a 1 Hz GPS and a 10 Hz wheel speed sensor) while guaranteeing robust performance criteria (regional eigenvalue placement, l2-induced norm). This approach allows for the offline computation of optimal observer gains, thereby significantly reducing the computational load for embedded systems.
