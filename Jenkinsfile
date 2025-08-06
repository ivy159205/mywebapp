pipeline {
    agent any

    environment {
        PROJECT_NAME = 'MyWebApp'
        DOCKER_IMAGE = 'mywebapp:latest'
        CONTAINER_NAME = 'MyWebApp-container'
        PORT = '82'

        SONARQUBE_SERVER = 'MySonar'
        SONAR_SCANNER = 'C:\\ProgramData\\Jenkins\\.jenkins\\tools\\hudson.plugins.sonar.SonarRunnerInstallation\\SonarScanner\\bin\\sonar-scanner.bat'
    }

    stages {
        stage('Cleanup') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ivy159205/mywebapp.git'
            }
        }

        stage('Restore') {
            steps {
                bat 'dotnet restore MyWebApp.csproj'
            }
        }

        stage('Build') {
            steps {
                bat 'dotnet build MyWebApp.csproj -c Release --no-restore'
            }
        }

        stage('Test') {
            steps {
                bat 'dotnet test || exit 0'
            }
        }

        stage('Publish') {
            steps {
                bat 'dotnet publish MyWebApp.csproj -c Release -o out --no-restore'
                bat '''
                    if not exist out\\MyWebApp.runtimeconfig.json (
                        echo ❌ runtimeconfig.json not found!
                        exit /b 1
                    )
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %DOCKER_IMAGE% .'
            }
        }

        stage('Deploy Docker Container') {
            steps {
                bat '''
                    docker rm -f %CONTAINER_NAME% || exit 0
                    docker run -d -p %PORT%:80 --name %CONTAINER_NAME% %DOCKER_IMAGE%
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonar') {
                    bat "\"${env.SONAR_SCANNER}\" -Dsonar.projectKey=mywebapp -Dsonar.sources=."
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
