# CI/CD Project

Welcome! This project focuses on continuous integration and continuous deployment using Jenkins, Docker, Kubernetes, and Helm.
You have the options to control Infrastructure as code using Terraform and monitor using Prometheus and Grafana.
It includes a Flask application, a Jenkinsfile for build, test, approval, and deploy stages, as well as scripts for deployment and testing.


## Prerequisites

Before running this project, please ensure that you have the following:

- Open Ubuntu server
- Install Jenkins, Docker, AWS CLI, gcloud CLI, and Helm.
- Add the jenkins user to the docker group.
```sh
sudo usermod -aG docker jenkins
```

- Add the following line to the sudoers file on the Jenkins server to allow Jenkins to restart the Flask service:
```sh
jenkins ALL=(ALL) NOPASSWD: /bin/systemctl restart flask.service
```

- Perform `docker login -u <user>` with Docker Hub PAT as the password with the jenkins user.
- Perform `gcloud auth login <account>` with the jenkins user.
- Perform Kubectl authentication with your gcloud.
- Create a GCP GKE cluster and a GCP GCE instance.
- Add a .env file to your Jenkins server at `/var/lib/jenkins`, configured as this:
```sh
API_KEY=<your API key> # Remove this line if you're not using an API in your Flask application
DOCKER_USERNAME=<your Docker Hub username>
DOCKER_PASSWORD=<your Docker Hub password>
```


## Getting Started

To get started with this project, please follow these steps:

1. Launch Jenkins on your server and set it up.

2. Create a new pipeline job.

3. Change variables in all relevant files.
- Note: not all variables are defined, so double-check Jenkinsfile, deploy.sh, manifest.yaml, and docker-compose.yml

4. In the pipeline configuration, specify the Jenkinsfile from `https://github.com/Raz-Dahan/pipelines.git` or the one you've imported.

5. Customize the Jenkinsfile to enable/disable the approval stage based on your requirements.

## Running the Project

Once you have completed the setup, you can run the project using the following steps:

1. Build and deploy the project by running the Jenkins pipeline job.

2. The pipeline will build the Docker image, run tests on a VM using Docker compose, and deploy the Flask application and Redis database on a cluster using Kubernetes.

3. Access the Flask application by entering the public IP address of the Load balancer service in your web browser.

4. Test the application's functionality, ensuring it meets the requirements.

5. To access the monitoring tools, go to GCP Console > Kubernetes Engine > "Services & Ingress" > prometheus-grafana > edit > change "metadata: type" to LoadBalancer, then enter these Grafana credentials:

```sh
username: admin
password: prom-operator
```


