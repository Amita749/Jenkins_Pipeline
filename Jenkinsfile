pipeline {
    agent any

    environment {
        JWT_KEY   = credentials('sf_jwt_key')
        SFDC_HOST = 'https://test.salesforce.com'
        GIT_URL   = 'https://github.com/Amita749/Jenkins_Pipeline.git'
    }

        parameters {
        choice(name: 'ACTION', choices: ['DEPLOY','ROLLBACK'], description: 'Choose Deploy or Rollback')
        choice(name: 'BRANCH_NAME', choices: ['feature/dev1','feature/dev2','main'], description: 'Git branch to deploy from')
        choice(name: 'TARGET_ORG', choices: ['Jenkins1', 'Jenkins2'], description: 'Select target Salesforce Org')
        string(name: 'METADATA', defaultValue: '', description: 'Metadata to deploy (comma separated, e.g., ApexClass:Demo)')
        string(name: 'ROLLBACK_COMMIT', defaultValue: '', description: 'Commit ID to rollback to (required for rollback)')
        string(name: 'TEST_CLASSES', defaultValue: '', description: 'Comma-separated Apex test classes to run (optional)')
    }


    stages {
        stage('Checkout') {
            steps { git branch: "${params.BRANCH_NAME}", url: "${GIT_URL}" }
        }

        stage('Auth Org') {
            steps {
                script {
                    def credsMap = [
                        Jenkins1: [consumerCredId: 'JENKINS1_CONSUMER_KEY', user: 'naman.rawat@dynpro.com.jenkins1'],
                        Jenkins2: [consumerCredId: 'JENKINS2_CONSUMER_KEY', user: 'naman.rawat@dynpro.com.jenkins2']
                    ]
                    def creds = credsMap[params.TARGET_ORG]
                    withCredentials([string(credentialsId: creds.consumerCredId, variable: 'CONSUMER_KEY')]) {
                        bat "sf auth jwt grant --client-id %CONSUMER_KEY% --jwt-key-file \"%JWT_KEY%\" --username ${creds.user} --instance-url ${SFDC_HOST} --alias ${params.TARGET_ORG}"
                    }
                }
            }
        }

        stage('Prepare Manifest') {
            steps {
                bat "sf project generate manifest --metadata \"ApexClass:${params.MAIN_CLASS},${params.TEST_CLASSES.replaceAll(',',',ApexClass:')}\" --output-dir manifest"
            }
        }

        stage('Validate and Deploy') {
            steps {
                script {
                    def testParam = params.TEST_CLASSES.replaceAll(',',',')
                    def validate = bat(returnStatus: true, script: "sf project deploy validate --manifest manifest\\package.xml --target-org ${params.TARGET_ORG} --test-level RunSpecifiedTests --tests ${testParam}")
                    
                    if (validate != 0) {
                        echo "❌ Validation failed, rolling back..."
                        bat "git checkout ${params.ROLLBACK_COMMIT}"
                        bat "sf project deploy start --manifest manifest\\package.xml --target-org ${params.TARGET_ORG} --test-level NoTestRun"
                        currentBuild.description = "Rollback performed"
                    } else {
                        echo "✅ Validation passed, deploying..."
                        bat "sf project deploy start --manifest manifest\\package.xml --target-org ${params.TARGET_ORG} --test-level RunSpecifiedTests --tests ${testParam}"
                        currentBuild.description = "Deployment successful"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🔹 Build Status: ${currentBuild.currentResult}"
            echo "🔹 Action Description: ${currentBuild.description}"
        }
    }
}
