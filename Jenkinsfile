library(
    identifier: 'jenkins-lib-common@v4.1.4',
    retriever: modernSCM([
        $class: 'GitSCMSource',
        credentialsId: 'jenkins-integration-with-github-account',
        remote: 'git@github.com:zextras/jenkins-lib-common.git',
    ])
)

properties(defaultPipelineProperties())

pipeline {
    agent {
        node {
            label 'base'
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        parallelsAlwaysFailFast()
        skipDefaultCheckout()
        timeout(time: 1, unit: 'HOURS')
    }

    stages {
        stage('Setup') {
            steps {
                checkout scm
                gitMetadata()
            }
        }

        stage('Security Scan') {
            steps {
                gitleaksStage()
            }
        }

        stage('Build') {
            steps {
                echo 'Building deb/rpm packages'
                buildStage([
                    buildFlags: '-ds',
                    prepare: true,
                    prepareFlags: '-g',
                ])
                buildStage([
                    buildFlags: '-ds',
                    architecture: 'aarch64',
                    distros: ['ubuntu-jammy'],
                    parallel: false,
                    prepare: true,
                    prepareFlags: '-g',
                ])
            }
        }

        stage('Upload artifacts')
        {
            tools {
                jfrog 'jfrog-cli'
            }
            steps {
                uploadStage(
                    exclusionMap: [
                        'carbonio-prometheus': ['.*alertmanager.*\\.rpm', '.*exporter.*\\.rpm']
                    ]
                )
                uploadStage(
                    architecture: 'aarch64',
                    distros: ['ubuntu-jammy'],
                    exclusionMap: [
                        'carbonio-prometheus': ['.*alertmanager.*\\.rpm', '.*exporter.*\\.rpm']
                    ]
                )
            }
        }
    }

    post {
        always {
            emailext([
                attachLog: true,
                body: '$DEFAULT_CONTENT',
                recipientProviders: [requestor()],
                subject: '$DEFAULT_SUBJECT',
                to: env.GIT_COMMIT_EMAIL
            ])
        }
    }
}
