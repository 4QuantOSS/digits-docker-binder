FROM nvidia/digits:6.0

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root
# install python3 and jupyter
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3.6 && \
    rm -rf /var/lib/apt/lists/*
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.6
RUN pip3 install --upgrade setuptools pip
RUN pip3 install jupyter notebook
RUN pip3 install https://github.com/betatim/nbserverproxy/archive/master.zip

# Copy repo into ${HOME}, make user own $HOME
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

WORKDIR ${HOME}
RUN jupyter serverextension enable --py nbserverproxy
RUN pip3 install -e.
RUN jupyter serverextension enable  --user --py nbdlstudioproxy
RUN jupyter nbextension     install --user --py nbdlstudioproxy
RUN jupyter nbextension     enable  --user --py nbdlstudioproxy

USER ${NB_USER}
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
