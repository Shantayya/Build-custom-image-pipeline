pipeline{
    agent{
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            metadata:
               lables: 
                  app: test
            spec:
              containers:
              - name: git
                image: bitnami/git:latest
                command:
                - cat
                tty: true
              - name: docker
                image: docker:latest
                command:
                - cat
                tty: true
              - name: kubectl-helm
                image: shantayya/kubectl-helm-cli:latest
                command:
                - cat
                tty: true
                volumeMounts:
                - name: docker-sock
                  mountPath: /var/run/docker.sock  
              volumes:
              - name: docker-sock
                hostPath:
                  path: /var/run/docker.sock    
                '''
                }
    }
    environment{
        DOCKERHUB_USERNAME = "shantayya"
        APP_NAME = "kubectl-helm-cli"
        IMAGE_NAME = "${DOCKERHUB_USERNAME}"+"/"+"${APP_NAME}"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }
    options{
        buildDiscarder(logRotator(numToKeepStr: '2'))
    }
    stages{
         stage('Clean Workspace'){
            when { expression { true}}
            steps{
                container('jnlp'){
                    script{
                        sh 'echo "Cleaning workspace"'
                        deleteDir()
                    }
                }       
            }
        }
        stage('SCM Checkout'){
            when { expression { true}}
            steps{
                container('git'){
                    git branch: 'master',
                    url: 'https://github.com/Shantayya/Build-custom-image-pipeline.git'
                }       
            }
        }
        stage('Build Docker Image'){
                when { expression { false }}
                steps{
                    container('docker'){
                        sh "docker build -t $IMAGE_NAME:$IMAGE_TAG ."
                        sh " docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest"
                        withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                                sh "docker login -u $USER -p $PASS"
                                sh "docker push $IMAGE_NAME:$IMAGE_TAG"
                                sh "docker push $IMAGE_NAME:latest"
                            }
                            sh "docker rmi $IMAGE_NAME:$IMAGE_TAG"
                            sh "docker rmi $IMAGE_NAME:latest"
                        }
                    }
            }
            stage('Deploy Spring-petclinic to K8s Cluster'){
                when { expression { true}}
                steps{
                    container('kubectl'){
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'kubeconfig', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                                sh "kubectl apply -f deployment.yaml" 
                            }
                        }
                    }
                post{
                    success{
                        sh 'echo "Deployment Success"'
                    }
                }
            }             
    }          
}
