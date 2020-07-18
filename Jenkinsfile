pipeline {
    agent {
        docker {
            label 'terra'
            image 'python:3.8'
        }
    }

    triggers {
        pollSCM('*/1 * * * *')
    }

    options {
        //skipDefaultCheckout(true)
        // Keep the 10 most recent builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {

        //stage ("Code pull"){
        //    steps{
        //        checkout scm
        //    }
        //}

        stage('Setup Build Environment') {
            steps {
                echo "Install dependencies"
                sh "pip install -r requirements/dev.txt"
                sh "mkdir reports"
            }
        }

        stage('Static Code Analysis') {
            steps {
                sh 'pylint --verbose --exit-zero --msg-template="{path}:{line}: [{msg_id}({symbol}), {obj}] {msg}" package_xxx > reports/pylint.out'
            }
            post {
                always{
                    recordIssues(
                        tool: pyLint(pattern: 'reports/pylint.out'),
                        unstableTotalAll: 100,
                    )
                }
            }
        }

        stage('Unit Testing') {
            steps {
                //coverage run -m pytest --verbose --junit-xml reports/unit_tests.xml
                sh  ''' pytest --cov=. --verbose --junit-xml reports/unit_tests.xml
                        coverage xml -o reports/coverage.xml
                    '''
            }
            post {
                always {
                    // Archive unit tests for the future
                    junit allowEmptyResults: true, testResults: 'reports/unit_tests.xml'
                    cobertura coberturaReportFile: 'reports/coverage.xml'
                }
            }
        }

        stage('Build Package') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh  "python setup.py bdist_wheel"
            }
            post {
                always {
                    // Archive unit tests for the future
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'dist/*whl', fingerprint: true
                }
            }
        }

        // stage("Deploy to PyPI") {
        //     steps {
        //         sh """twine upload dist/*
        //         """
        //     }
        // }
    }

    post {
        failure {
            emailext (
                subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                         <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']])
        }
    }
}