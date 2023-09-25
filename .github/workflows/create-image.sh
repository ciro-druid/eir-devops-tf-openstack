name: Create image Centos79 - EIR

on:
  workflow_dispatch:

  push:



jobs:
  deploy:
    runs-on: ubuntu-20.04

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Install AWS CLI
        run: |
          sudo apt-get update
          sudo apt-get install -y awscli

      - name: Deploy to EC2
        run: |
          aws sts get-caller-identity
          aws ssm start-session --target i-0223ed54de2f64fd6 --region us-east-1 --document-name AWS-StartInteractiveCommand --parameters command="sudo su - ubuntu -c /eir_images/L2/make-image.sh EIR-BE "
        env:
          AWS_EC2_METADATA_DISABLED: true
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
