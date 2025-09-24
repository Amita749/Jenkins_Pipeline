pipeline {
    agent any

    environment {
        JWT_KEY   = credentials('sf_jwt_key') // JWT private key stored in Jenkins
        SFDC_HOST = 'https://test.salesforce.com'
        GIT_URL   = 'https://github.com/Amita749/Jenkins_Pipeline.git'
    }

    parameters {
        choice(name: 'BRANCH_NAME', choices: ['feature/dev1','feature/dev2','main'], description: 'Git branch to deploy from')
        choice(name: 'TARGET_ORG', choices: ['Jenkins1', 'Jenkins2'], description: 'Select target Salesforce Org')
        string(name: 'METADATA', defaultValue: '', description: 'Metadata to deploy (comma separated)')
    }

    stages {

        stage('Debug Parameters') {
            steps {
                echo "BRANCH_NAME = ${params.BRANCH_NAME}"
                echo "TARGET_ORG  = ${params.TARGET_ORG}"
                echo "METADATA    = ${params.METADATA}"
            }
        }

        stage('Checkout Git Branch') {
            steps {
                echo "Checking out branch: ${params.BRANCH_NAME}"
                git branch: "${params.BRANCH_NAME}", url: "${GIT_URL}"
            }
        }

        stage('Authenticate Target Org') {
            steps {
                script {
                    // Map orgs to Jenkins credential IDs and usernames
                    def credsMap = [
                        Jenkins1: [consumerCredId: 'JENKINS1_CONSUMER_KEY', user: 'naman.rawat@dynpro.com.jenkins1'],
                        Jenkins2: [consumerCredId: 'JENKINS2_CONSUMER_KEY', user: 'naman.rawat@dynpro.com.jenkins2']
                    ]
                    def creds = credsMap[params.TARGET_ORG]

                    // Fetch consumer key dynamically from Jenkins credentials
                    withCredentials([string(credentialsId: creds.consumerCredId, variable: 'CONSUMER_KEY')]) {
                        echo "Authenticating ${params.TARGET_ORG} with user ${creds.user}"

                        bat """
                        sf auth jwt grant ^
                        --client-id ${CONSUMER_KEY} ^
                        --jwt-key-file "${JWT_KEY}" ^
                        --username ${creds.user} ^
                        --instance-url ${SFDC_HOST} ^
                        --alias ${params.TARGET_ORG}
                        """
                    }
                }
            }
        }

        stage('Prepare Manifest') {
            steps {
                bat """
                if not exist manifest mkdir manifest
                echo Generating package.xml for metadata: ${params.METADATA}
                sf project generate manifest --metadata "${params.METADATA}" --output-dir manifest
                type manifest\\package.xml
                """
            }
        }

      stage('Deploy to Target Org') {
    steps {
        bat """
        echo Deploying to ${params.TARGET_ORG}
        sf project deploy start ^
        --manifest manifest\package.xml ^
        --target-org ${params.TARGET_ORG} ^
        --test-level NoTestRun ^
        --json ^
        --ignore-conflicts
        """
    }
}
    }

    

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Deployment failed. Check the console output for errors."
        }
    }
}
