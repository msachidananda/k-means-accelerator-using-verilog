module kmeans_top #
(
    parameter K = 8,
    parameter D = 4,
    parameter W = 8,
    parameter N = 128
)
(
    input clk,
    input rst,
    input start,

    input signed [D*W-1:0] point_flat,
    input signed [K*D*W-1:0] init_centroid_flat,

    output done
);

    wire [$clog2(K)-1:0] cluster_id;
    wire valid, compute_mean, clear_acc, converged;
    wire [6:0] point_idx;

    reg signed [K*D*W-1:0] old_centroid_flat;
    wire signed [K*D*W-1:0] centroid_flat;

    always @(posedge clk)
        old_centroid_flat <= centroid_flat;

    distance_unit DU (
        .point_flat(point_flat),
        .centroid_flat(centroid_flat),
        .min_cluster(cluster_id)
    );

    mean_accumulator MA (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .clear(clear_acc),
        .compute_mean(compute_mean),
        
        // --- ADD THIS LINE ---
        .init_centroids(init_centroid_flat),
        // ---------------------
        
        .cluster_id(cluster_id),
        .point_flat(point_flat),
        .centroid_flat(centroid_flat)
    );

    centroid_compare CC (
        .old_c(old_centroid_flat),
        .new_c(centroid_flat),
        .converged(converged)
    );

    kmeans_fsm FSM (
        .clk(clk),
        .rst(rst),
        .start(start),
        .converged(converged),
        .valid(valid),
        .compute_mean(compute_mean),
        .clear_acc(clear_acc),
        .done(done),
        .point_idx(point_idx)
    );
endmodule
