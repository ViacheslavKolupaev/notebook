# ########################################################################################
#  Copyright (c) 2022 Viacheslav Kolupaev; author's website address:
#
#      https://vkolupaev.com/?utm_source=c&utm_medium=link&utm_campaign=notebook
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# ########################################################################################


##########################################################################################
# Dockerfile with instructions for building the Docker image of the application.
#
# Dockerfile reference: https://docs.docker.com/engine/reference/builder/
##########################################################################################

# Dockerfile syntax definition. Required to mount package manager cache directories.
# See Dockerfile syntax tags here: https://hub.docker.com/r/docker/dockerfile
# Reference: https://docs.docker.com/engine/reference/builder/#syntax
# syntax=docker/dockerfile:1

##########################################################################################
# STAGE 1: PYTHON-BASE
##########################################################################################
# Build arguments; only before the declaration of the `FROM` instruction. Reference:
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DOCKER_REGISTRY=docker.io/library
ARG PYTHON_IMAGE_TAG

# Pull official base image.
# Not the final image, will appear as `<none>:<none>`.
FROM ${DOCKER_REGISTRY}/python:${PYTHON_IMAGE_TAG} AS python-base

# Build arguments; after the declaration of the `FROM` instruction.
ARG APP_NAME
ARG VCS_REF

# TODO: https://github.com/python-poetry/poetry/discussions/1879?sort=new
# Adding some environment variables.
####################
# File system.
####################
# The base directory of the project.
ENV PYPROJECT_BASE_DIR="/opt"

####################
# pip.
####################
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_CONFIG_FILE=pip.conf

####################
# poetry.
# https://python-poetry.org/docs/configuration/#using-environment-variables
####################
# Pin poetry version.
ENV POETRY_VERSION=1.2.2

# Make poetry install to this location.
# https://python-poetry.org/docs/configuration/#data-directory
# https://python-poetry.org/docs/#ci-recommendations
ENV POETRY_HOME="${PYPROJECT_BASE_DIR}/poetry"

# Create the virtualenv inside the project’s root directory: `{project-dir}/.venv`
# https://python-poetry.org/docs/configuration/#virtualenvsin-project
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

# Do not install `setuptools` in the environment.
# https://python-poetry.org/docs/configuration/#virtualenvsoptionsno-setuptools
ENV POETRY_VIRTUALENVS_OPTIONS_NO_SETUPTOOLS=true

####################
# Paths.
####################
ENV PYPROJECT_PATH="${PYPROJECT_BASE_DIR}/pyproject"
ENV VENV_PATH="${PYPROJECT_PATH}/.venv"

# Prepend poetry and venv to path.
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Setting the application root folder. For example: `/opt/pyproject/boilerplate`.
ENV APP_ROOT="${PYPROJECT_PATH}/${APP_NAME}"

####################
# Python.
#
# Docs: https://docs.python.org/3/using/cmdline.html#environment-variables
####################
# Prevents Python from writing `.pyc` files on the import of source modules.
# https://stackoverflow.com/questions/2998215/if-python-is-interpreted-what-are-pyc-files
# ENV PYTHONDONTWRITEBYTECODE=1

# Force the stdout and stderr streams to be unbuffered.
ENV PYTHONUNBUFFERED=1

# Augment the default search path for module files.
ENV PYTHONPATH ${APP_ROOT}

# Remove assert statements and any code conditional on the value of `__debug__`.
# Also discard docstrings.
ENV PYTHONOPTIMIZE=1


##########################################################################################
# STAGE 2: BUILDER-BASE
#
# This stage is used to build deps + create our virtual environment.
##########################################################################################
FROM python-base as builder-base

# Cache apt packages reference:
# https://docs.docker.com/engine/reference/builder/#run---mounttypecache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
  > /etc/apt/apt.conf.d/keep-cache

# Installing some auxiliary utilities.
# Docs: https://manpages.ubuntu.com/manpages/focal/en/man8/apt-get.8.html
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # https://packages.ubuntu.com/jammy/build-essential
    build-essential \
    libsasl2-dev \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# `pip` configuration before installing dependencies.
COPY pip.conf ./

# https://python-poetry.org/docs/#ci-recommendations
RUN python3 -m venv ${POETRY_HOME}
RUN ${POETRY_HOME}/bin/pip install "poetry==${POETRY_VERSION}"

# The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, COPY
# and ADD instructions that follow it in the Dockerfile.
# Reference: https://docs.docker.com/engine/reference/builder/#workdir
WORKDIR ${PYPROJECT_PATH}

# copy project requirement files here to ensure they will be cached.
COPY poetry.lock pyproject.toml ./

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
# --mount=type=cache,target=/root/.cache/pypoetry/cache \
# --mount=type=cache,target=/root/.cache/pypoetry/artifacts \
RUN poetry install --only main --no-interaction --no-ansi --no-root

# Deleting files that are no longer needed.
RUN rm -f poetry.lock pyproject.toml

##########################################################################################
# STAGE 3: DEVELOPMENT
#
# `development` image is used during development / testing.
##########################################################################################
# The final image, will appear as `image_name:image_tag` (`docker build -t` option)
FROM python-base as development

####################
# Adding labels.
####################
LABEL author="Viacheslav Kolupaev"
LABEL stage=development
LABEL app_name=${APP_NAME}
LABEL vcs_ref=${VCS_REF}

####################
# Adding frequently changing environment variables.
####################
# Setting the git revision short SHA. Changes frequently.
ENV VCS_REF=${VCS_REF}

# Create a user group 'app_group'. Create a user 'app_user' under 'app_group'.
RUN addgroup --system app_group && \
    adduser --system --home ${APP_ROOT} --ingroup app_group app_user

# Switch to non-root user.
USER app_user

# Copy Python dependencies from build image.
COPY --chown=app_user:app_group --from=builder-base ${PYPROJECT_PATH} ${PYPROJECT_PATH}

# Copy project from context.
COPY --chown=app_user:app_group ./ ${APP_ROOT}

# Chown all the files to the `app_user`.
RUN chown -R app_user:app_group ${APP_ROOT}

# The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, COPY
# and ADD instructions that follow it in the Dockerfile.
# Reference: https://docs.docker.com/engine/reference/builder/#workdir
WORKDIR ${APP_ROOT}

# Deleting files that are no longer needed.
RUN rm -f poetry.lock pyproject.toml pip.conf

# Server start.
ENTRYPOINT ["/bin/bash", "docker_entrypoint.sh"]
