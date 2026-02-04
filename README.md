# k-means-accelerator-using-verilog
This project implements a high-performance K-Means Clustering Hardware Accelerator in Verilog, designed to efficiently partition a dataset of 128, 4-dimensional points 8 bits each into 8 distinct clusters.
The system demonstrates advanced digital logic capabilities, including:
Parallel Distance Calculation: A dedicated distance_unit computes Euclidean distances between data points and centroids using a multi-stage combinational pipeline to determine the nearest cluster ID.
Dynamic Resource Management: The mean_accumulator tracks the count and coordinate sums of points assigned to each cluster, performing fixed-point division to calculate new centroid means.
Convergence Detection: A centroid_compare module evaluates structural stability by comparing bit-level changes between iteration cycles to trigger the completion signal.
Functional Working--
Upon receiving a start pulse, the FSM iterates through the dataset. During the ASSIGN state, it streams 128 points into the distance logic. Once all points are processed, it transitions to the UPDATE state to recalculate centroid positions. The system repeats this cycle automatically until the centroids stabilize (converge), at which point the done signal is asserted, signifying a completed clustering operation
Total cycles = 3840
Frequency = 100Mhz
Time = 3840/100*10^6 = 38.4µs (lesser by 68.6% than c)
c language - 100-200µs
python - 500µs
