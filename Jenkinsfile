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
Environments:
    1. `DEV`;
    2. `TEST`;
    3. `PROD`.

Git Flow type. The pipeline provides a GitHub Flow implementation suitable for small teams:
    1. `main` (push without Pull Request and force push are prohibited);
    2. Branches that can be merged into the `main` branch using a Pull Request:
        1. `feature/<task-id>`;
        2. `bugfix/<task-id>`;
        3. `infra/<task-id>`.

Triggers for starting the pipeline:
    1. Creating a Pull Request to the `main` branch: (`feature`|`bugfix`|`infra`) → `main`.
        1. Pushing additional commits to an open Pull Request. Skip branch pipelines when PR pipelines already exist.
    2. Merge Pull Request into `main` branch (equals `git push` to the `main` branch). All merge commits to the `main`
       branch. Fires after feature has been merged into the `main` branch.

Environment variables and pipeline parameterization:
    1. It is possible to use environment variables and secrets of the standard Credentials plugin.
    These settings can only be edited by DevOps engineers.
    2. It is possible to get environment variables (no secrets!) from the `jenkins_properties.groovy` file.
    This file can be edited by Software Engineers.
    3. Pipeline environment variables:
        1. CI_DEPLOY_FREEZE — boolean flag indicating that deploy freeze is in effect. For example, 16:00 on Thu — 09:00
        on Mon, [UTC 3] MSK. Jenkins needs to check if the current system time falls within the specified interval.

Tools:
    1. All pipeline tests are run in pre-configured Docker containers. This provides environment isolation.
        1. `.base_python_image_w_venv`
    2. The same dependencies can be used by different stages of the same pipeline. Therefore, to speed things up,
    Jenkins should use dependency caching.
        1. `.python_caching_params`

Stages:
    1. `pre`
    2. `test`:
        1. `sonar-test`
        2. `lint-test`
        3. `type-test`:
            1. rules:
                1. Testing BEFORE merging branches. If type tests fail, branch merging is prohibited.
                2. Testing AFTER merging branches. If type tests fail, deploy to staging is prohibited.
            2. base:
                1. `.base_python_image_w_venv`
                2. `.python_caching_params`
            3. script:
                1. `pip install --requirement requirements/out/type_test.txt` — A separate file with the necessary
                dependencies has been prepared in the project.
                2. `mypy` — The parameters for running `mypy` are specified in the config file.
        4. `unit-test`:  # TODO: migrations?
            1. rules:
                1. Testing BEFORE merging branches. If unit tests fail, branch merging is prohibited.
                2. Testing AFTER merging branches. If unit tests fail, deploy to staging is prohibited.
            2. base:
                1. `.base_python_image_w_venv`
                2. `.python_caching_params`
            3. script:
                1. `pip install --requirement requirements/out/unit_test.txt` — A separate file with the necessary
                dependencies has been prepared in the project.
                2. `pytest` — The parameters for running `pytest` are specified in the config file.
            4. artifacts:
                1. `cobertura: coverage.xml` — Publishing a report on the degree of code coverage by tests.
                2. `junit: report.xml` — Publishing a report on the execution of specific unit tests.
    3 `deploy`:
        1. `deploy-to-test`
            1. `notify-deploy-freeze`: notify only.
            2. `deploy-auto-docs`
        2. `deploy-to-prod`
            1. `notify-deploy-freeze`: notify and block further work of the pipeline.
    4. `post`
*/


// Jenkins Declarative Pipeline
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
        rateLimitBuilds(throttle: [count: 60, durationName: 'hour', userBoost: false])
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
        // TODO: https://www.jenkins.io/doc/book/pipeline/syntax/#options
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

                    // Check.
                    // Jenkins Pipeline exposes environment variables via the global variable env, which is available
                    // from anywhere within a Jenkinsfile.
                    echo "APP_NAME: ${env.APP_NAME}."
                    echo "APP_ENV_STATE: ${env.APP_ENV_STATE}."
                }
                echo '| STAGE 0: PREPARING THE ENVIRONMENT | END |'
            }  //steps
        }  // stage
        stage('STAGE: 1') {
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
                echo '| STAGE 0: PREPARING THE ENVIRONMENT | START |'

                echo "APP_NAME: ${APP_NAME}."
                echo "APP_ENV_STATE: ${APP_ENV_STATE}."

                echo '| STAGE 0: PREPARING THE ENVIRONMENT | END |'
            }
        }
    } // stages
}
