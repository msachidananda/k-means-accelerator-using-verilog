module mean_accumulator #
(
    parameter K = 8,
    parameter D = 4,
    parameter W = 8
)
(
    input clk,
    input rst,
    input valid,
    input clear,
    input compute_mean,
    
    // NEW PORT: Input for initialization
    input signed [K*D*W-1:0] init_centroids, 

    input [$clog2(K)-1:0] cluster_id,
    input signed [D*W-1:0] point_flat,

    output reg signed [K*D*W-1:0] centroid_flat
);

    integer i,j;
    reg signed [W-1:0] point[0:D-1];
    reg signed [W+7:0] sum[0:K-1][0:D-1];
    reg [7:0] count[0:K-1];

    // Unpack the point
    always @(*) begin
        for (j=0;j<D;j=j+1)
            point[j] = point_flat[j*W +: W];
    end

    always @(posedge clk) begin
        if (rst) begin
            // 1. HARD RESET: Load initial values from outside
            centroid_flat <= init_centroids; 
            
            // Clear accumulators
            for (i=0;i<K;i=i+1) begin
                count[i] <= 0;
                for (j=0;j<D;j=j+1)
                    sum[i][j] <= 0;
            end
        end
        else if (clear) begin
            // 2. ITERATION CLEAR: Only clear accumulators
            // Do NOT reset centroid_flat here (we need it for the next pass)
            for (i=0;i<K;i=i+1) begin
                count[i] <= 0;
                for (j=0;j<D;j=j+1)
                    sum[i][j] <= 0;
            end
        end
        else if (valid) begin       
            // 3. ACCUMULATE
            count[cluster_id] <= count[cluster_id] + 1;
            for (j=0;j<D;j=j+1)
                sum[cluster_id][j] <= sum[cluster_id][j] + point[j];
        end
        else if (compute_mean) begin   
            // 4. UPDATE CENTROIDS (DIVIDE)
            for (i=0;i<K;i=i+1)
                for (j=0;j<D;j=j+1)
                    if (count[i] != 0)
                        centroid_flat[(i*D+j)*W +: W] <= sum[i][j] / count[i];
        end
    end
endmodule