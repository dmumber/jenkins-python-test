pipeline {
    agent none

    triggers {
        pollSCM('*/1 * * * *') // at every 15th minute on every day-of-week
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // keep the 10 most recent builds
        timestamps() // each log entry will be timestamped
    }

    stages {
        stage('Python Virtual Environment') {
            agent {
                docker { label 'terra' image 'python:3.7' }
            }
            stages {
                stage('Build') {
                    steps {
                        sh """python3 -m venv it4ad_e2e_base
                              . it4ad_e2e_base/bin/activate
                              pip install -r requirements.txt
                           """
                    }
                }
                stage('Package') {
                    steps {
                        sh """pip install venv-pack
                              echo $GIT_COMMIT > it4ad_e2e_base/.git_commit
                              venv-pack -p it4ad_e2e_base -o it4ad_e2e_base-${env.BUILD_NUMBER}.tar.gz
                           """
                        //archiveArtifacts artifacts: "**/it4ad_e2e_base.tar.gz", fingerprint: true
                    }
                }
                //stage('Publish') {
                //    steps {
                //        //sh "sed -i 's/ARTIFACT_NAME/it4ad_e2e_base/g' artifactory-spec.json" // uncomment if using 'specPath' insead of 'spec'
                //        rtUpload (
                //            serverId: 'artifactory',
                //            //specPath: 'artifactory-spec.json'
                //            spec: """{
                //                    "files": [
                //                            {
                //                                "pattern": "(it4ad_e2e_base)-${env.BUILD_NUMBER}.tar.gz",
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
                stage('Build Image') {
                    steps {
                        script {
                            dockerImage = docker.build("registry + :$BUILD_NUMBER", "--build-arg VENV_NAME=it4ad_e2e_base-${env.BUILD_NUMBER}", "-f Dockerfile .")
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
            //post {
            //    always {
            //        cleanWs(notFailBuild: true)
            //    }
            //}
        }
    }      
}
