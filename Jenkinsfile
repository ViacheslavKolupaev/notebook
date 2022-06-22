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
    // Docs: https://www.jenkins.io/doc/book/pipeline/syntax/#environment
    environment {
        GIT_COMMIT_SHORT_HASH = sh('git rev-parse --short HEAD')
        DEPLOY_TO = 'staging'
    }

    options {
        // This is required if you want to clean before build
        //skipDefaultCheckout(true)

        // Keep only last 3 builds.
        buildDiscarder logRotator(artifactDaysToKeepStr: '21', artifactNumToKeepStr: '2', daysToKeepStr: '21', numToKeepStr: '2')

        disableConcurrentBuilds()

        timestamps()

        // Timeout period for the Pipeline run, after which Jenkins should abort the Pipeline.
        timeout(time: 10, unit: 'MINUTES')
    }

    triggers {
        pollSCM('* * * * *')
    }

    // agent section specifies where the entire Pipeline will execute in the Jenkins environment
    agent {
        label ('linux && (master || main)')
    }
}
