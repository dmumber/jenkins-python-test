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

        stage('Prepare environment') {
            steps {
                echo "Install dependencies"
                sh  "pip install -r requirements/dev.txt"
            }
        }
        stage('Test: Run') {
            steps {
                // Run my project tests.
                sh 'coverage run package_xxx tests'
    
                // Dump coverage metrics to XML.
                sh 'coverage xml -o reports/coverage.xml'
    
                // Run Pylint.
                sh 'pylint --rcfile=.pylintrc my_project > reports/pylint.report'
    
                // Run Pycodestyle (PEP8 checks).
                sh 'pycodestyle my_project > reports/pep8.report'
            }
            post {
                always{
                    // Generate JUnit, PEP8, Pylint and Coverage reports.
                    junit 'reports/*junit.xml'
                    recordIssues(
                        tool: pep8(pattern: 'reports/pep8.report'),
                        unstableTotalAll: 200,
                        failedTotalAll: 220
                    )
                    recordIssues(
                        tool: pyLint(pattern: 'reports/pylint.report'),
                        unstableTotalAll: 20,
                        failedTotalAll: 30
                    )
                    cobertura coberturaReportFile: 'reports/coverage.xml'
                }
            }
        }
        //stage('Static code metrics') {
        //    steps {
        //        //echo "Raw metrics"
        //        //sh  ''' radon raw --json irisvmpy > raw_report.json
        //        //        radon cc --json irisvmpy > cc_report.json
        //        //        radon mi --json irisvmpy > mi_report.json
        //        //        sloccount --duplicates --wide irisvmpy > sloccount.sc
        //        //    '''
        //        echo "Test coverage"
        //        sh  ''' coverage run package_xxx/module_xxx.py 1 1 2 3
        //                python -m coverage xml -o reports/coverage.xml
        //            '''
        //        echo "Style check"
        //        //sh  ''' pylint package_xxx || true
        //        sh  ''' 
        //                pylint --disable=W1202 --output-format=parseable --reports=no module > pylint.log || echo "pylint exited with $?")'
        //                cat render/pylint.log
        //            '''
        //    }
        //    post{
        //        always{
        //            step([$class: 'CoberturaPublisher',
        //                           autoUpdateHealth: true,
        //                           autoUpdateStability: true,
        //                           coberturaReportFile: 'reports/coverage.xml',
        //                           failNoReports: false,
        //                           failUnhealthy: false,
        //                           failUnstable: false,
        //                           maxNumberOfBuilds: 10,
        //                           onlyStable: false,
        //                           sourceEncoding: 'ASCII',
        //                           zoomCoverageChart: true]
        //            )
        //            step([$class: 'WarningsPublisher', parserConfigurations: [[parserName: 'PYLint', pattern: 'pylint.log']], unstableTotalAll: '0', usePreviousBuildAsReference: true])
        //        }
        //    }
        //}



        stage('Unit tests') {
            steps {
                sh  ''' python -m pytest --verbose --junit-xml reports/unit_tests.xml
                    '''
            }
            post {
                always {
                    // Archive unit tests for the future
                    junit allowEmptyResults: true, testResults: 'reports/unit_tests.xml'
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

        stage('Build package') {
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