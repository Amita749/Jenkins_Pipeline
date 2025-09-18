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
stage('Run Specific Test & Check Coverage') {
    steps {
        script {
            // workspace-safe coverage folder
            def coverageDir = "${WORKSPACE}/coverage-results"
            bat "if not exist \"${coverageDir}\" mkdir \"${coverageDir}\""

            // run only the specific test class with code coverage
            bat "sf apex run test --target-org %TARGET_ALIAS% --tests %TEST_CLASS% --code-coverage --json --output-dir \"${coverageDir}\" --wait 10"

            // pick the JSON file dynamically without findFiles()
            def coverageFile = null
            def folder = new File(coverageDir)
            def files = folder.listFiles().findAll { it.name.startsWith('test-run-codecoverage') && it.name.endsWith('.json') }
            if (files.size() == 0) {
                error("❌ No coverage JSON file found! Check if tests ran successfully.")
            }
            coverageFile = files[0].getAbsolutePath()

            // parse coverage safely
            def jsonText = readFile(coverageFile)
            def json = new groovy.json.JsonSlurper().parseText(jsonText)

            def covered = json.summary.coveredLines as Integer
            def uncovered = json.summary.uncoveredLines as Integer
            def coverage = (covered * 100) / (covered + uncovered)

            echo "Coverage from ${env.TEST_CLASS}: ${coverage}%"

            if (coverage < 75) {
                error("❌ Coverage ${coverage}% < 75%. Deployment stopped.")
            }
        }
    }
}

        TEST_CLASS = 'AdderTest'   // specify the test class to run
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

        stage('Run Specific Test & Check Coverage') {
            steps {
                script {
                    // workspace-safe coverage folder
                    def coverageDir = "${WORKSPACE.replaceAll('\\\\','/')}/coverage-results"
                    bat "mkdir ${coverageDir} || exit 0"

                    // run only the specific test class with code coverage
                    bat "sf apex run test --target-org %TARGET_ALIAS% --tests %TEST_CLASS% --code-coverage --json --output-dir ${coverageDir} --wait 10"

                    // dynamically find the latest coverage JSON file (handles timestamped filenames)
                    def files = findFiles(glob: "${coverageDir}/test-run-codecoverage*.json")
                    if (files.length == 0) {
                        error("❌ No coverage JSON file found! Check if tests ran successfully.")
                    }
                    def coverageFile = files[0].path

                    // parse coverage safely
                    def jsonText = readFile(coverageFile)
                    def json = new groovy.json.JsonSlurper().parseText(jsonText)

                    def covered = json.summary.coveredLines as Integer
                    def uncovered = json.summary.uncoveredLines as Integer
                    def coverage = (covered * 100) / (covered + uncovered)

                    echo "Coverage from ${env.TEST_CLASS}: ${coverage}%"

                    if (coverage < 75) {
                        error("❌ Coverage ${coverage}% < 75%. Deployment stopped.")
                    }
                }
            }
        }

        stage('Deploy Metadata to Target Org') {
            steps {
                // only deploy if coverage >= 75%
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
