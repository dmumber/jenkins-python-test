pipeline {
    agent {
        docker {
            label 'terra'
            image 'dmumber/base-line:64'
            registryCredentialsId 'dockerhub'
        }
    }

    triggers {
        pollSCM('*/1 * * * *')
    }

    options {
        skipDefaultCheckout(true)
        skipStagesAfterUnstable()
        // Keep the 10 most recent builds
        buildDiscarder(
            logRotator(numToKeepStr: '10')
        )

        timestamps()
    }

    stages {

        stage ("Checkout"){
            steps{
                checkout scm
            }
        }

        stage('Setup') {
            steps {
                sh '''pip install -r requirements.txt
                      mkdir reports
                   '''
            }
        }

        //stage('setup') {
        //    steps {
        //        echo "Install dependencies"
        //        sh "pip install -r requirements.txt"
        //        sh "mkdir reports"
        //    }
        //}

        stage('Quality Checks') {
            failFast true
            parallel {
                stage('Linter') {
                    steps {
                        sh '''pylint --verbose --exit-zero --reports=no --score=yes --msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" package_xxx > reports/pylint.out
                           '''
                    }
                    post {
                        always{
                            recordIssues(
                                aggregatingResults: true,
                                enabledForFailure: true,
                                failOnError: true,
                                ignoreFailedBuilds: false,
                                qualityGates: [
                                    [threshold: 1, type: 'TOTAL_ERROR', unstable: false],
                                    [threshold: 5, type: 'TOTAL_HIGH', unstable: false],
                                    [threshold: 1, type: 'TOTAL_HIGH', unstable: true],
                                    [threshold: 10, type: 'TOTAL', unstable: true]
                                ],
                                tools: [
                                    pyLint(pattern: 'reports/pylint.out')
                                ]
                            )
                        }
                    }
                }
        
                stage('Unit-Tests') {
                    steps {
                        //coverage run -m pytest --verbose --junit-xml reports/junit.xml
                        sh  '''pytest --cov=package_xxx --verbose -o junit_family=xunit2 --junit-xml=reports/junit.xml
                               coverage xml -o reports/coverage.xml --skip-empty
                            '''
                    }
                    post {
                        always {
                            // Archive unit tests for the future
                            junit(
                                allowEmptyResults: true,
                                testResults: 'reports/junit.xml'
                            )
        
                            cobertura(
                                coberturaReportFile: 'reports/coverage.xml',
                                sourceEncoding: 'ASCII',
                                enableNewApi: true,
                                failNoReports: false,
                                failUnstable: false,
                                conditionalCoverageTargets: '80, 60, 70',
                                methodCoverageTargets: '80, 60, 70',
                                packageCoverageTargets: '80, 60, 70'
                            )
                        }
                    }
                }
            }
        }

        stage('Package') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh  '''python setup.py bdist_wheel
                    '''
            }
            post {
                always {
                    // Archive unit tests for the future
                    archiveArtifacts(
                        allowEmptyArchive: true,
                        artifacts: 'dist/*whl',
                        fingerprint: true
                    )
                }
            }
        }

        stage("Publish") {
            parallel {
                stage('PyPi') {
                    steps {
                        echo "publishing to PyPi ..."
                        //sh """twine upload dist/*
                        //"""
                    }
                }
                stage('Artifactory') {
                    steps {
                        echo "publishing to JFrog Artifactory ..."
                    }
                }
                stage('Docker Registry') {
                    steps {
                        echo "publishing to Docker Registry ..."
                    }
                }
            }
        }

        stage("Deploy") {
            steps {
                echo "deploying ..."
                //sh """twine upload dist/*
                //"""
            }
        }

        stage("E2E-Tests") {
            steps {
                echo "e2e-testing ..."
                //sh """twine upload dist/*
                //"""
            }
        }
    }

    post {
        always {
            //sh 'rm -rf ${BUILD_TAG}'
            cleanWs(
                cleanWhenFailure: false,
                cleanWhenNotBuilt: false,
                cleanWhenUnstable: false,
                notFailBuild: true
            )
        }

        failure {
            emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                         <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']])
        }
    }
}