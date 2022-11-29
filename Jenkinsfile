pipeline {
    parameters {
        booleanParam defaultValue: true,
        description: 'Whether to upload the packages in playground repositories',
        name: 'PLAYGROUND'
    }
    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 1, unit: 'HOURS')
    }
    agent {
        node {
            label 'base-agent-v1'
        }
    }
    environment {
        NETWORK_OPTS = '--network ci_agent'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'mkdir staging'
                sh 'cp -r packages staging'
                stash includes: 'staging/**', name: 'staging'
            }
        }
        stage('Build deb/rpm') {
            stages {
                stage('pacur') {
                    parallel {
                        stage('Ubuntu 20.04') {
                            agent {
                                node {
                                    label 'pacur-agent-ubuntu-20.04-v1'
                                }
                            }
                            steps {
                                unstash 'staging'
                                sh 'cp -r staging /tmp'
                                sh 'sudo pacur build ubuntu-focal /tmp/staging/packages'
                                stash includes: 'artifacts/', name: 'artifacts-ubuntu-focal'
                            }
                            post {
                                always {
                                    archiveArtifacts artifacts: 'artifacts/*.deb', fingerprint: true
                                }
                            }
                        }
                        stage('Rocky 8') {
                            agent {
                                node {
                                    label 'pacur-agent-rocky-8-v1'
                                }
                            }
                            steps {
                                unstash 'staging'
                                sh 'cp -r staging /tmp'
                                sh 'sudo pacur build rocky-8 /tmp/staging/packages'
                                stash includes: 'artifacts/', name: 'artifacts-rocky-8'
                            }
                            post {
                                always {
                                    archiveArtifacts artifacts: 'artifacts/*.rpm', fingerprint: true
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Upload To Playground') {
            when {
                expression { params.PLAYGROUND == true }
            }
            steps {
                unstash 'artifacts-ubuntu-focal'
                unstash 'artifacts-rocky-8'

                script {
                    def server = Artifactory.server 'zextras-artifactory'
                    def buildInfo
                    def uploadSpec
                    buildInfo = Artifactory.newBuildInfo()
                    uploadSpec = '''{
                        "files": [
                            {
                                "pattern": "artifacts/*focal*.deb",
                                "target": "ubuntu-playground/pool/",
                                "props": "deb.distribution=focal;deb.component=main;deb.architecture=amd64"
                            },
                            {
                                "pattern": "artifacts/(carbonio-grafana-settings)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-alertmanager)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-blackbox-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-consul-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-mysql-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-nginx-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-node-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-openldap-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-postgres)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-process-exporter)-(*).rpm",
                                "target": "centos8-playground/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            }
                        ]
                    }'''
                    server.upload spec: uploadSpec, buildInfo: buildInfo, failNoOp: false
                }
            }
        }
        stage('Upload & Promotion Config') {
            when {
                anyOf {
                    branch 'release/*'
                    buildingTag()
                }
            }
            steps {
                unstash 'artifacts-ubuntu-focal'
                unstash 'artifacts-rocky-8'

                script {
                    def server = Artifactory.server 'zextras-artifactory'
                    def buildInfo
                    def uploadSpec
                    def config

                    //ubuntu
                    buildInfo = Artifactory.newBuildInfo()
                    buildInfo.name += "-ubuntu"
                    uploadSpec = """{
                        "files": [
                            {
                                "pattern": "artifacts/*focal*.deb",
                                "target": "ubuntu-rc/pool/",
                                "props": "deb.distribution=focal;deb.component=main;deb.architecture=amd64"
                            }
                        ]
                    }"""
                    server.upload spec: uploadSpec, buildInfo: buildInfo, failNoOp: false
                    config = [
                            'buildName'          : buildInfo.name,
                            'buildNumber'        : buildInfo.number,
                            'sourceRepo'         : 'ubuntu-rc',
                            'targetRepo'         : 'ubuntu-release',
                            'comment'            : 'Do not change anything! Just press the button',
                            'status'             : 'Released',
                            'includeDependencies': false,
                            'copy'               : true,
                            'failFast'           : true
                    ]
                    Artifactory.addInteractivePromotion server: server, promotionConfig: config, displayName: "Ubuntu Promotion to Release"
                    server.publishBuildInfo buildInfo


                    //rocky8
                    buildInfo = Artifactory.newBuildInfo()
                    buildInfo.name += "-centos8"
                    uploadSpec= """{
                        "files": [
                            {
                                "pattern": "artifacts/(carbonio-grafana-settings)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-alertmanager)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-blackbox)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-consul)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-mysqld)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-nginx)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-node)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-openldap)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-postgres)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            },
                            {
                                "pattern": "artifacts/(carbonio-prometheus-process)-(*).rpm",
                                "target": "centos8-rc/zextras/{1}/{1}-{2}.rpm",
                                "props": "rpm.metadata.arch=x86_64;rpm.metadata.vendor=zextras"
                            }
                        ]
                    }"""
                    server.upload spec: uploadSpec, buildInfo: buildInfo, failNoOp: false
                    config = [
                            'buildName'          : buildInfo.name,
                            'buildNumber'        : buildInfo.number,
                            'sourceRepo'         : 'centos8-rc',
                            'targetRepo'         : 'centos8-release',
                            'comment'            : 'Do not change anything! Just press the button',
                            'status'             : 'Released',
                            'includeDependencies': false,
                            'copy'               : true,
                            'failFast'           : true
                    ]
                    Artifactory.addInteractivePromotion server: server, promotionConfig: config, displayName: "Centos8 Promotion to Release"
                    server.publishBuildInfo buildInfo
                }
            }
        }
    }
}
