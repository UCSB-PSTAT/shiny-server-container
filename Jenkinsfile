pipeline {
    agent none
    triggers { cron('H H(0-6) * * 1') }
    stages {
        stage('Shiny Server Images') {
            matrix {
                axes {
                    axis {
                        name 'IMAGE_NAME'
                        values 'shiny-server'
                    }
                }
                stages {
                    stage('Build Test Deploy') {
                        agent {
                            label 'jupyter'
                        }
                        stages{
                            stage('Build') {
                                steps {
                                    script {
                                        if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                                           scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                                        }
                                    }
                                    echo "NODE_NAME = ${env.NODE_NAME}"
                                    sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache $([ "scipy-base" == "$IMAGE_NAME" ] && echo "--from=jupyter/scipy-notebook:notebook-7.0.3")  .'
                                 }
                            }
                            stage('Test') {
                                steps {
                                    sh 'podman run -it --rm localhost/$IMAGE_NAME Rscript -e "library(shiny); library(shinythemes); library(maps); library(mapproj); library(leaflet); library(rgdal); library(dplyr); library(sf); library(sp); library(flexdashboard); library(plotly); library(stringr)"'
                                    sh 'podman run -d --name=$IMAGE_NAME --rm -p 3838:3838 localhost/$IMAGE_NAME'
                                    sh 'sleep 10 && curl -v http://localhost:3838/ 2>&1 | grep -P "HTTP\\S+\\s200\\s+[A-Z ]+"'
                                }
                                post {
                                    always {
                                        sh 'podman rm -ifv $IMAGE_NAME'
                                    }
                                }
                            }
                            stage('Deploy') {
                                when { branch 'main' }
                                environment {
                                    DOCKER_HUB_CREDS = credentials('DockerHubToken')
                                }
                                steps {
                                    sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                                    sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://docker.io/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                                }
                                post {
                                    always {
                                        sh 'podman rmi -i $IMAGE_NAME || true'
                                    }
                                }
                            }                
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(channel: '#infrastructure-build', username: 'jenkins', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
