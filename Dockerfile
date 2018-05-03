FROM deepcognitionlabs/deep-learning-studio:2.0.0

# Copy repo into ${HOME}, make user own $HOME
USER root
COPY . ${HOME}
# RUN chown -R ${NB_USER} ${HOME}
# USER ${NB_USER}
