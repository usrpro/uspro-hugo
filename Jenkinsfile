node {
    def srvc
    def GITHUB_PROJECT
    stage("Clone repository") {
        checkout scm
    }
    stage("Build image") {
        GITHUB_PROJECT = "ms-hugo"
        echo "Starting build for branch ${env.BRANCH_NAME} of project ${GITHUB_PROJECT}"
        sh 'docker build -t img .'
    }
    stage("Push image") {
        if (env.BRANCH_NAME == "master") {
            sh "docker login -u $DL_U -p $DL_P ${DR}"
            sh "docker tag img ${DR}/${GITHUB_PROJECT}:${env.BRANCH_NAME}"
            sh "docker push ${DR}/${GITHUB_PROJECT}:${env.BRANCH_NAME}"
            echo "Branch ${env.BRANCH_NAME} pushed to registry, image: ${DR}/${GITHUB_PROJECT}:${env.BRANCH_NAME}"
        } else {
            echo "Branch ${env.BRANCH_NAME} built."
        }

    }
}