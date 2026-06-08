pipeline {
    agent any 
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    
    stages {
        stage('Execute Containerized Tests') {
            steps {
                echo 'Spawning a clean Ubuntu environment, sanitizing line endings, and running tests...'
                
                // The 'sed' command cleans up any accidental Windows \r characters before running bash
                bat 'docker run --rm -v "%WORKSPACE%":/build -w /build ubuntu:24.04 bash -c "sed -i \"s/\\r//g\" ci-test.sh && bash ci-test.sh"'
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
