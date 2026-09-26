// =====================================================================
// tb_spectra_power_mgmt.v
// Testbench for SPECTRA controller
// Run in Vivado simulator (or any Verilog sim) and inspect the waveform
// =====================================================================
`timescale 1ns/1ps

module tb_spectra_power_mgmt;

    reg        clk;
    reg        rst_n;
    reg  [1:0] battery_level;
    reg        cpu_activity;
    reg        sensor_req;
    reg        radio_req;
    reg        emergency;

    wire       cpu_enable;
    wire       sensor_enable;
    wire       radio_enable;
    wire [1:0] power_state;

    // Small threshold for fast simulation
    spectra_power_mgmt #(.INACTIVITY_THRESHOLD(8'd10)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .battery_level(battery_level),
        .cpu_activity(cpu_activity),
        .sensor_req(sensor_req),
        .radio_req(radio_req),
        .emergency(emergency),
        .cpu_enable(cpu_enable),
        .sensor_enable(sensor_enable),
        .radio_enable(radio_enable),
        .power_state(power_state)
    );

    // 10ns clock period
    always #5 clk = ~clk;

    task print_status(input [127:0] label);
        begin
            $display("[%0t] %-28s state=%0d cpu=%b sensor=%b radio=%b",
                       $time, label, power_state, cpu_enable, sensor_enable, radio_enable);
        end
    endtask

    initial begin
        // Init
        clk = 0; rst_n = 0;
        battery_level = 2'b10; // NORMAL
        cpu_activity = 0; sensor_req = 0; radio_req = 0; emergency = 0;
        #12 rst_n = 1;

        // 1) Normal battery, active workload -> S_ACTIVE
        cpu_activity = 1; sensor_req = 1; radio_req = 1;
        #40 print_status("Normal + full workload");

        // 2) No workload for a while -> inactivity timeout -> S_SLEEP
        cpu_activity = 0; sensor_req = 0; radio_req = 0;
        #150 print_status("After inactivity timeout");

        // 3) Wake it up, then drop battery to LOW -> S_LOW_POWER (radio cut)
        cpu_activity = 1; sensor_req = 1; radio_req = 1;
        #20;
        battery_level = 2'b01; // LOW
        #40 print_status("Low battery + workload");

        // 4) Battery goes CRITICAL -> forced S_SLEEP regardless of activity
        battery_level = 2'b00; // CRITICAL
        #40 print_status("Critical battery");

        // 5) Emergency asserted -> overrides everything, all blocks on
        emergency = 1;
        #40 print_status("Emergency override");

        // 6) Emergency clears, battery back to normal -> returns to normal policy
        emergency = 0;
        battery_level = 2'b10;
        cpu_activity = 1;
        #40 print_status("Back to normal after emergency");

        #50 $display("Simulation complete.");
        $finish;
    end

endmodule
