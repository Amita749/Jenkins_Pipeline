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
        string(name: 'ROLLBACK_COMMIT', defaultValue: '', description: 'Commit ID to rollback to (leave blank to use backup)')
    }

    stages {

        stage('Debug Parameters') {
            steps {
                echo "ACTION      = ${params.ACTION}"
                echo "BRANCH_NAME = ${params.BRANCH_NAME}"
                echo "TARGET_ORG  = ${params.TARGET_ORG}"
                echo "METADATA    = ${params.METADATA}"
                echo "ROLLBACK_COMMIT = ${params.ROLLBACK_COMMIT}"
            }
        }

        stage('Checkout Git Branch') {
            when { expression { params.ACTION == 'DEPLOY' || (params.ACTION == 'ROLLBACK' && params.ROLLBACK_COMMIT?.trim()) } }
            steps {
                echo "Checking out branch: ${params.BRANCH_NAME}"
                git branch: "${params.BRANCH_NAME}", url: "${GIT_URL}"

                script {
                    if (params.ACTION == 'ROLLBACK' && params.ROLLBACK_COMMIT?.trim()) {
                        echo "Rolling back to commit: ${params.ROLLBACK_COMMIT}"
                        sh "git checkout ${params.ROLLBACK_COMMIT}"
                    }
                }
            }
        }

        stage('Authenticate Target Org') {
            steps {
                script {
                    def credsMap = [
                        Jenkins1: [consumerCredId: 'JENKINS1_CONSUMER_KEY', user: 'naman.rawat@dynpro.com.jenkins1'],
                        Jenkins2: [consumerCredId: 'JENKINS2_CONSUMER_KEY', user: 'naman.rawat@dynpro.com.jenkins2']
                    ]
                    def creds = credsMap[params.TARGET_ORG]

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

        stage('Backup Target Org') {
            when { expression { params.ACTION == 'DEPLOY' } }
            steps {
                bat """
                echo Taking backup from ${params.TARGET_ORG}...
                if not exist backup mkdir backup
                sf project retrieve start ^
                --manifest manifest\\package.xml ^
                --target-org ${params.TARGET_ORG} ^
                --output-dir backup\\${params.TARGET_ORG}
                tar -czf backup_${params.TARGET_ORG}.tar.gz backup\\${params.TARGET_ORG}
                """
                archiveArtifacts artifacts: "backup_${params.TARGET_ORG}.tar.gz", fingerprint: true
            }
        }

        stage('Prepare Manifest') {
            when { expression { params.ACTION == 'DEPLOY' || (params.ACTION == 'ROLLBACK' && params.ROLLBACK_COMMIT?.trim()) } }
            steps {
                bat """
                if not exist manifest mkdir manifest
                echo Generating package.xml for metadata: ${params.METADATA}
                sf project generate manifest --metadata "${params.METADATA}" --output-dir manifest
                type manifest\\package.xml
                """
            }
        }

        stage('Deploy or Rollback') {
            steps {
                script {
                    if (params.ACTION == 'DEPLOY') {
                        bat """
                        echo Deploying to ${params.TARGET_ORG}...
                        sf project deploy start ^
                        --manifest manifest\\package.xml ^
                        --target-org ${params.TARGET_ORG} ^
                        --test-level NoTestRun
                        """
                    } else {
                        if (params.ROLLBACK_COMMIT?.trim()) {
                            bat """
                            echo Rolling back to commit ${params.ROLLBACK_COMMIT} on ${params.TARGET_ORG}...
                            sf project deploy start ^
                            --manifest manifest\\package.xml ^
                            --target-org ${params.TARGET_ORG} ^
                            --test-level NoTestRun
                            """
                        } else {
                            bat """
                            echo Rolling back using last backup for ${params.TARGET_ORG}...
                            tar -xzf backup_${params.TARGET_ORG}.tar.gz
                            sf project deploy start ^
                            --source-dir backup\\${params.TARGET_ORG} ^
                            --target-org ${params.TARGET_ORG} ^
                            --test-level NoTestRun
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ ${params.ACTION} completed successfully!"
        }
        failure {
            echo "❌ ${params.ACTION} failed. Check console output for errors."
        }
    }
}
