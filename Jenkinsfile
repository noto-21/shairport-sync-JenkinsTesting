pipeline {
    agent {
        docker {
            // Pulls a Linux container environment onto your Windows machine
            image 'ubuntu:24.04'
            // Avoids strict Linux UID/GID mapping conflicts on Windows filesystems
            args '-u root'
        }
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    
    stages {
        stage('Install System Dependencies') {
            steps {
                echo 'Installing Linux compilation tools inside the container...'
                sh '''
                    apt-get update && apt-get install -y \
                        build-essential \
                        autoconf \
                        automake \
                        libtool \
                        pkg-config \
                        libasound2-dev \
                        libpopt-dev \
                        libconfig-dev \
                        libssl-dev \
                        libavahi-client-dev \
                        libsoxr-dev \
                        libplist-dev \
                        libsodium-dev \
                        libgcrypt20-dev
                '''
            }
        }

        stage('Bootstrap & Configure') {
            steps {
                echo 'Generating Linux Makefiles via Autotools...'
                sh '''
                    autoreconf -fi
                    ./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr
                '''
            }
        }

        stage('Compile') {
            steps {
                echo 'Compiling shairport binaries...'
                sh 'make -j$(nproc)'
            }
        }

        stage('Execute Native Tests') {
            steps {
                echo 'Triggering internal repository tests...'
                sh 'make check'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline successfully orchestrated the native test suite!'
        }
        failure {
            echo 'Pipeline failed. Review the compilation or test logs above.'
        }
    }
}
