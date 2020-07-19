pipeline {
    agent {
        docker {
            label 'terra'
            image 'python:3.8'
        }
    }

    triggers {
        pollSCM('*/15 * * * *')
    }

    options {
        skipDefaultCheckout(true)
        skipStagesAfterUnstable(true)
        // Keep the 10 most recent builds
        buildDiscarder(
            logRotator(numToKeepStr: '10')
        )

        timestamps()
    }

    stages {

        stage ("checkout"){
            steps{
                checkout scm
            }
        }

        stage('setup') {
            steps {
                sh '''python -m venv ${BUILD_TAG}
                      . ${BUILD_TAG}/bin/activate 
                      pip install -r requirements.txt
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

        stage('code analysis') {
            steps {
                sh '''. ${BUILD_TAG}/bin/activate
                      pylint --verbose --exit-zero --reports=no --score=yes --msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" package_xxx > reports/pylint.out
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

        stage('test') {
            steps {
                //coverage run -m pytest --verbose --junit-xml reports/junit.xml
                sh  '''. ${BUILD_TAG}/bin/activate 
                       pytest --cov=package_xxx --verbose -o junit_family=xunit2 --junit-xml=reports/junit.xml
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

        stage('package') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh  '''. ${BUILD_TAG}/bin/activate
                       python setup.py bdist_wheel
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

        // stage("publish") {
        //     steps {
        //         sh """twine upload dist/*
        //         """
        //     }
        // }
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