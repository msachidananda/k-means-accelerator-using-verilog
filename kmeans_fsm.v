module kmeans_fsm #
(
    parameter N = 128
)
(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire        converged,

    output reg         valid,
    output reg         compute_mean,
    output reg         clear_acc,
    output reg         done,
    output reg  [6:0]  point_idx
);

    // FSM states
    localparam IDLE   = 2'd0,
               ASSIGN = 2'd1,
               UPDATE = 2'd2,
               CHECK  = 2'd3;

    reg [1:0] state, next_state;

    // -------------------------------
    // STATE REGISTER
    // -------------------------------
    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            point_idx <= 0;
        end else begin
            state <= next_state;

            // point index control
            if (state == IDLE && start)
                point_idx <= 0;
            else if (state == ASSIGN) begin
                if (point_idx < N-1)
                    point_idx <= point_idx + 1;
                else point_idx <= 0;    
            end
            else if (state == CHECK && !converged)
                point_idx <= 0;   // 🔥 critical fix
        end
    end

    // -------------------------------
    // NEXT STATE LOGIC
    // -------------------------------
    always @(*) begin
        next_state = state;
        case (state)

            IDLE: begin
                if (start)
                    next_state = ASSIGN;
            end

            ASSIGN: begin
                if (point_idx == N-1)
                    next_state = UPDATE;
                else next_state = ASSIGN;    
            end

            UPDATE: begin
                next_state = CHECK;
            end

            CHECK: begin
                if (converged)
                    next_state = IDLE;
                else
                    next_state = ASSIGN;
            end

        endcase
    end

    // -------------------------------
    // OUTPUT CONTROL LOGIC
    // -------------------------------
    always @(*) begin
        // defaults
        valid        = 0;
        compute_mean = 0;
        clear_acc    = 0;
        done         = 0;

        case (state)

            ASSIGN: begin
                valid = 1;          // distance computation active
            end

            UPDATE: begin
                compute_mean = 1;   // centroid update
            end

            CHECK: begin
                clear_acc = ~converged;
                done      = converged; // done pulses ONLY when converged
            end

        endcase
    end

endmodule
