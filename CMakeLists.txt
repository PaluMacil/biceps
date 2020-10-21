cmake_minimum_required(VERSION 3.17)
project(biceps CUDA)

set(CMAKE_CUDA_STANDARD 14)

add_executable(biceps main.cu)

set_target_properties(
        biceps
        PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)