# K-Means Accelerator using Verilog

## 📌 Overview
This project presents a **high-performance hardware implementation of the K-Means Clustering algorithm** using Verilog. The design accelerates clustering of a dataset consisting of **128 data points**, each having **4 dimensions with 8-bit precision**, into **8 clusters**.

The implementation leverages **parallel computation, efficient resource management, and hardware-level optimization** to significantly outperform traditional software-based approaches.

---

## 🚀 Key Features

- **Parallel Distance Computation**
  - Uses a dedicated `distance_unit` module
  - Computes Euclidean distance between data points and centroids
  - Multi-stage combinational pipeline for high throughput

- **Dynamic Mean Calculation**
  - `mean_accumulator` module tracks:
    - Cluster-wise point count
    - Sum of coordinates
  - Performs fixed-point division to compute updated centroids

- **Convergence Detection**
  - `centroid_compare` module checks:
    - Bit-level changes in centroids across iterations
  - Triggers termination when centroids stabilize

- **Finite State Machine (FSM) Control**
  - Manages clustering workflow
  - Ensures synchronized operation of all modules

---

## 🧠 System Architecture

The system is composed of the following major modules:

### 1. `top_module.v`
- Acts as the **main controller**
- Instantiates all submodules
- Contains FSM for controlling clustering process

### 2. `distance_unit.v`
- Computes **Euclidean distance** between:
  - Input data point
  - All cluster centroids
- Outputs:
  - Minimum distance
  - Corresponding cluster ID
- Uses **parallel arithmetic units** for fast computation

### 3. `mean_accumulator.v`
- Maintains:
  - Sum of coordinates for each cluster
  - Count of points per cluster
- Performs:
  - Fixed-point division to compute new centroid
- Ensures efficient memory and arithmetic usage

### 4. `centroid_compare.v`
- Compares:
  - Previous centroids
  - Updated centroids
- Detects convergence based on **bit-level equality**
- Outputs a `done` signal when clustering stabilizes

### 5. `fsm_controller.v` (if separate)
- Controls system states:
  - `IDLE`
  - `ASSIGN`
  - `UPDATE`
  - `CHECK`
- Generates control signals for module coordination

### 6. `memory_block.v` (if used)
- Stores:
  - Input dataset
  - Centroid values
- Enables sequential data streaming

---

## ⚙️ Working Principle

1. **Initialization**
   - System waits in `IDLE` state
   - On receiving a `start` signal, begins clustering

2. **ASSIGN State**
   - Streams all **128 data points**
   - Each point is passed to `distance_unit`
   - Closest centroid is determined
   - Cluster assignment is stored

3. **UPDATE State**
   - `mean_accumulator` computes:
     - New centroid positions
   - Uses accumulated sums and counts

4. **CHECK State**
   - `centroid_compare` verifies convergence
   - If centroids unchanged → `done = 1`
   - Else → repeat from ASSIGN state

5. **Termination**
   - System stops when convergence is achieved

---

## ⏱️ Performance Analysis

| Implementation | Execution Time |
|---------------|--------------|
| Verilog (Hardware) | **38.4 µs** |
| C Language | 100–200 µs |
| Python | ~500 µs |

### Calculation:
