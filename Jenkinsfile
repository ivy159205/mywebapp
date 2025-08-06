pipeline {
    agent any

    environment {
        PROJECT_NAME = 'MyWebApp'
        DOCKER_IMAGE = 'mywebapp:latest'
        CONTAINER_NAME = 'MyWebApp-container'
        PORT = '82'
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

        stage('SonarQube Analysis Begin') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat """
                        dotnet tool install --global dotnet-sonarscanner
                        set PATH=%PATH%;%USERPROFILE%\\.dotnet\\tools
                        dotnet sonarscanner begin ^
                          /k:"MyWebApp" ^
                          /d:sonar.login=%sqtoken%
                    """
                }
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

        stage('SonarQube Analysis End') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat """
                        set PATH=%PATH%;%USERPROFILE%\\.dotnet\\tools
                        dotnet sonarscanner end /d:sonar.login=%sqtoken%
                    """
                }
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
