FROM nvidia/digits:6.0

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Copy repo into ${HOME}, make user own $HOME
USER root
# install python3 and jupyter
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        python3-jupyter && \
    rm -rf /var/lib/apt/lists/*

COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}
RUN pip3 install https://github.com/betatim/nbserverproxy/archive/master.zip
RUN jupyter serverextension enable --py nbserverproxy
RUN pip3 install -e.
RUN jupyter serverextension enable  --user --py nbdlstudioproxy
RUN jupyter nbextension     install --user --py nbdlstudioproxy
RUN jupyter nbextension     enable  --user --py nbdlstudioproxy

CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
