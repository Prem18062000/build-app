pipeline {
    agent none

    environment {
        DEV_IMAGE  = "prem18062000/react-app-dev:latest-dev"
        PROD_IMAGE = "prem18062000/react-app-prod:latest-prod"
    }

    stages {

        /***********************
         * CHECKOUT CODE
         ***********************/
        stage('Checkout Code') {
            agent any
            steps {
                script {
                    // Detect branch correctly
                    def branchName = env.GIT_BRANCH ?: sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
                    env.ACTUAL_BRANCH = branchName.replace("origin/", "")
                }

                git branch: "${env.ACTUAL_BRANCH}",
                    url: "https://github.com/Prem18062000/build-app.git",
                    credentialsId: "github-creds"

                echo "Branch Detected: ${env.ACTUAL_BRANCH}"
            }
        }

        /***********************
         * BUILD DOCKER IMAGE
         ***********************/
        stage('Build Docker Image') {
            agent any
            steps {
                script {
        
                    def buildContext = "build/"   // IMPORTANT
        
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "Building DEV Docker image..."
                        sh "sudo docker build -t $DEV_IMAGE ${buildContext}"
                    }
                    else if (env.ACTUAL_BRANCH == "prod") {
                        echo "Building PROD Docker image..."
                        sh "sudo docker build -t $PROD_IMAGE ${buildContext}"
                    }
                    else {
                        error "Unsupported branch: ${env.ACTUAL_BRANCH}. Only 'dev' and 'prod' are allowed."
                    }
                }
            }
        }


        /***********************
         * PUSH DOCKER IMAGE
         ***********************/
        stage('Push Docker Image') {
            agent any
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    script {
                        sh """
                            echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin
                        """

                        if (env.ACTUAL_BRANCH == "dev") {
                            echo "Pushing DEV Docker image..."
                            sh "sudo docker push $DEV_IMAGE"
                        }
                        else if (env.ACTUAL_BRANCH == "prod") {
                            echo "Pushing PROD Docker image..."
                            sh "sudo docker push $PROD_IMAGE"
                        }
                    }
                }
            }
        }

        /***********************
         * DEPLOY TO SERVERS
         ***********************/
        stage('Deploy to Environment') {
            steps {
                script {
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "Deploying to DEV environment..."
                        node('project_1_dev') {
                            sh "bash ~/deploy.sh $DEV_IMAGE"
                        }
                    }

                    if (env.ACTUAL_BRANCH == "prod") {
                        echo "Deploying to PROD environment..."
                        node('project_1_prod') {
                            sh "bash ~/deploy.sh $PROD_IMAGE"
                        }
                    }
                }
            }
        }
    }
}
