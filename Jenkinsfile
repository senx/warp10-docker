//
//   Copyright 2020-2022  SenX S.A.S.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

@Library('senx-shared-library') _

pipeline {
    agent any
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '3'))
        timestamps()
    }
    triggers {
        pollSCM('H/15 * * * 1-5')
    }
    environment {
        DOCKER_HUB_CREDS = credentials('dockerhub')
        GITLAB_REGISTRY_CREDS = credentials('gitlabregistry')
        PLATFORM = 'linux/amd64,linux/arm/v7,linux/arm64/v8'
        PLATFORM_ALPINE = 'linux/amd64'
    }
    parameters {
        string(name: 'GITLAB_REPO', defaultValue: 'registry.gitlab.com/steven.gueguen/warp10-docker', description: 'Container registry')
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    env.version = ""
                    notify.slack('STARTED')
                }
                checkout scm
                script {
                    env.version = gitUtils.getVersion()
                }
            }
        }
        stage('Setting up Docker env') {
            steps {
                sh 'docker buildx prune --force --all'
                sh 'docker buildx use multiarch'
            }
        }
        stage('Build Docker image') {
            steps {
                sh 'echo ${GITLAB_REGISTRY_CREDS_PSW} | docker login --username ${GITLAB_REGISTRY_CREDS_USR} --password-stdin registry.gitlab.com'
                sh "docker buildx build --pull --push --platform ${PLATFORM} -t ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu ubuntu"
                sh "docker buildx build --pull --push --platform ${PLATFORM_ALPINE} -t ${params.GITLAB_REPO}/warp10:${env.version}-alpine alpine"
            }
        }
        stage('Test image - Standard mode') {
            steps {
                sh "./test.sh docker run --rm --platform linux/amd64 -d -P ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu"
                sh "./test.sh docker run --rm --platform linux/arm/v7 -d -P ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu"
                sh "./test.sh docker run --rm --platform linux/arm64/v8 -d -P ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu"
                sh "./test.sh docker run --rm --platform linux/amd64 -d -P ${params.GITLAB_REPO}/warp10:${env.version}-alpine"
            }
        }
        stage('Test image - In memory mode') {
            steps {
                sh "./test.sh docker run --rm --platform linux/amd64 -d -P -e IN_MEMORY=true ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu"
                sh "./test.sh docker run --rm --platform linux/arm/v7 -d -P -e IN_MEMORY=true ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu"
                sh "./test.sh docker run --rm --platform linux/arm64/v8 -d -P -e IN_MEMORY=true ${params.GITLAB_REPO}/warp10:${env.version}-ubuntu"
                sh "./test.sh docker run --rm --platform linux/amd64 -d -P -e IN_MEMORY=true ${params.GITLAB_REPO}/warp10:${env.version}-alpine"
            }
        }
        stage('Deploy to Docker Hub') {
            when {
                beforeInput true
                expression { gitUtils.isTag() }
            }
            options {
                timeout(time: 4, unit: 'DAYS')
            }
            input {
                message "Should we deploy image to Docker Hub?"
            }
            steps {
                sh 'echo ${DOCKER_HUB_CREDS_PSW} | docker login --username ${DOCKER_HUB_CREDS_USR} --password-stdin'
                sh "docker buildx build --pull --push --platform ${PLATFORM} -t ${DOCKER_HUB_CREDS_USR}/warp10:${env.version}-ubuntu ubuntu"
                sh "docker buildx build --pull --push --platform ${PLATFORM} -t ${DOCKER_HUB_CREDS_USR}/warp10:${env.version}-ubuntu-ci predictible-tokens-for-ci"
                sh "docker buildx build --pull --push --platform ${PLATFORM_ALPINE} -t ${DOCKER_HUB_CREDS_USR}/warp10:${env.version}-alpine alpine"
                script {
                    notify.slack('PUBLISHED')
                }
            }
        }
    }
    post {
        success {
            script {
                notify.slack('SUCCESSFUL')
            }
        }
        failure {
            script {
                notify.slack('FAILURE')
            }
        }
        aborted {
            script {
                notify.slack('ABORTED')
            }
        }
        unstable {
            script {
                notify.slack('UNSTABLE')
            }
        }
    }
}
