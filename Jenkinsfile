pipeline {
  agent any

  environment {
    ACR_NAME       = 'demogit'                      // ACR name only
    ACR_NAME_FULL  = 'demogit.azurecr.io'           // Full ACR URL
    IMAGE_NAME     = 'myapp'                        // Docker image name
  }

  stages {
    stage('Checkout Code') {
      steps {
        git 'https://github.com/prakash4600/demo.git'  // Your GitHub repo
      }
    }

    stage('Login to Azure') {
      steps {
        withCredentials([
          string(credentialsId: 'AZURE_CLIENT_ID', variable: 'AZURE_CLIENT_ID'),
          string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'AZURE_CLIENT_SECRET'),
          string(credentialsId: 'AZURE_TENANT_ID', variable: 'AZURE_TENANT_ID'),
          string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'AZURE_SUBSCRIPTION_ID')
        ]) {
          sh '''
            az logout || true
            az login --service-principal \
              -u $AZURE_CLIENT_ID \
              -p $AZURE_CLIENT_SECRET \
              --tenant $AZURE_TENANT_ID

            az account set --subscription $AZURE_SUBSCRIPTION_ID
          '''
        }
      }
    }

    stage('Login to ACR') {
      steps {
        sh "az acr login --name $ACR_NAME --expose-token"
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def latestTag = "${ACR_NAME_FULL}/${IMAGE_NAME}:latest"
          def buildTag  = "${ACR_NAME_FULL}/${IMAGE_NAME}:${BUILD_NUMBER}"

          sh """
            docker build -t ${latestTag} -t ${buildTag} .
          """
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          def latestTag = "${ACR_NAME_FULL}/${IMAGE_NAME}:latest"
          def buildTag  = "${ACR_NAME_FULL}/${IMAGE_NAME}:${BUILD_NUMBER}"

          sh """
            docker push ${latestTag}
            docker push ${buildTag}
          """
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
