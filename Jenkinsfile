pipeline {
    agent none

    triggers {
        pollSCM('*/1 * * * *') // at every 15th minute on every day-of-week
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // keep the 10 most recent builds
        timestamps() // each log entry will be timestamped
    }

    parameters {
        string(name: 'VENV', defaultValue: 'it4ad_e2e_base', description: 'The name of the python virtual environment to create.')
    }

    stages {
        stage('Python Virtual Environment') {
            agent {
                docker {
                    label 'terra'
                    image 'python:3.7'
                }
            }
            stages {
                stage('Build') {
                    steps {
                        sh '''python3 -m venv ${params.VENV}
                              . ${params.VENV}/bin/activate
                              pip install -r requirements.txt
                           '''
                    }
                }
                stage('Package') {
                    steps {
                        sh '''pip install venv-pack
                              echo $GIT_COMMIT > ${params.VENV}/.git_commit
                              venv-pack -p ${params.VENV} -o ${params.VENV}-${env.BUILD_NUMBER}.tar.gz
                           '''
                        //archiveArtifacts artifacts: "**/${params.VENV}.tar.gz", fingerprint: true
                    }
                }
                //stage('Publish') {
                //    steps {
                //        //sh "sed -i 's/ARTIFACT_NAME/${params.VENV}/g' artifactory-spec.json" // uncomment if using 'specPath' insead of 'spec'
                //        rtUpload (
                //            serverId: 'artifactory',
                //            //specPath: 'artifactory-spec.json'
                //            spec: """{
                //                    "files": [
                //                            {
                //                                "pattern": "(${params.VENV})-${env.BUILD_NUMBER}.tar.gz",
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
            agent { label 'terra' }
            stages {
                stage('Build Image') {
                    steps {
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
                stage('Remove Unused Docker Image') {
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
    }      
}
