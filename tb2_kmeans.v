`timescale 1ns/1ps

module tb_kmeans;

    parameter K = 8;
    parameter D = 4;
    parameter W = 8;
    parameter N = 128;

    reg clk, rst, start;
    reg signed [D*W-1:0] point_flat;
    reg signed [K*D*W-1:0] init_centroid_flat;

    wire done;
    wire signed [K*D*W-1:0] final_centroid_flat;
    wire [$clog2(K)-1:0] cluster_id;
    wire point_valid;

    integer i, k, d;
    integer fd;

    kmeans_top DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .point_flat(point_flat),
        .init_centroid_flat(init_centroid_flat),
        .done(done),
        .final_centroid_flat(final_centroid_flat),
        .cluster_id(cluster_id),
        .point_valid(point_valid)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        fd = $fopen("kmeans_results.txt", "w");

        clk = 0;
        rst = 1;
        start = 0;
        point_flat = 0;
        init_centroid_flat = 0;

        #20 rst = 0;

        // Initialize centroids
        for (i = 0; i < K*D; i = i + 1)
            init_centroid_flat[i*W +: W] = i;

        #10 start = 1;
        #10 start = 0;

        // Feed points
        for (i = 0; i < N; i = i + 1) begin
            point_flat = {i[7:0], i[7:0]+1, i[7:0]+2, i[7:0]+3};
            #10;

            if (point_valid) begin
                $fwrite(fd, "Point %0d assigned to Cluster %0d\n", i, cluster_id);
            end
        end

        wait(done);

        // Print final centroids
        $fwrite(fd, "\nFINAL CENTROIDS:\n");
        for (k = 0; k < K; k = k + 1) begin
            $fwrite(fd, "Cluster %0d : ", k);
            for (d = 0; d < D; d = d + 1) begin
                $fwrite(fd, "%0d ",
                    final_centroid_flat[(k*D+d)*W +: W]);
            end
            $fwrite(fd, "\n");
        end

        $fclose(fd);
        #20 $finish;
    end

endmodule
