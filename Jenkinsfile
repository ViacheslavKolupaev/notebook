#!groovy

/*
##########################################################################################
# Copyright (c) 2022. Viacheslav Kolupaev, https://vkolupaev.com/
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language governing
# permissions and limitations under the License.
##########################################################################################
*/

/*
GitHub Flow with branches: master, dev.

Stages:
    - git commit + git push to dev:
        - Stage 0: Prepare Env
        - Stage 1: Local Testing
    - pull request + merge dev → master:
        - Stage 2: Build container
        - Stage 3: Publish container
        - Stage 4: Deploy container to prod
*/

pipeline {
    options {
        disableConcurrentBuilds()
    }
}
