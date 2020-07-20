pipeline {
    environment {
        registry = "dmumber/base-line"
        registryCredential = 'dockerhub'
        dockerImage = ''
    }
    
    agent {
        any {
            label 'terra'
        }
    }

    triggers {
        pollSCM('*/1 * * * *')
    }

    options {
        skipStagesAfterUnstable()
        // Keep the 10 most recent builds
        buildDiscarder(
            logRotator(numToKeepStr: '10')
        )

        timestamps()
    }

    stages {
        stage('Building image') {
            steps{
                script {
                    dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }
        stage('Deploy Image') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Remove Unused docker image') {
            steps{
                sh "docker rmi $registry:$BUILD_NUMBER"
            }
        }
    }

    post {
        always {
            cleanWs(notFailBuild: true)
        }
    }
}