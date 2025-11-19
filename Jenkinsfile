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
                    def branchName = env.GIT_BRANCH ?: sh(
                        script: "git rev-parse --abbrev-ref HEAD",
                        returnStdout: true
                    ).trim()

                    env.ACTUAL_BRANCH = branchName.replace("origin/", "")
                }

                git branch: "${env.ACTUAL_BRANCH}",
                    url: "https://github.com/Prem18062000/build-app.git",
                    credentialsId: "github-creds"

                echo "Branch Detected: ${env.ACTUAL_BRANCH}"

                // Make repo available for other nodes
                stash name: 'appsource', includes: '**/*'
            }
        }


        /***********************
         * BUILD DOCKER IMAGE
         ***********************/
        stage('Build Docker Image') {
            agent { label 'build_agent' }
            steps {
                unstash 'appsource'

                script {
                    def buildContext = "build/"

                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "Building DEV Docker image..."
                        sh "sudo docker build -t $DEV_IMAGE -f build/Dockerfile ${buildContext}"
                    }
                    else if (env.ACTUAL_BRANCH == "prod") {
                        echo "Building PROD Docker image..."
                        sh "sudo docker build -t $PROD_IMAGE -f build/Dockerfile ${buildContext}"
                    }
                    else {
                        error "Unsupported branch: ${env.ACTUAL_BRANCH}"
                    }
                }
            }
        }


        /***********************
         * PUSH DOCKER IMAGE
         ***********************/
        stage('Push Docker Image') {
            agent { label 'build_agent' }
            steps {
                unstash 'appsource'

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

                    /***********************
                     * DEV DEPLOYMENT
                     ***********************/
                    if (env.ACTUAL_BRANCH == "dev") {
                        echo "Deploying to DEV environment..."

                        node('project_1_dev') {

                            unstash 'appsource'  // <---- RESTORES FILES HERE

                            sh """
                                cp docker-compose.yaml ~/docker-compose.yaml
                                cp deploy.sh ~/deploy.sh
                                chmod +x ~/deploy.sh
                            """

                            sh "bash ~/deploy.sh $DEV_IMAGE"
                        }
                    }


                    /***********************
                     * PROD DEPLOYMENT
                     ***********************/
                    if (env.ACTUAL_BRANCH == "prod") {
                        echo "Deploying to PROD environment..."

                        node('project_1_prod') {

                            unstash 'appsource'

                            sh """
                                cp docker-compose.yaml ~/docker-compose.yaml
                                cp deploy.sh ~/deploy.sh
                                chmod +x ~/deploy.sh
                            """

                            sh "bash ~/deploy.sh $PROD_IMAGE"
                        }
                    }

                } // script
            } // steps
        } // stage

    } // stages

} // pipeline
