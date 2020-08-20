pipeline {
  agent any
  environment {
    PRE_PROD_INVENTORY = "aws_preprod"
    STAGING_INVENTORY = "aws_staging"
    DEVELOPMENT_INVENTORY = "old_staging"
    PRE_PRODUCTION_BRANCH = /^release\/.*/
    STAGING_BRANCH = "integration"
    DEV_BRANCH = "cicd_dev"
    INVENTORY_NAME = """${
                BRANCH_NAME == DEV_BRANCH ? DEVELOPMENT_INVENTORY : 
                    BRANCH_NAME ==~ PRE_PRODUCTION_BRANCH ? PRE_PROD_INVENTORY : 
                        BRANCH_NAME == STAGING_BRANCH ? STAGING_INVENTORY : 'Unknown'
            }"""
  }
  stages {
      stage('Validate branch') {
        when {
            equals expected: 'Unknown',
            actual: env.INVENTORY_NAME
        }
        steps {
            script {
                    currentBuild.result = "ABORTED"
                    error "Aborting build as the branch not part of plan"
                    }
        }
      }
      stage('Generate CSS') {
		    steps {
                echo "The directory: ${WORKSPACE}" 
                sh '''
                cd classicrummy
                compass compile
                  '''
            }
        } 
        stage('Create Archive') {
            steps {
                echo "The branch: ${BRANCH_NAME} and the build ${BUILD_NUMBER}" 
                sh '''
                    cd classicrummy
                    touch drupal_themes_${BRANCH_NAME}_${BUILD_NUMBER}.tar.gz
                    touch drupal_themes_latest.tar.gz
                    tar --exclude="./images" --exclude="drupal_themes_${BRANCH_NAME}_${BUILD_NUMBER}.tar.gz" --exclude="drupal_themes_latest.tar.gz" -zcvf drupal_themes_${BRANCH_NAME}_${BUILD_NUMBER}.tar.gz .
                    tar --exclude="./images" --exclude="drupal_themes_${BRANCH_NAME}_${BUILD_NUMBER}.tar.gz" --exclude="drupal_themes_latest.tar.gz" -zcvf drupal_themes_latest.tar.gz .
                '''
            }
        }
        stage('Push to Artifactory') {
            steps {
                echo 'we will push the tar file to artifactory'
                rtServer (
                    id: 'jfrog',
                    url: 'http://10.16.51.18:8082/artifactory',
                    credentialsId: 'jfrog_login'
                )
                rtUpload (
                    serverId: 'jfrog',
                    spec: '''{
                      "files": [
                    {
                        "pattern": "classicrummy/drupal_themes*.tar.gz",
                        "target": "drupal_themes/",
                        "props": "type=tar.gz;status=ready"                        
                    }
                        ]
                    }''',
                    buildName: 'drupal_themes',
                    buildNumber: '${BUILD_NUMBER}'
                )
            }
       }
        stage('Deploy') {
            steps {
                sh """
                  sudo ansible-playbook ansible.yml --extra-vars "deployment_host=$env.INVENTORY_NAME"
                   """
            }
        }
    }
    post {
    aborted {
      emailext attachLog: true,
      mimeType: 'text/html',
      body: '${FILE, path="/var/lib/jenkins/mailtemplate/aborted.html"}',
      compressLog: true,
      recipientProviders: [developers(), requestor()],
      subject: '${DEFAULT_SUBJECT}',
      to: '$DEFAULT_RECIPIENTS'
    }
    failure {
      emailext attachLog: true,
      mimeType: 'text/html',
      body: '${FILE, path="/var/lib/jenkins/mailtemplate/failure.html"}',
      compressLog: true,
      recipientProviders: [developers(), requestor()],
      subject: '${DEFAULT_SUBJECT}',
      to: '$DEFAULT_RECIPIENTS'
    }
    success {
      emailext attachLog: true,
      mimeType: 'text/html',
      body: '${FILE, path="/var/lib/jenkins/mailtemplate/success.html"}',
      compressLog: true,
      recipientProviders: [developers(), requestor()],
      subject: '${DEFAULT_SUBJECT}',
      to: '$DEFAULT_RECIPIENTS'
    }
  }
}