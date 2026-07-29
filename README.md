# AXI4 Verification IP (VIP)

A reusable **AXI4 Verification IP (VIP)** developed in **SystemVerilog** and **UVM** for verifying AXI4-compliant designs. The project currently includes configurable AXI Master and Slave UVM agents, protocol assertions, transaction monitoring, and scoreboard-based verification, with additional commercial VIP features under development.

---

## Features

- AXI4 Master UVM Agent
- AXI4 Slave UVM Agent
- Configurable drivers, sequencers, and monitors
- Common AXI transaction class
- Transaction-level monitoring
- Scoreboard for Master–Slave transaction comparison
- SystemVerilog Assertions (SVA) for protocol checking
- Modular and reusable UVM architecture

---

## Project Structure

```
axi_vip/
├── rtl/                # AXI interface
├── master_agent/       # Master driver, monitor, sequencer
├── slave_agent/        # Slave driver, monitor, sequencer
├── sequence/           # AXI sequences
├── transaction/        # AXI transaction class
├── env/                # UVM environment
├── test/               # UVM tests
├── scoreboard/         # Transaction comparison
├── assertions/         # AXI protocol assertions
└── tb/                 # Top-level testbench
```

---

## Current Status

### Implemented
- Master Agent
- Slave Agent
- Driver
- Sequencer
- Monitor
- AXI Transaction Class
- Scoreboard
- Interface-based Assertions

### Planned
- Functional Coverage
- Memory Model
- Outstanding Transaction Tracking
- Channel-Level Transaction Reconstruction
- AXI Protocol Reference Model
- Error Injection
- Random Backpressure
- Validation with Real AXI RTL Designs

---

## Technologies

- SystemVerilog
- UVM
- AXI4 Protocol
- SystemVerilog Assertions (SVA)
- QuestaSim / ModelSim

---

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/<username>/axi_vip.git
```

2. Compile the project using your simulator.

3. Run the desired UVM test.

---

## Future Goals

This project aims to evolve into a near-commercial AXI4 Verification IP by incorporating advanced protocol checking, comprehensive functional coverage, configurable components, and interoperability testing with real AXI RTL implementations.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Author

**C. Sai Charan**

M.Tech – VLSI & Embedded Systems  
SystemVerilog | UVM | RTL Design | Design Verification
