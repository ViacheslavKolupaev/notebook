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
    // agent section specifies where the entire Pipeline will execute in the Jenkins environment
    agent {
        label ('master && linux')
    }

    // Docs: https://www.jenkins.io/doc/book/pipeline/syntax/#environment
    environment {
        //GIT_COMMIT_SHORT_HASH = sh('git rev-parse --short HEAD')
        DEPLOY_TO = 'staging'
        NOTEBOOK_GIT_URL = credentials('jenkins-secret-text-notebook-git-url')
    }

    // Configure Pipeline-specific options.
    options {
        // Disables the standard, automatic checkout scm before the first stage.
        // If specified and SCM checkout is desired, it will need to be explicitly included.
        skipDefaultCheckout true

        // Artifact rotation policy.
        buildDiscarder logRotator(
                artifactDaysToKeepStr: '21',
                artifactNumToKeepStr: '2',
                daysToKeepStr: '21',
                numToKeepStr: '2'
        )
        disableConcurrentBuilds()
        disableResume()
        timestamps()
        durabilityHint 'MAX_SURVIVABILITY'
        parallelsAlwaysFailFast()
        quietPeriod 5  // increase value in real setup
        retry(1)

        // Timeout period for the Pipeline run, after which Jenkins should abort the Pipeline.
        timeout(time: 10, unit: 'MINUTES')
        rateLimitBuilds(throttle: [count: 30, durationName: 'hour', userBoost: false])
    }

    triggers {
        pollSCM('* * * * *')
    }

    /*
    post section defines actions which will be run at the end of the Pipeline run or stage
    post section condition blocks: always, changed, failure, success, unstable, and aborted
    */
    post {
        always {
            echo "Build #${env.BUILD_NUMBER} - Job: ${env.JOB_NUMBER} status is: ${currentBuild.currentResult}"

            // Delete workspace
            cleanWs(
                    cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [
                            [pattern: '.gitignore', type: 'INCLUDE'],
                            [pattern: '.propsfile', type: 'EXCLUDE']
                    ]
            )
        }

        // TODO: add Docker clean-up.
        // TODO: add notifications to Telegram in case of success and failure.
    }  // post

    /**
     * stages contain one or more stage directives
     */
    stages {
        stage('Checkout SCM') {
            when {
                allOf {
                    expression {
                        return env.BRANCH_NAME == "origin/main" || env.BRANCH_NAME == "main"
                    }  // expression
                    expression {
                        currentBuild.result == null || currentBuild.result == 'SUCCESS'
                    }  // expression
                }  // allOf
            }  // when
            steps {
                checkout(
                        [
                                $class: 'GitSCM',
                                branches: [
                                        [name: 'refs/heads/main']
                                ],
                                extensions: [
                                        [$class: 'CheckoutOption', timeout: 1],
                                        [$class: 'BuildSingleRevisionOnly'],
                                        [$class: 'GitLFSPull']
                                ],
                                userRemoteConfigs: [
                                        [url: "${env.NOTEBOOK_GIT_URL}"]
                                ]
                        ]
                )
            }
        }
        stage('STAGE 0: PREPARING THE ENVIRONMENT') {
            steps {
                echo '| STAGE 0: PREPARING THE ENVIRONMENT | START |'
                echo "Running build id ${env.BUILD_ID} on Jenkins node ${env.NODE_NAME} for git branch ${env.BRANCH_NAME}."

                script {
                    // Load Jenkins envs.
                    load "jenkins_properties.groovy"

                    // Unpack.
                    env.APP_NAME = "${APP_NAME}"

                    // Check.
                    echo "APP_NAME: ${env.APP_NAME}."
                }
                echo '| STAGE 0: PREPARING THE ENVIRONMENT | END |'
            }  //steps
        }  // stage 0
    } // stages
}
