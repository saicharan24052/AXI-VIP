# AXI4 Verification IP (VIP)

A reusable **AXI4 Verification IP (VIP)** developed in **SystemVerilog** and **UVM** for verifying AXI4-compliant designs. The project currently includes configurable AXI Master and Slave UVM agents, protocol assertions, transaction monitoring, and scoreboard-based verification, with additional commercial VIP features under development.

---

## Features

- AXI4 Master UVM Agent
- AXI4 Slave UVM Agent
- Configurable drivers, sequencers, and monitors
- Common AXI transaction class
- Transaction-level and Channel-Level monitoring
- Scoreboard for Master–Slave data comparison
- SystemVerilog Assertions (SVA) for protocol checking
- Modular and reusable UVM architecture

---

## Project Structure

```
axi_vip/
├── interface/          # AXI interface
├── master_agent/       # Master driver, monitor, sequencer
├── slave_agent/        # Slave driver, monitor, sequencer
├── sequence/           # AXI sequences
├── transaction/        # AXI transaction class
├── env/                # UVM environment
├── test/               # UVM tests
├── scoreboard/         # Transaction comparison
└── top/                # Top-level testbench
```

## Project Status

🚧 **Work in Progress**

**Currently in active development.** New features and enhancements are being added to evolve the project into a near-commercial AXI4 Verification IP.

### Current Implementation
- Master Agent
- Slave Agent
- Driver
- Sequencer
- Monitor
- AXI Transaction Class
- Scoreboard
- Interface-based Assertions
- Random Backpressure
- Channel-Level and Transaction-Level monitoring


---

## Technologies

- SystemVerilog
- UVM
- AXI4 Protocol
- SystemVerilog Assertions (SVA)
- QuestaSim and Visualizer™ Debug Environment 
---


## Simulation

### Prerequisites

- Siemens **QuestaSim** with SystemVerilog and UVM support.
- Siemens **Visualizer™ Debug Environment**

### Running the Simulation

1. Download or clone the repository.
2. Place all project files in a single working directory.
3. Open the project folder.
4. Start the simulation by **double-clicking the provided `.do` file**.
5. The script will automatically:
   - Create the required simulation library.
   - Compile all source files and optimize.
   - Launch the simulation in Visualizer™ Debug Environment.

> **Note:** The provided `.do` file is configured for the **Visualizer™ Debug Environment**. To run the project using **QuestaSim only**, minor modifications to the simulation script may be required.



---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Author

**C. Sai Charan**

