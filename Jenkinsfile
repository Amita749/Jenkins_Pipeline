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
                git branch: "${params.BRANCH_NAME}", url: "${GIT_URL}"
            }
        }

        stage('Authenticate Target Org') {
            steps {
                script {
                    // Map org aliases to their Consumer Keys and usernames
                    def credsMap = [
                        Jenkins1: [consumer: '3MVG9LY8n98IRTt0nbrFoCu_WHYCMj4Y_8VTI3HR0VXMQJ8Ebd3vVJBOml0d.rG6Xj5FpYKvbgYnh5tmp1DMl', user: 'jenkins1@example.com'],
                        Jenkins2: [consumer: '3MVG9yFeMD.c3Gem6rRxnz7Izrn.P_h1U4SLqxUuP9SyLTVn.69cxB_preVAT1vU2MQKIB_RLF3Y.7W_lvoTE', user: 'jenkins2@example.com']
                    ]
                    def creds = credsMap[params.TARGET_ORG]

                    // Authenticate Salesforce CLI to the selected org
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

        stage('Generate package.xml') {
            steps {
                bat """
                    sf project generate manifest --metadata "${params.METADATA}" --output-dir manifest
                    type manifest\\package.xml
                """
            }
        }

        stage('Deploy to Target Org') {
            steps {
                bat """
                    sf project deploy start ^
                    --manifest manifest\\package.xml ^
                    --target-org ${params.TARGET_ORG} ^
                    --test-level NoTestRun
                """
            }
        }
    }

    post {
        always {
            echo 'Deployment finished successfully.'
        }
    }
}
