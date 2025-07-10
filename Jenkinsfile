pipeline {
  agent any

  environment {
    ACR_NAME       = 'demogit'                      // ACR name only
    ACR_NAME_FULL  = 'demogit.azurecr.io'           // Full ACR URL
    IMAGE_NAME     = 'myapp'                        // Docker image name
    AKS_CLUSTER    = 'Last'                         // AKS Cluster Name
    RESOURCE_GROUP = 'Rahul'                        // Azure Resource Group
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
          string(credentialsId: 'AZURE_CLIENT_ID', variable: 'AZURE_CLIENT_ID'),
          string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'AZURE_CLIENT_SECRET'),
          string(credentialsId: 'AZURE_TENANT_ID', variable: 'AZURE_TENANT_ID'),
          string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'AZURE_SUBSCRIPTION_ID')
        ]) {
          sh '''
            echo "🔐 Logging in to Azure..."
            az logout || true
            az login --service-principal \
              --username $AZURE_CLIENT_ID \
              --password $AZURE_CLIENT_SECRET \
              --tenant $AZURE_TENANT_ID
            az account set --subscription $AZURE_SUBSCRIPTION_ID
          '''
        }
      }
    }

    stage('Docker Login to ACR') {
      steps {
        sh '''
          echo "🔐 Logging into ACR..."
          USERNAME=$(az acr credential show --name $ACR_NAME --query "username" -o tsv)
          PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
          echo "$PASSWORD" | docker login $ACR_NAME_FULL -u "$USERNAME" --password-stdin
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def latestTag = "${ACR_NAME_FULL}/${IMAGE_NAME}:latest"
          def buildTag  = "${ACR_NAME_FULL}/${IMAGE_NAME}:${BUILD_NUMBER}"

          sh """
            echo "🐳 Building Docker image..."
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
            echo "📤 Pushing Docker image to ACR..."
            docker push ${latestTag}
            docker push ${buildTag}
          """
        }
      }
    }

    stage('Get AKS Credentials') {
      steps {
        sh '''
          echo "🔄 Getting AKS credentials..."
          az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing
        '''
      }
    }

    stage('Deploy to AKS') {
      steps {
        sh '''
          echo "🚀 Deploying to AKS..."
          kubectl apply -f ./K8s/Deployment.yaml
        '''
      }
    }
  }

  post {
    always {
      sh '''
        echo "⚙️ Cleanup: Docker logout"
        docker logout $ACR_NAME_FULL || true
      '''
    }
  }
}
