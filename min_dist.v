module distance_unit #
(
    parameter K = 8,
    parameter D = 4,
    parameter W = 8
)
(
    input  signed [D*W-1:0] point_flat,
    input  signed [K*D*W-1:0] centroid_flat,
    output reg [$clog2(K)-1:0] min_cluster
);

    integer i, j;
    
    reg signed [W-1:0] point   [0:D-1];
    reg signed [W-1:0] centroid[0:K-1][0:D-1];
    reg signed [2*W+4:0] dist, min_dist;
    reg signed [2*W-1:0] diff;
    // Added pipeline registers
    
    reg signed [W:0] diff_p1 [0:K-1][0:D-1];
    reg signed [2*W+4:0] dist_p2 [0:K-1];

    
    // Unpack (combinational)
    
    always @(*) begin
        for (j = 0; j < D; j = j + 1)
            point[j] = point_flat[j*W +: W];

        for (i = 0; i < K; i = i + 1)
            for (j = 0; j < D; j = j + 1)
                centroid[i][j] = centroid_flat[(i*D + j)*W +: W];
    end

    
    // STAGE 1: Subtraction (PIPELINED)
    
    always @(*) begin
        for (i = 0; i < K; i = i + 1)
            for (j = 0; j < D; j = j + 1)
                diff_p1[i][j] = point[j] - centroid[i][j];
    end

    
    // STAGE 2: Square + Sum (PIPELINED)
    
    always @(*) begin
        for (i = 0; i < K; i = i + 1) begin
            dist_p2[i] =
                  diff_p1[i][0] * diff_p1[i][0]
                + diff_p1[i][1] * diff_p1[i][1]
                + diff_p1[i][2] * diff_p1[i][2]
                + diff_p1[i][3] * diff_p1[i][3];
        end
    end

        // STAGE 3: Minimum selection
    
    always @(*) begin
        min_dist    = dist_p2[0];
        min_cluster = 0;

        for (i = 1; i < K; i = i + 1) begin
            if (dist_p2[i] < min_dist) begin
                min_dist    = dist_p2[i];
                min_cluster = i[$clog2(K)-1:0];
            end
        end
    end

endmodule
