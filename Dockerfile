# syntax=docker/dockerfile:1
FROM jpauwels/hartufo-collections:medium as data


FROM python:3.11-slim

# Make MyBinder compatible
## Create local user
RUN useradd --create-home --shell /bin/bash --uid 1000 hartufo-user
WORKDIR /home/hartufo-user
## Overwrite entrypoint
ENTRYPOINT []
## Install Jupyter
RUN apt-get update && apt-get install -y git
USER hartufo-user
ENV PATH="${PATH}:/home/hartufo-user/.local/bin"
RUN python3 -m pip install --no-cache-dir --user notebook jupyterlab
RUN python3 -m pip install --no-cache-dir --user jupyterhub nbgitpuller

# Add data to image
COPY --from=data /hartufo-collections ./hartufo-collections

# Install libsamplerate
USER root
RUN apt-get update && apt-get install -y libsamplerate0

## Copy repo contents
COPY ./requirements.txt .

# Switch to local user
RUN chown -R hartufo-user:hartufo-user .
USER hartufo-user

# Install requirements
RUN python3 -m pip install --no-cache-dir --user -r requirements.txt
