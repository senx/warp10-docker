#!/usr/bin/env groovy
import hudson.model.*

pipeline {
    agent any
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '3'))
    }
    environment {
        version = "${getVersion()}"
    }
    stages {

        stage('Checkout') {
            steps {
                this.notifyBuild('STARTED', version)
                git credentialsId: 'github', poll: false, url: 'git@github.com:cityzendata/warp10-docker.git'
                echo "Building ${version}"
            }
        }

        stage('Docker image') {
            steps {
                sh "docker build -t warp10io/warp10:$version ."
                sh "docker tag warp10io/warp10:$version warp10io/warp10"
            }
        }
        stage('Deploy') {
            when {
                expression { return isItATagCommit() }
            }
            parallel {
                stage('Deploy to DockerHub') {
                    options {
                        timeout(time: 2, unit: 'HOURS')
                    }
                    input {
                        message 'Should we deploy to DockerHub?'
                    }
                    steps {
                        sh "docker push warp10io/warp10:$version"
                        sh "docker push warp10io/warp10:latest"
                        def image_id = sh(script: 'docker images warp10io/warp10:$version -q', returnStdout: true).trim()
                        sh "docker rmi -f ${image_id}"
                        this.notifyBuild('PUBLISHED', version)
                    }
                }
            }
        }
    }
    post {
        success {
            this.notifyBuild('SUCCESSFUL', version)
        }
        failure {
            this.notifyBuild('FAILURE', version)
        }
        aborted {
            this.notifyBuild('ABORTED', version)
        }
        unstable {
            this.notifyBuild('UNSTABLE', version)
        }
    }
}

void notifyBuild(String buildStatus, String version) {
    // build status of null means successful
    buildStatus = buildStatus ?: 'SUCCESSFUL'
    String subject = "${buildStatus}: Job ${env.JOB_NAME} [${env.BUILD_DISPLAY_NAME}] | ${version}" as String
    String summary = "${subject} (${env.BUILD_URL})" as String
    // Override default values based on build status
    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFF00'
    } else if (buildStatus == 'SUCCESSFUL') {
        color = 'GREEN'
        colorCode = '#00FF00'
    } else if (buildStatus == 'PUBLISHED') {
        color = 'BLUE'
        colorCode = '#0000FF'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
    }

    // Send notifications
    this.notifySlack(colorCode, summary, buildStatus)
}

void notifySlack(String color, String message, String buildStatus) {
    String slackURL = getParam('slackUrl')
    String payload = "{\"username\": \"${env.JOB_NAME}\",\"attachments\":[{\"title\": \"${env.JOB_NAME} ${buildStatus}\",\"color\": \"${color}\",\"text\": \"${message}\"}]}" as String
    sh "curl -X POST -H 'Content-type: application/json' --data '${payload}' ${slackURL}" as String
}

String getParam(String key) {
    return params.get(key)
}

String getVersion() {
    return sh(returnStdout: true, script: 'git describe --abbrev=0 --tags').trim()
}


boolean isItATagCommit() {
    String lastCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    String tag = sh(returnStdout: true, script: "git show-ref --tags -d | grep ^${lastCommit} | sed -e 's,.* refs/tags/,,' -e 's/\\^{}//'").trim()
    return tag != ''
}
