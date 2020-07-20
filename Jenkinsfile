pipeline {
    triggers {
        pollSCM('*/1 * * * *') // at every 15th minute on every day-of-week
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // keep the 10 most recent builds
        timestamps() // each log entry will be timestamped
    }

    environment {
        PYTHON_IMAGE = 'python:3.7'
        VENV_NAME = 'it4ad_e2e_base'
    }

    agent none
    stages {
        stage('Build base_line') {
            parallel {
                stage('Python Virtual Environment') {
                    agent {
                        docker { label "terra" image "${PYTHON_IMAGE}" }
                    }
                    stages {
                        stage('Build') {
                            steps {
                                sh """python3 -m venv ${VENV_NAME}
                                      . ${VENV_NAME}/bin/activate
                                      pip install -r requirements.txt
                                   """
                            }
                        }
                        stage('Package') {
                            steps {
                                sh """pip install venv-pack
                                      echo $GIT_COMMIT > ${VENV_NAME}/.git_commit
                                      venv-pack -p ${VENV_NAME} -o ${VENV_NAME}-${env.BUILD_NUMBER}.tar.gz
                                   """
                                //archiveArtifacts artifacts: "**/${VENV_NAME}.tar.gz", fingerprint: true
                            }
                        }
                        //stage('Publish') {
                        //    steps {
                        //        //sh "sed -i 's/ARTIFACT_NAME/${VENV_NAME}/g' artifactory-spec.json" // uncomment if using 'specPath' insead of 'spec'
                        //        rtUpload (
                        //            serverId: 'artifactory',
                        //            //specPath: 'artifactory-spec.json'
                        //            spec: """{
                        //                    "files": [
                        //                            {
                        //                                "pattern": "(${VENV_NAME})-${env.BUILD_NUMBER}.tar.gz",
                        //                                "target": "generic-local/${env.JOB_NAME}/{1}/"
                        //                            }
                        //                        ]
                        //                    }"""
                        //        )
                        //    }
                        //}
                
                        //stage ('Publish build info') {
                        //    steps {
                        //        rtPublishBuildInfo (
                        //            serverId: 'artifactory'
                        //        )
                        //    }
                        //}
                    }
                }
                stage('Docker Image') {
                    agent {
                        any { label 'terra' }
                    }
                    environment {
                        registry = "dmumber/base-line"
                        registryCredential = 'dockerhub'
                        dockerImage = ''
                    }
                    stages {
                        stage('Build') {
                            steps {
                                script {
                                    dockerImage = docker.build("$registry:$BUILD_NUMBER", "--build-arg BASE_IMAGE=$PYTHON_IMAGE -f Dockerfile .")
                                }
                            }
                        }
                        stage('Publish') {
                            steps{
                                script {
                                    docker.withRegistry( '', registryCredential ) {
                                        dockerImage.push()
                                    }
                                }
                            }
                        }
                        stage('Cleanup') {
                            steps{
                                sh "docker rmi $registry:$BUILD_NUMBER"
                            }
                        }
                    }
                }
            }
            post {
                always {
                    cleanWs(notFailBuild: true)
                }
            }
        }
    }      
}
