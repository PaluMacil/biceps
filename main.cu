// Dan Wolf

#include <iostream>
#include <string>
#include <chrono>

// https://stackoverflow.com/questions/14038589/what-is-the-canonical-way-to-check-for-errors-using-the-cuda-runtime-api/14038590#14038590
#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
    if (code != cudaSuccess)
    {
        fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
        if (abort) exit(code);
    }
}

__global__ void multMat(int n, int *arrForce_d, int *arrDistance_d, int *arrAnswer_d) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n){
        arrAnswer_d[i] = arrForce_d[i] * arrDistance_d[i];
    }
}

int main(int argc, char **argv) {
    auto n = atoi(argv[1]);
    size_t bytes = n* sizeof(int);

    // host pointers
    int* arrForce;
    int* arrDistance;
    int* arrAnswer;

    // device pointers
    int* arrForce_d;
    int* arrDistance_d;
    int* arrAnswer_d;

    // allocate on host
    arrForce = (int*)malloc(bytes);
    arrDistance = (int*)malloc(bytes);
    arrAnswer = (int*)malloc(bytes);
    // initialize on host, at n=16, this initializes to
    // (1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2)
    // (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 1, 2, 3, 4, 5)
    // Answer: 1 + 4 + 9 + 16 + 25 + 36 + 49 + 64 + 81 + 80 + 77 + 6 + 10 + 12 + 12 + 10 = 492
    int forceValue = 1;
    int distanceValue = 0;
    for (int i = 0; i < n; i++){
        arrForce[i] = forceValue;
        if (i < n/2) {
            forceValue = forceValue + 1;
        } else {
            forceValue = forceValue - 1;
        }

        distanceValue = distanceValue > 10 ? distanceValue - 10 : distanceValue + 1;
        arrDistance[i] = distanceValue;
    }

    // allocate on device

    // print
    std::cout << "force: ";
    for (int i = 0; i < n; i++){
        std::cout << arrForce[i] << " ";
    }
    std::cout << '\n' << "dist: ";
    for (int i = 0; i < n; i++){
        std::cout << arrDistance[i] << " ";
    }

    std::chrono::high_resolution_clock::time_point t1 = std::chrono::high_resolution_clock::now();
    // if more than the number of elements is passed in, don't use the gpu
    if (argc > 2) {
        std::cout << '\n' << "using CPU" << '\n';
        for (int i = 0; i < n; i++) {
            arrAnswer[i] = arrForce[i] * arrDistance[i];
        }
    } else {
        std::cout << '\n' << "using GPU" << '\n';
        const int BLOCK_SIZE = 1024;
        dim3 dimBlock (BLOCK_SIZE);
        dim3 dimGrid = (int)ceil((float)n / BLOCK_SIZE);

        gpuErrchk(cudaMalloc(&arrForce_d, bytes));
        gpuErrchk(cudaMalloc(&arrDistance_d, bytes));
        gpuErrchk(cudaMalloc(&arrAnswer_d, bytes));

        gpuErrchk(cudaMemcpy(arrForce_d, arrForce, bytes, cudaMemcpyHostToDevice));
        gpuErrchk(cudaMemcpy(arrDistance_d, arrDistance, bytes, cudaMemcpyHostToDevice));
        gpuErrchk(cudaMemcpy(arrAnswer_d, arrAnswer, bytes, cudaMemcpyHostToDevice));

        multMat<<<dimGrid, dimBlock>>>(n, arrForce_d, arrDistance_d, arrAnswer_d);
        gpuErrchk(cudaPeekAtLastError());

        gpuErrchk(cudaMemcpy(arrAnswer, arrAnswer_d, bytes, cudaMemcpyDeviceToHost));

        gpuErrchk(cudaFree(arrForce_d))
        gpuErrchk(cudaFree(arrDistance_d))
        gpuErrchk(cudaFree(arrAnswer_d))
    }
    std::chrono::high_resolution_clock::time_point t2 = std::chrono::high_resolution_clock::now();

    int total = 0;
    for (int i = 0; i < n; i++) {
        total = total + arrAnswer[i];
    }
    std::cout << "answer: " << total << '\n' << '\n';
    std::cout << "time for calculation: " << (t2 - t1).count() << "ns";

    return 0;
}
