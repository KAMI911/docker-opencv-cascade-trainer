cd /opt
mkdir -p opencv-3.1.0/release
wget 'https://github.com/opencv/opencv/archive/3.1.0.zip'
unzip 3.1.0.zip
cd opencv-3.1.0/release
# cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_PYTHON_SUPPORT=ON -D WITH_XINE=ON -D WITH_TBB=ON ..
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D PYTHON3_EXECUTABLE=/usr/bin/python3.4 -D PYTHON_INCLUDE_DIR=/usr/include/python3.4 -D PYTHON_INCLUDE_DIR2=/usr/include/x86_64-linux-gnu/python3.4m/ -D PYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.4m.so -D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.4/dist-packages/numpy/core/include/ ..
make -j16 && make install
cd /
