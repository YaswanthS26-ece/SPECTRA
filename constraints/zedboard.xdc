# =====================================================================
# zedboard.xdc
# Pin assignments for ZedBoard (xc7z020)
# SPECTRA Phase 2 Implementation
# =====================================================================

# Inputs (Switches)
set_property PACKAGE_PIN F22 [get_ports {battery_level[1]}]
set_property PACKAGE_PIN G22 [get_ports {battery_level[0]}]
set_property PACKAGE_PIN Y9  [get_ports clk]
set_property PACKAGE_PIN F21 [get_ports cpu_activity]
set_property PACKAGE_PIN H19 [get_ports emergency]
set_property PACKAGE_PIN H18 [get_ports radio_req]
set_property PACKAGE_PIN H17 [get_ports rst_n]
set_property PACKAGE_PIN M15 [get_ports sensor_req]

# Outputs (LEDs)
set_property PACKAGE_PIN T22 [get_ports cpu_enable]
set_property PACKAGE_PIN T21 [get_ports radio_enable]
set_property PACKAGE_PIN U22 [get_ports sensor_enable]

# State LEDs
set_property PACKAGE_PIN U21 [get_ports {power_state[1]}]
set_property PACKAGE_PIN V22 [get_ports {power_state[0]}]

# IO Standards - Inputs
set_property IOSTANDARD LVCMOS33 [get_ports {battery_level[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {battery_level[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports cpu_activity]
set_property IOSTANDARD LVCMOS33 [get_ports emergency]
set_property IOSTANDARD LVCMOS33 [get_ports radio_req]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_req]

# IO Standards - Outputs
set_property IOSTANDARD LVCMOS33 [get_ports cpu_enable]
set_property IOSTANDARD LVCMOS33 [get_ports radio_enable]
set_property IOSTANDARD LVCMOS33 [get_ports sensor_enable]
set_property IOSTANDARD LVCMOS33 [get_ports {power_state[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {power_state[0]}]
