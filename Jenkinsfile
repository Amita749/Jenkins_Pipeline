pipeline {
    agent any

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'feature/dev1', description: 'Git branch to deploy from')
        choice(name: 'TARGET_ORG', choices: ['Jenkins1', 'Jenkins2'], description: 'Target Salesforce Org')
        string(name: 'METADATA', defaultValue: 'ApexClass:MathHelper', description: 'Metadata to deploy (comma separated)')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH_NAME}",
                    url: 'https://github.com/Amita749/Salesforce-CICD.git'
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

        stage('Deploy to Org') {
            steps {
                bat """
                sf project deploy start --manifest manifest\\package.xml --target-org ${params.TARGET_ORG} --test-level NoTestRun
                """
            }
        }
    }
}
