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
         stage('Run Tests and Coverage Before Deployment') {
             steps {
        // Run tests  AdderTest before deploying
        bat 'sf apex run test --target-org %TARGET_ALIAS% --tests AdderTest --code-coverage --json --output-dir coverage-results --wait 10'
    }
         }
      stage('Deploy Metadata to Target Org') {
    steps {
        bat 'sf project deploy start --manifest manifest/package.xml --target-org %TARGET_ALIAS% --wait 10 --ignore-conflicts --test-level RunSpecifiedTests --tests AdderTest'
    }
}
         
    }
    

    post {
        always {
            echo 'Deployment pipeline finished.'
        
        }
    }
}
