pipeline {
    agent any

    environment {
        // Define the environment variable with the BUILD NUMBER
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "gihan4/helmredis"
        CHART_DIRECTORY = "./redis_flask/thechart"
        BUCKET_NAME = "helmbucket4"
        CHART_RELEASE = "myflask-release"
    }

    stages {
        stage('Cleanup') {
            steps {
                echo "Cleaning up..."
                // removes all files and directories in the current working directory 
                sh 'rm -rf *'
            }
        }

        stage('Remove old Images from local machine') {
            steps {
                // Delete from Jenkins local server
                echo "Stopping and removing containers and images on Jenkins server..."
                script {
                    // List all images associated with the DOCKER IMAGE repository
                    def dockerImages = sh(script: "docker images --filter=reference='$DOCKER_IMAGE' --format '{{.Repository}}:{{.Tag}}'", returnStdout: true).trim()

                    // Split the images into an array
                    def imagesArray = dockerImages.split()

                    // Remove each image (repository:tag) one by one
                    imagesArray.each { image ->
                        sh "docker rmi -f $image"
                    }
                }
            }
        }

        stage('Clone') {
            steps {
                echo "Cloning repository..."
                sh 'git clone https://github.com/Gihan4/redis_flask.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker flask image ..."
                dir('redis_flask') {
                    // build image with a new tag
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push app Image to Docker Hub') {
            steps {
                echo "Pushing Docker image to Docker Hub..."
                sh 'docker push --all-tags ${DOCKER_IMAGE}'
            }
        }

        stage('Modify Chart.yaml Version') {
            steps {
                echo "Modifying Chart.yaml version..."
                sh """\
                echo -e "apiVersion: v2\\nname: FlaskX\\nversion: 1.\${BUILD_NUMBER}.0\\ndescription: A Helm chart for K8S for deploying flask and redis" > ${CHART_DIRECTORY}/Chart.yaml
                """
            }
        }

        stage('Package Helm Chart') {
            steps {
                sh "helm package ${CHART_DIRECTORY}"
            }
        }

        stage('Connect to Test Cluster') {
            steps {
                sh 'gcloud container clusters get-credentials test-cluster --zone us-central1-a --project formidable-hold-392607'
            }
        }

        stage('Deploy to Test Cluster') {
            steps {
                script {
                    // list all Helm releases in JSON format, to filter the release name.
                    def helmRelease = sh(returnStdout: true, script: "helm list -o json | jq '.[] | select(.name==\"${CHART_RELEASE}\") | .name'").trim()

                    if (helmRelease) {
                        // If the Helm release already exists in the cluster, perform an upgrade with the new image tag
                        echo 'chart already installed'
                        echo 'Performing upgrade'
                        sh "helm upgrade $CHART_RELEASE $CHART_DIRECTORY --set VER=$BUILD_NUMBER"
                    } else {
                        // If the Helm release does not exist in the cluster, perform an install with the new image tag
                        echo 'installing the chart'
                        sh "helm install $CHART_RELEASE $CHART_DIRECTORY --set VER=$BUILD_NUMBER"
                    }
                }
            }
        }



        stage('Test Cluster') {
            steps {
                script {
                    // Sleep for 1 minute
                    sleep(time: 90, unit: 'SECONDS')
                    
                    def SERVICE_NAME = "flask-service"
        
                    // Get the external IP of the Load Balancer associated with the Service.
                    def EXTERNAL_IP = sh(script: "kubectl get svc $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}'", returnStdout: true).trim()
        
                    if (EXTERNAL_IP.isEmpty()) {
                        echo "Load Balancer IP not found. Check if the Load Balancer is provisioned and the Service is exposed correctly."
                        currentBuild.result = 'FAILURE'
                        return
                    }
        
                    def FLASK_APP_URL = "http://$EXTERNAL_IP"
        
                    // Send a GET request to your Flask application and store the HTTP status code in a variable.
                    def HTTP_STATUS = sh(script: "curl -s -o /dev/null -w %{http_code} $FLASK_APP_URL", returnStdout: true).trim().toInteger()
        
                    // Check if the HTTP status code is 200 (OK), so flask is up
                    def EXPECTED_STATUS_CODE = 200
        
                    if (HTTP_STATUS == EXPECTED_STATUS_CODE) {
                        echo "Flask application is running successfully. HTTP status code: $HTTP_STATUS"
                    } else {
                        echo "Flask application is not running as expected. HTTP status code: $HTTP_STATUS"
                        currentBuild.result = 'FAILURE'
                        return
                    }
                }
            }
        }

        stage('Upload Helm Chart to GCS Bucket') {
            steps {
                // copy the package ffrom the workspace to a gcp bucket.
                sh "gsutil cp /var/lib/jenkins/workspace/K8S_HELM/FlaskX-1.${BUILD_NUMBER}.0.tgz gs://${BUCKET_NAME}/"
            }
        }

        stage('Connect Production Cluster') {
            steps {
                echo "connecting to the cluster..."
                sh 'gcloud container clusters get-credentials prod-cluster --zone us-central1-a --project formidable-hold-392607'
            }
        }

        stage('Deploy to Prod Cluster') {
            steps {
                script {
                    def helmRelease = sh(returnStdout: true, script: "helm list -o json | jq '.[] | select(.name==\"${CHART_RELEASE}\") | .name'").trim()

                    if (helmRelease) {
                        // If the Helm release exists, perform an upgrade with the new image tag
                        echo 'chart already installed'
                        echo 'Performing upgrade'
                        sh "helm upgrade $CHART_RELEASE $CHART_DIRECTORY --set VER=$BUILD_NUMBER"
                    } else {
                        // If the Helm release does not exist, perform an install with the new image tag
                        echo 'installing the chart'
                        sh "helm install $CHART_RELEASE $CHART_DIRECTORY --set VER=$BUILD_NUMBER"
                    }
                }
            }
        }


    }
}
