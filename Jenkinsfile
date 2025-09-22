pipeline {
    agent any

    environment {
        JWT_KEY   = credentials('sf_jwt_key') // JWT private key stored in Jenkins
        SFDC_HOST = 'https://test.salesforce.com'
        GIT_URL   = 'https://github.com/Amita749/Jenkins_Pipeline.git'
    }

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'feature/dev1', description: 'Git branch to deploy from')
        choice(name: 'TARGET_ORG', choices: ['Jenkins1', 'Jenkins2'], description: 'Select target Salesforce Org')
        string(name: 'METADATA', defaultValue: 'ApexClass:MathHelper', description: 'Metadata to deploy (comma separated)')
    }

    stages {
        stage('Checkout Git Branch') {
            steps {
                echo "Checking out branch: ${params.BRANCH_NAME}"
                git branch: "${params.BRANCH_NAME}", url: "${GIT_URL}"
            }
        }

        stage('Authenticate Target Org') {
            steps {
                script {
                    // Map org aliases to their Consumer Keys and usernames
                    def credsMap = [
                        Jenkins1: [consumer: '3MVG9LY8n98IRTt0nbrFoCu_WHYCMj4Y_8VTI3HR0VXMQJ8Ebd3vVJBOml0d.rG6Xj5FpYKvbgYnh5tmp1DMl', user: 'naman.rawat@dynpro.com.jenkins1'],
                        Jenkins2: [consumer: '3MVG9yFeMD.c3Gem6rRxnz7Izrn.P_h1U4SLqxUuP9SyLTVn.69cxB_preVAT1vU2MQKIB_RLF3Y.7W_lvoTE', user: 'naman.rawat@dynpro.com.jenkins2']
                    ]
                    def creds = credsMap[params.TARGET_ORG]

                    echo "Authenticating ${params.TARGET_ORG} using JWT key at: ${JWT_KEY}"

                    bat """
                    sf auth jwt grant ^
                    --client-id ${creds.consumer} ^
                    --jwt-key-file "${JWT_KEY}" ^
                    --username ${creds.user} ^
                    --instance-url ${SFDC_HOST} ^
                    --alias ${params.TARGET_ORG}
                    """
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
                --manifest manifest\\package.xml ^
                --target-org ${params.TARGET_ORG} ^
                --test-level NoTestRun ^
                --json
                """
            }
        }

        stage('Validate Deployment') {
            steps {
                echo "Deployment finished. Check logs for any errors above."
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
