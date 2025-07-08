pipeline {
  agent any

  environment {
    ACR_NAME = 'demogit'                             // only ACR name (no domain)
    ACR_NAME_FULL = 'demogit.azurecr.io'             // full domain for tagging
    IMAGE_NAME = 'myapp'
    TENANT_ID = '3b6e02a4-df52-4727-ab5f-876c0e1261d6'
    SUBSCRIPTION_ID = '01ca380c-fcf2-4075-8c67-82b2de4de29a'
  }

  stages {

    stage('Checkout Code') {
      steps {
        git 'https://github.com/prakash4600/demo.git'
      }
    }

    stage('Login to Azure') {
      steps {
        withCredentials([
          usernamePassword(
            credentialsId: 'azure-sp',
            usernameVariable: 'AZURE_CLIENT_ID',
            passwordVariable: 'AZURE_CLIENT_SECRET'
          )
        ]) {
          sh '''
            az logout || true
            az login --service-principal \
              -u $AZURE_CLIENT_ID \
              -p $AZURE_CLIENT_SECRET \
              --tenant $TENANT_ID
              
            az account set --subscription $SUBSCRIPTION_ID
          '''
        }
      }
    }

    stage('Login to ACR') {
      steps {
        sh "az acr login --name $ACR_NAME"
      }
    }

    stage('Build and Push Docker Image') {
      steps {
        script {
          def image_latest = "${ACR_NAME_FULL}/${IMAGE_NAME}:latest"
          def image_build = "${ACR_NAME_FULL}/${IMAGE_NAME}:${BUILD_NUMBER}"

          sh """
            docker build -t $image_latest -t $image_build .
            docker push $image_latest
            docker push $image_build
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
