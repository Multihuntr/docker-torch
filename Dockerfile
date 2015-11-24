# Base this image on the Cuda Ubuntu 14.04 image from nvidia-docker.
# You can build yours by following the instructions at
# https://github.com/NVIDIA/nvidia-docker
FROM cuda

# Alternatively, if you don't need cutorch then you can base this image on the
# stock Ubuntu image
# FROM ubuntu:14.04

# Install Python, Jupyter and build tools
RUN apt-get update \
    && apt-get install -y python3 python3-setuptools python3-dev \
    build-essential git
RUN easy_install3 pip \
    && pip install jupyter

# Install OpenBLAS
RUN git clone https://github.com/xianyi/OpenBLAS.git /tmp/OpenBLAS \
    && cd /tmp/OpenBLAS \
    && make NO_AFFINITY=1 USE_OPENMP=1 \
    && make install \
    && rm -rf /tmp/OpenBLAS

# Install Torch
RUN apt-get update \
    && apt-get install -y cmake curl unzip libreadline-dev libjpeg-dev \
    libpng-dev ncurses-dev imagemagick gnuplot gnuplot-x11 libssl-dev \
    libzmq3-dev
RUN git clone https://github.com/torch/distro.git ~/torch --recursive \
    && cd ~/torch \
    && ./install.sh

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/root/torch/install/share/lua/5.1/?.lua;/root/torch/install/share/lua/5.1/?/init.lua;./?.lua;/root/torch/install/share/luajit-2.1.0-alpha/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' \
    LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/root/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so' \
    PATH=/root/torch/install/bin:$PATH \
    LD_LIBRARY_PATH=/root/torch/install/lib:$LD_LIBRARY_PATH \
    DYLD_LIBRARY_PATH=/root/torch/install/lib:$DYLD_LIBRARY_PATH

# Install LuaSocket - mainly because socket.gettime() is handy
RUN luarocks install luasocket

# Set working dir
VOLUME /root/notebook
WORKDIR /root/notebook

# Expose Jupyter port
EXPOSE 8888

CMD ["jupyter", "notebook", "--no-browser", "--ip=0.0.0.0"]