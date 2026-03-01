pipeline {
  agent any

  options {
    timestamps()
    timeout(time: 15, unit: 'MINUTES')
  }

  parameters {
    choice(name: 'SERVICE', choices: ['orders', 'payments', 'users', 'inventory', 'gateway'],
           description: 'Which service MIG to operate')
    choice(name: 'ACTION', choices: ['detach', 'attach'],
           description: 'Detach or attach MIG autohealing health check')
    string(name: 'REGION', defaultValue: 'us-central1', description: 'Region of the regional MIG')
    string(name: 'INITIAL_DELAY', defaultValue: '120', description: 'Initial delay (seconds) when attaching autohealing')
  }

  environment {
    TF_DIR  = "terraform"
    TF_VARS = "envs/dev.tfvars"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Read Terraform outputs') {
      steps {
        dir("${env.TF_DIR}") {
          sh '''
            set -euo pipefail
            terraform init -input=false
            terraform output -json > tf_outputs.json
          '''
        }
      }
    }

    stage('Resolve targets') {
      steps {
        dir("${env.TF_DIR}") {
          script {
            def resolved = sh(
              script: """
                python3 - <<'PY'
import json
svc = "${params.SERVICE}"
with open("tf_outputs.json") as f:
    out = json.load(f)

mig = out["mig_names"]["value"][svc]
hc  = out["mig_autoheal_health_checks"]["value"][svc]
print(mig)
print(hc)
PY
              """,
              returnStdout: true
            ).trim().split("\\r?\\n")

            env.MIG_NAME = resolved[0]
            env.HEALTH_CHECK = resolved[1]

            echo "SERVICE      = ${params.SERVICE}"
            echo "ACTION       = ${params.ACTION}"
            echo "REGION       = ${params.REGION}"
            echo "MIG_NAME     = ${env.MIG_NAME}"
            echo "HEALTH_CHECK = ${env.HEALTH_CHECK}"
          }
        }
      }
    }

    stage('DETACH autohealing') {
      when { expression { params.ACTION == 'detach' } }
      steps {
        sh '''
          set -euo pipefail
          echo "Detaching autohealing from ${MIG_NAME}..."
          gcloud compute instance-groups managed update "${MIG_NAME}" \
            --region "${REGION}" \
            --clear-autohealing
        '''
      }
    }

    stage('ATTACH autohealing') {
      when { expression { params.ACTION == 'attach' } }
      steps {
        sh '''
          set -euo pipefail
          echo "Waiting until MIG is stable before attaching autohealing..."
          gcloud compute instance-groups managed wait-until "${MIG_NAME}" \
            --region "${REGION}" \
            --stable

          echo "Attaching autohealing health check..."
          gcloud compute instance-groups managed update "${MIG_NAME}" \
            --region "${REGION}" \
            --health-check "${HEALTH_CHECK}" \
            --initial-delay "${INITIAL_DELAY}"
        '''
      }
    }

    stage('Verify') {
      steps {
        sh '''
          set -euo pipefail
          echo "Autohealing policies now:"
          gcloud compute instance-groups managed describe "${MIG_NAME}" \
            --region "${REGION}" \
            --format="yaml(autoHealingPolicies)"
        '''
      }
    }
  }
}
