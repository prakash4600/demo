pipeline {
  agent any

  environment {
    ACR_NAME = 'demogit.azurecr.io'     // replace with your ACR FQDN
    IMAGE_NAME = 'myapp'                   // replace with your app/image name
    TENANT_ID = '3b6e02a4-df52-4727-ab5f-876c0e1261d6  '         // your Azure tenant ID
    SUBSCRIPTION_ID = '01ca380c-fcf2-4075-8c67-82b2de4de29a'   // your Azure subscription ID
  }

  stages {

    stage('Checkout Code') {
      steps {
        git 'https://github.com/prakash4600/demo.git'   // ✅ replace with your repo
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

    stage('ACR Login') {
      steps {
        sh "az acr login --name ${ACR_NAME%%.azurecr.io}"
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          IMAGE_TAG_LATEST = "${ACR_NAME}/${IMAGE_NAME}:latest"
          IMAGE_TAG_BUILD  = "${ACR_NAME}/${IMAGE_NAME}:${BUILD_NUMBER}"
          sh """
            docker build -t $IMAGE_TAG_LATEST -t $IMAGE_TAG_BUILD .
          """
        }
      }
    }

    stage('Push Docker Image to ACR') {
      steps {
        script {
          sh """
            docker push ${ACR_NAME}/${IMAGE_NAME}:latest
            docker push ${ACR_NAME}/${IMAGE_NAME}:${BUILD_NUMBER}
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
