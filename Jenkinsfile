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
                sh  "pip install -r requirements/dev.txt"
                sh "mkdir reports"
            }
        }

        stage('Static Code Analysis') {
            steps {
                sh "pylint package_xxx > reports/pylint.report || true"
                sh "pycodestyle package_xxx > reports/pep8.report  || true"
                //sh ''' 
                //       coverage run -m pytest tests
                //       coverage xml -o reports/coverage.xml
                //   '''
            }
            post {
                always{
                    recordIssues(
                        tool: pyLint(pattern: 'reports/pylint.report'),
                        unstableTotalAll: 100,
                    )
                    recordIssues(
                        tool: pep8(pattern: 'reports/pep8.report'),
                        unstableTotalAll: 100,
                    )
                    //cobertura coberturaReportFile: 'reports/coverage.xml'
                }
            }
        }

        stage('Unit Testing') {
            steps {
                sh  ''' coverage run -m pytest --verbose --junit-xml reports/unit_tests.xml
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

        //stage('Acceptance tests') {
        //    steps {
        //        sh  ''' behave -f=formatters.cucumber_json:PrettyCucumberJSONFormatter -o ./reports/acceptance.json || true
        //            '''
        //    }
        //    post {
        //        always {
        //            cucumber (buildStatus: 'SUCCESS',
        //            fileIncludePattern: '**/*.json',
        //            jsonReportDirectory: './reports/',
        //            parallelTesting: true,
        //            sortingMethod: 'ALPHABETICAL')
        //        }
        //    }
        //}

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