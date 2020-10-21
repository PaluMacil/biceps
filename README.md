# Biceps

This is merely a simple dot matrix multiplication in order to demonstrate a 
dot product of two vectors in parallel over an Nvidia card with CUDA cores.

## Install

You need the `nvcc` compiler which wraps GCC. The version available might 
not support the lastest GCC on your system, but you can install multiple 
versions and switch between them as needed. In my case, I'm on Ubuntu 20.04 
and will use the nvcc available in the repos as well as gcc 7.

```
sudo apt install nvidia-cuda-toolkit

sudo apt install build-essential
sudo apt -y install gcc-7 g++-7 gcc-8 g++-8 gcc-9 g++-9

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
```

Using `sudo update-alternatives --config gcc` (and g++) you can set the 
versions used. Check them with `gcc --version`, `g++ --version`, and 
`nvcc --version`.
