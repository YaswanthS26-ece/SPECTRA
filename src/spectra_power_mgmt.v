// =====================================================================
// spectra_power_mgmt.v
// SPECTRA - Speed & Power Efficient Compact Technology for Resource-Aware Applications
// Phase 2 - Workload-Aware Power Management
//
// Features:
//   1. Inactivity counter -> auto transition to SLEEP
//   2. Multi-level battery (NORMAL / LOW / CRITICAL)
//   3. Individual block control (CPU / SENSOR / RADIO)
//   4. Emergency mode (overrides everything)
//   5. Workload awareness (sensor/radio requests count as activity)
// =====================================================================

module spectra_power_mgmt #(
    parameter INACTIVITY_THRESHOLD = 8'd50   // clk cycles of no activity -> sleep
) (
    input  wire       clk,
    input  wire       rst_n,

    // Battery status: 2'b10 = NORMAL, 2'b01 = LOW, 2'b00 = CRITICAL
    input  wire [1:0] battery_level,

    // Workload / activity inputs
    input  wire       cpu_activity,     // general activity pulse
    input  wire       sensor_req,       // sensor block wants to run
    input  wire       radio_req,        // radio block wants to run

    // Priority override
    input  wire       emergency,        // asserted -> force full power, ignore policy

    // Block enables
    output reg        cpu_enable,
    output reg        sensor_enable,
    output reg        radio_enable,

    // For LEDs / debug: 00=ACTIVE 01=LOW_POWER 10=SLEEP 11=EMERGENCY
    output reg  [1:0] power_state
);

    // ---------------- Battery level encoding ----------------
    localparam BATT_CRITICAL = 2'b00;
    localparam BATT_LOW      = 2'b01;
    localparam BATT_NORMAL   = 2'b10;

    // ---------------- FSM states ----------------
    localparam S_ACTIVE     = 2'b00;
    localparam S_LOW_POWER  = 2'b01;
    localparam S_SLEEP      = 2'b10;
    localparam S_EMERGENCY  = 2'b11;

    reg [1:0] state, next_state;

    // ---------------- Workload detection ----------------
    // Any request (CPU, sensor, radio) counts as "activity" -> resets inactivity timer
    wire workload = cpu_activity | sensor_req | radio_req;

    // ---------------- Inactivity counter ----------------
    reg [7:0] inactivity_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            inactivity_cnt <= 8'd0;
        else if (workload)
            inactivity_cnt <= 8'd0;               // reset on any activity
        else if (inactivity_cnt < INACTIVITY_THRESHOLD)
            inactivity_cnt <= inactivity_cnt + 1'b1; // saturate at threshold
    end

    wire inactivity_timeout = (inactivity_cnt >= INACTIVITY_THRESHOLD);

    // ---------------- State register ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_ACTIVE;
        else
            state <= next_state;
    end

    // ---------------- Next-state logic ----------------
    always @(*) begin
        // Emergency always wins, regardless of battery or activity
        if (emergency) begin
            next_state = S_EMERGENCY;
        end
        else if (battery_level == BATT_CRITICAL) begin
            next_state = S_SLEEP;                  // critical battery forces sleep
        end
        else if (inactivity_timeout) begin
            next_state = S_SLEEP;                  // long idle -> sleep
        end
        else if (battery_level == BATT_LOW) begin
            next_state = S_LOW_POWER;               // low battery -> reduced power
        end
        else if (workload) begin
            next_state = S_ACTIVE;                  // normal battery + activity
        end
        else begin
            next_state = state;                     // hold current state otherwise
        end
    end

    // ---------------- Output logic ----------------
    always @(*) begin
        power_state = state;

        case (state)
            S_EMERGENCY: begin
                // Force everything on - safety/critical operation
                cpu_enable    = 1'b1;
                sensor_enable = 1'b1;
                radio_enable  = 1'b1;
            end

            S_ACTIVE: begin
                // Full functionality, but still only enable blocks that are requested
                cpu_enable    = 1'b1;
                sensor_enable = sensor_req;
                radio_enable  = radio_req;
            end

            S_LOW_POWER: begin
                // Keep CPU + sensor alive if requested, radio is the biggest power hog -> cut it
                cpu_enable    = 1'b1;
                sensor_enable = sensor_req;
                radio_enable  = 1'b0;
            end

            S_SLEEP: begin
                // Everything off; a new request will pull us out via workload/timeout logic
                cpu_enable    = 1'b0;
                sensor_enable = 1'b0;
                radio_enable  = 1'b0;
            end

            default: begin
                cpu_enable    = 1'b0;
                sensor_enable = 1'b0;
                radio_enable  = 1'b0;
            end
        endcase
    end

endmodule
