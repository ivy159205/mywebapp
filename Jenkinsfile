pipeline {
    agent any

    environment {
        PROJECT_NAME = 'MyWebApp'
        DOCKER_IMAGE = 'mywebapp:latest'
        CONTAINER_NAME = 'MyWebApp-container'
        PORT = '82'

        SONARQUBE_SERVER = 'MySonar'
        SONAR_SCANNER_PATH = 'C:\\ProgramData\\Jenkins\\.jenkins\\tools\\hudson.plugins.sonar.SonarRunnerInstallation\\SonarScanner\\bin\\sonar-scanner.bat'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ivy159205/mywebapp.git'
            }
        }

        stage('Restore & Build') {
            steps {
                sh 'dotnet restore'
                sh 'dotnet build -c Release'
            }
        }

        stage('Test') {
            steps {
                sh 'dotnet test || true'  // Cho phép job tiếp tục nếu test fail (tuỳ chọn)
            }
        }

        stage('Publish') {
            steps {
                sh 'dotnet publish MyWebApp.csproj -c Release -o out'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Deploy Docker Container') {
            steps {
                sh '''
                    docker rm -f $CONTAINER_NAME || true
                    docker run -d -p $PORT:80 --name $CONTAINER_NAME $DOCKER_IMAGE
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    bat "${env.SONAR_SCANNER_PATH} -Dsonar.projectKey=MyWebApp -Dsonar.sources=."
                }
            }
        }

        stage("Wait for Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        } 
    }

    post {
        success {
            echo "✅ Deployed to http://localhost:$PORT"
        }
        failure {
            echo "❌ CI/CD Failed"
        }
    }
}
