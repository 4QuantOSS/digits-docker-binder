# Start with Ubuntu base image
FROM ubuntu:14.04
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Install git, wget, bc, cmake and dependencies
RUN apt-get update && apt-get install -y \
  git \
  wget \
  bc \
  cmake \
  libgflags-dev \
  libgoogle-glog-dev \
  libopencv-dev \
  libleveldb-dev \
  libsnappy-dev \
  liblmdb-dev \
  libhdf5-serial-dev \
  libprotobuf-dev \
  protobuf-compiler \
  libatlas-base-dev \
  python-dev \
  python-pip \
  python-numpy \
  gfortran
# Install boost
RUN apt-get install -y --no-install-recommends libboost-all-dev

# Clone NVIDIA Caffe repo and move into it
RUN cd /root && git clone https://github.com/NVIDIA/caffe.git && cd caffe && \
# Install python dependencies
  cat python/requirements.txt | xargs -n1 pip install
MAINTAINER Kai Arulkumaran <design@kaixhin.com>

# Move into NVIDIA Caffe repo
RUN cd /root/caffe && \
# Make and move into build directory
  mkdir build && cd build && \
# CMake
  cmake .. && \
# Make
  make -j"$(nproc)"
# Set CAFFE_HOME
ENV CAFFE_HOME /root/caffe

# Clone DIGITS repo and move into it
RUN cd /root && git clone https://github.com/NVIDIA/DIGITS.git digits && cd digits && \
# pip install
  pip install -r requirements.txt

# Enable volumes for host persistence
VOLUME /data
VOLUME /jobs

ENV DIGITS_JOBS_DIR=/jobs
ENV DIGITS_LOGFILE_FILENAME=/jobs/digits.log

# Expose server port
EXPOSE 5000
# Set working directory
WORKDIR /root/digits

# TensorBoard
EXPOSE 6006

# Create basic user
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root
# install python3 and jupyter
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common curl

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
        python3.6 && \
    rm -rf /var/lib/apt/lists/*
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.6
RUN pip3 install --upgrade setuptools pip
RUN pip3 install jupyter notebook
RUN pip3 install https://github.com/betatim/nbserverproxy/archive/master.zip

ENV HOME /root
# Copy repo into ${HOME}, make user own $HOME
COPY . ${HOME}

WORKDIR ${HOME}
RUN jupyter serverextension enable --py nbserverproxy
RUN pip3 install -e.
RUN jupyter serverextension enable --py nbdlstudioproxy
RUN jupyter nbextension     install --py nbdlstudioproxy
RUN jupyter nbextension     enable --py nbdlstudioproxy

RUN chown -R ${NB_USER} ${HOME}

WORKDIR ${HOME}/digits
RUN python setup.py install
WORKDIR ${HOME}

USER ${NB_USER}

ENV DIGITS_JOBS_DIR=${HOME}/jobs
ENV DIGITS_LOGFILE_FILENAME=${HOME}/digits.log
ENV PYTHONPATH=/usr/local/python

ENTRYPOINT [""]
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
