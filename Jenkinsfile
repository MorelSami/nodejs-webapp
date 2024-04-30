pipeline {
    agent any 

    options {
       timeout(time: 10, unit: 'MINUTES')
    }

    environment {
    ACR_NAME = "samiacr"
    registryUrl = "samiacr.azurecr.io"
    IMAGE_NAME = "nodejs-webapp"
    IMAGE_TAG = "v1.0.0"
    registryCredential  = "sami-acr-creds"
    }

    stages { 
        stage('SCM Checkout') {
            steps{
           git branch: 'main', url: 'https://github.com/MorelSami/nodejs-webapp.git'
            }
        }
        // run sonarqube test
        stage('Run Sonarqube') {
            environment {
                scannerHome = tool 'ibt-sonarqube';
            }
            steps {
              withSonarQubeEnv(credentialsId: 'smorel-ibt-sonar', installationName: 'IBT sonarqube') {
                sh "${scannerHome}/bin/sonar-scanner"
              }
            }
        }
       // Building Docker Image 
       stage ('Build Docker image') {
        steps {
                script {
                    //dockerImage = docker.build registryUrl
                 def dockerImage = docker.build("${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}", '.') 
                }
            }
       } 
    // Uploading Docker images into ACR
        stage('Push Image to ACR') {
         steps{   
             script {
                 docker.withRegistry( "http://${ACR_NAME}.azurecr.io", registryCredential ) {
               // dockerImage.push()
              sh " docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"
                  }
              }
         }
      }
    }
}
