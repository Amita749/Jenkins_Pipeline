pipeline {
    agent any

    environment {
        SOURCE_CONSUMER_KEY = credentials('SOURCE_CONSUMER_KEY')
        SOURCE_USERNAME     = credentials('SOURCE_USERNAME')
        SOURCE_ALIAS        = 'SourceOrg'

        TARGET_CONSUMER_KEY = credentials('TARGET_CONSUMER_KEY')
        TARGET_USERNAME     = credentials('TARGET_USERNAME')
        TARGET_ALIAS        = 'TargetOrg'

        JWT_KEY   = credentials('sf_jwt_key')
        SFDC_HOST = 'https://test.salesforce.com'
    }

    stages {
        stage('Authenticate Source Org') {
            steps {
                bat 'sf auth jwt grant --client-id %SOURCE_CONSUMER_KEY% --jwt-key-file "%JWT_KEY%" --username %SOURCE_USERNAME% --instance-url %SFDC_HOST% --alias %SOURCE_ALIAS%'
            }
        }

        stage('Authenticate Target Org') {
            steps {
                bat 'sf auth jwt grant --client-id %TARGET_CONSUMER_KEY% --jwt-key-file "%JWT_KEY%" --username %TARGET_USERNAME% --instance-url %SFDC_HOST% --alias %TARGET_ALIAS%'
            }
        }

        stage('Retrieve Metadata from Source Org') {
            steps {
                bat 'sf project retrieve start --manifest manifest/package.xml --target-org %SOURCE_ALIAS% --wait 10 --ignore-conflicts'
            }
        }

        stage('Check Coverage in Sandbox') {
            steps {
                script {
                    // Run all tests in Sandbox with coverage
                    bat 'sf apex run test --target-org %TARGET_ALIAS% --code-coverage --json --output-dir coverage-results --wait 10'

                    // Parse coverage JSON
                    def json = new groovy.json.JsonSlurper().parseText(readFile('coverage-results/test-run-codecoverage.json'))
                    def coverage = (json.summary.coveredLines * 100) / (json.summary.coveredLines + json.summary.uncoveredLines)

                    echo "Sandbox Coverage: ${coverage}%"

                    if (coverage < 75) {
                        error("❌ Coverage ${coverage}% < 75%. Deployment stopped.")
                    }
                }
            }
        }

        stage('Deploy Metadata to Target Org') {
            steps {
                // Only runs if coverage >= 75%
                bat 'sf project deploy start --manifest manifest/package.xml --target-org %TARGET_ALIAS% --wait 10 --ignore-conflicts'
            }
        }
    }

    post {
        always {
            echo 'Deployment pipeline finished.'
            archiveArtifacts artifacts: 'coverage-results/**', onlyIfSuccessful: false
        }
    }
}
