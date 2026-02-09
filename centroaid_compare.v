module centroid_compare #
(
    parameter K = 8,
    parameter D = 4,
    parameter W = 8
)
(
    input  signed [K*D*W-1:0] old_c,
    input  signed [K*D*W-1:0] new_c,
    output reg converged
);

    integer i;

    always @(*) begin
        converged = 1;
        for (i=0;i<K*D;i=i+1)
            if (old_c[i*W +: W] != new_c[i*W +: W])
                converged = 0;
    end
endmodule
