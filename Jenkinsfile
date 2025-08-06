pipeline {
    agent any

    environment {
        PROJECT_NAME = 'MyWebApp'
        DOCKER_IMAGE = 'mywebapp:latest'
        CONTAINER_NAME = 'MyWebApp-container'
        PORT = '82'

        // Thông tin Docker Hub
        DOCKERHUB_USERNAME = credentials('vanesline') // Jenkins credential ID
        DOCKERHUB_TOKEN = credentials('dckr_pat_OfOBTRXluUCmGfJSA1efWzQGcvQ')       // Jenkins credential ID
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

        stage('Push to Docker Hub') {
            steps {
                script {
                    def fullImageName = "${DOCKERHUB_USERNAME}/mywebapp:latest"

                    sh """
                        echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                        docker tag $DOCKER_IMAGE $fullImageName
                        docker push $fullImageName
                        docker logout
                    """
                }
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
