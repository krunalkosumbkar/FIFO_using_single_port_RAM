Single-Port BRAM FIFO (2× FSM Controlled)








A lightweight, resource-efficient FIFO implemented using single-port BRAM and a 2× frequency FSM to enable effective same-cycle read/write behavior. Designed for area-optimized FPGA/ASIC systems.


📝 Overview

This project implements a synchronous FIFO using single-port BRAM combined with a high-frequency FSM to simulate dual-port behavior.
The primary objective is to reduce on-chip memory usage while maintaining performance comparable to a true dual-port FIFO.

⚙️ Design Approach

The FIFO uses a single-port BRAM and an FSM clocked at 2× the user frequency:

- Write phase (first half-cycle)

- Read phase (second half-cycle)

From the user’s perspective, both push and pop appear to occur in the same clock cycle, effectively mimicking dual-port behavior.

Key Features

1. Single-port BRAM based

2. 2× FSM for alternating read/write

3. Gray-coded pointers for glitch-free comparison

4. User-perceived simultaneous read & write

5. Low resource usage

6. Clean timing control
   
7. Save on-chip area for given density without affecting performance

📐 Architecture



<img width="1680" height="1027" alt="fifo block diagram (1)" src="https://github.com/user-attachments/assets/e7a39dd2-b2ec-431f-9091-a3fa62a27144" />


FSM Block Diagram



<img width="740" height="720" alt="fsm fifo" src="https://github.com/user-attachments/assets/52fd5d57-32df-4acf-9a5b-59214ce07e2c" />

