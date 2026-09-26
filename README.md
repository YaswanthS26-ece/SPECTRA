# SPECTRA — Speed & Power Efficient Compact Technology for Resource-Aware Applications

Welcome to **SPECTRA**.

SPECTRA is a reusable, adaptive power-management IP that dynamically manages the power states of functional hardware blocks (like the CPU, Sensors, and Radios). It operates based on battery conditions, system activity, workload, and emergency situations—aimed at extending battery life and reducing unnecessary energy usage while maintaining required performance for Edge-AI and SoC platforms.

> **Tagline:** High Performance. Low Power. Compact Design.

---

## 🚀 Repository Structure

This repository is structured cleanly for easy replication, synthesis in Vivado, and FPGA prototyping. 

```text
SPECTRA/
├── README.md               # You're reading this! Project overview and guide.
├── src/
│   └── spectra_power_mgmt.v # Core RTL (Verilog) for the Phase 2 controller.
├── tb/
│   └── tb_spectra.v         # Testbench for verifying FSM logic in XSim or ModelSim.
├── constraints/
│   └── zedboard.xdc         # Xilinx XDC constraints file for ZedBoard FPGA.
└── docs/                   # (Optional) For block diagrams, PPTs, LTSpice files, etc.
```

## ⚙️ Architecture & Features (Phase 2)

Currently, the default code reflects **Phase 2: Workload-Aware Power Management**. 

**Core “Intelligence” Features:**
1. **Inactivity Counter:** Automatically transitions to SLEEP when no workload is demanded for a specified number of clock cycles.
2. **Multi-Level Battery Sensing:** Operates contextually under NORMAL, LOW, or CRITICAL battery thresholds.
3. **Independent Block Control:** Precisely activates only what is requested (CPU, Sensor, Radio) to eliminate leakage/dynamic power waste.
4. **Emergency Override:** A dedicated state for safety-critical situations, overriding all power-saving policies to keep systems fully powered.
5. **Workload Awareness:** Distinguishes between what blocks need to be on rather than basic ON/OFF binary states.

## 🛠️ Getting Started (How to Run on Vivado)

1. **Clone the Repo:**
   ```bash
   git clone https://github.com/your-username/SPECTRA.git
   ```
2. **Create a Vivado Project:**
   - Launch Vivado.
   - Create a new RTL Project.
   - Select the target board (e.g., ZedBoard Zynq-7000 ARM/FPGA SoC Evaluation Board).
3. **Add Sources:**
   - Add `src/spectra_power_mgmt.v` as a Design Source.
   - Add `tb/tb_spectra_power_mgmt.v` as a Simulation Source.
   - Add `constraints/zedboard.xdc` as a Constraint Source.
4. **Simulate:**
   - Run Behavioral Simulation to view the waveforms and state transitions (NORMAL -> SLEEP -> LOW POWER -> EMERGENCY).
5. **Synthesize & Implement:**
   - Run Synthesis, then Implementation.
   - Generate Bitstream.
   - Program the FPGA.

## 📌 ZedBoard Hardware Mapping

For prototyping, the I/O connects to onboard elements:

- **Inputs (Switches):**
  - `clk` -> `Y9`
  - `rst_n` -> `H17`
  - `battery_level (2 bits)` -> `F22, G22`
  - `cpu/sensor/radio_req` -> `F21, M15, H18`
  - `emergency` -> `H19`
- **Outputs (LEDs):**
  - `cpu_enable`, `sensor_enable`, `radio_enable` -> `T22, T21, U22`
  - `power_state (2 bits debug)` -> `U21, V22`

## 🔮 Future Phases Roadmap

- **Phase 3:** Clock/Power Gating & Multi-Power Domain Management
- **Phase 4:** Dynamic Voltage & Frequency Scaling (DVFS) & PPA Optimization
- **Phase 5:** Final ASIC-ready Edge-AI / SoC Integration
