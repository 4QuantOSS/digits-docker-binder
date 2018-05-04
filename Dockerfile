FROM deepcognitionlabs/deep-learning-studio:2.0.0

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# setup paths
RUN mkdir /home/app/database
RUN chown -R ${NB_USER} /home/app/database
RUN mkdir /root/.keras
RUN chown -R ${NB_USER} /root/.keras
RUN mkdir /data
RUN chown -R ${NB_USER} /data

# Copy repo into ${HOME}, make user own $HOME
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}

USER ${NB_USER}
RUN pip install https://github.com/betatim/nbserverproxy/archive/master.zip
RUN jupyter serverextension enable --py nbserverproxy
RUN pip install -e.
RUN jupyter serverextension enable  --user --py nbdlstudioproxy
RUN jupyter nbextension     install --user --py nbdlstudioproxy
RUN jupyter nbextension     enable  --user --py nbdlstudioproxy
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
