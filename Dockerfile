#  Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

###########
# COMPILE #
###########

# Pull official base image.
# Not the final image, will appear as `<none>:<none>`.
FROM python:3.10.4-slim AS compile-image

LABEL author="Viacheslav Kolupaev"

# Label the image for cleaning after build process.
LABEL stage=compile-image

# Create a temporary folder to hold the files.
WORKDIR /usr/src/app

# Prevents Python from writing pyc files to disk.
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr.
ENV PYTHONUNBUFFERED 1

## Prepare virtualenv.
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv ${VIRTUAL_ENV}
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

# Install Python dependencies.
COPY ./requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt


########
# BUILD #
########

# Pull official base image.
# The final image, will appear as `image_name:image_tag` (`docker build -t` option)
FROM python:3.10.4-slim AS build-image

LABEL author="Viacheslav Kolupaev"

# Label the image for cleaning after build process.
LABEL stage=build-image

# Setting the application root folder.
ARG APP_NAME
ENV APP_ROOT="/usr/src/${APP_NAME}"

ARG CI_COMMIT_SHA
ENV CI_COMMIT_SHA=${CI_COMMIT_SHA}

# Prevents Python from writing pyc files to disk.
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr.
ENV PYTHONUNBUFFERED 1

# Create a user group 'app_group'. Create a user 'app_user' under 'app_group'.
RUN addgroup --system app_group && \
    adduser --system --home ${APP_ROOT} --ingroup app_group app_user

# Set work directory.
WORKDIR ${APP_ROOT}

ENV VIRTUAL_ENV=/opt/venv

## Copy Python dependencies from build image.
COPY --chown=app_user:app_group --from=compile-image ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Make sure we use the virtualenv:
ENV PATH="${VIRTUAL_ENV}/bin:$PATH"

ENV PYTHONPATH ${APP_ROOT}

# Copy project.
COPY --chown=app_user:app_group ./ ${APP_ROOT}

# Chown all the files to the app_user.
RUN chown -R app_user:app_group ${APP_ROOT}

# Switch to non-root user.
USER app_user

# Server start.
ENTRYPOINT ["/bin/bash", "docker_entrypoint.sh"]
