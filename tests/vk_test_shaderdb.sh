#!/bin/bash
workBase=$(pwd)

git clone https://github.com/GPUOpen-Drivers/xgl.git
git clone https://github.com/GPUOpen-Drivers/pal.git
git clone https://github.com/GPUOpen-Drivers/llpc.git
git clone https://github.com/GPUOpen-Drivers/llvm.git
cd llvm && git checkout remotes/origin/amd-vulkan-dev -b amd-vulkan-dev
cd $workBase
git clone https://github.com/GPUOpen-Drivers/spvgen.git
cd spvgen && git checkout remotes/origin/dev -b dev

#build amdllpc
cd $workBase/xgl
cmake -H. -Brbuild64
cd rbuild64
make amdllpc -j4

#build spvgen
cd $workBase/spvgen/external/
python fetch_external_sources.py
cd ..
cmake -H. -Brbuild64 -DCMAKE_BUILD_TYPE=release -DXGL_LLPC_PATH=$workBase/llpc -DVULKAN_HEADER_PATH=$workBase/xgl/icd/api/include/khronos
cd rbuild64
make -j4

#run the test
cd $workBase/xgl/test/shadertest
python testShaders.py --gfxip gfx6 $workBase/xgl/rbuild64/llpc $workBase/spvgen/rbuild64/

