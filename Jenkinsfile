pipeline {
    agent any // Executes natively on your Windows Desktop host
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    
    stages {
        stage('Execute Containerized Tests') {
            steps {
                echo 'Spawning a clean Ubuntu environment and mounting the workspace...'
                
                // 1. We mount the Windows workspace (%WORKSPACE%) into a clean /build directory inside Linux
                // 2. Docker Desktop automatically translates the drive paths seamlessly
                // 3. We explicitly tell it to use bash to run our checkout script
                bat 'docker run --rm -v "%WORKSPACE%":/build -w /build ubuntu:24.04 bash ./ci-test.sh'
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Windows host workspace...'
            cleanWs()
        }
    }
}
