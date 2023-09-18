#!/bin/bash






 for dir in */; do
          if [[ -f "${dir}main.tf" ]]; then
            echo "Deploying in directory: $dir"
            cd "$dir"
            terraform init \
              -backend-config="bucket=${BUCKET_NAME}" \
              -backend-config="key=tf-openstack/terraform.tfstate" \
              -backend-config="region=us-east-1"
            terraform plan -out=tfplan
            terraform apply -auto-approve tfplan
            cd ..
          fi
        done





