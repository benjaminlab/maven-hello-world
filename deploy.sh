# deploy.sh
#! /bin/bash

SHA1=$1

# Deploy image to Docker Hub
docker push bbach/myrepo1:$SHA1

# Create new Elastic Beanstalk version
EB_BUCKET=testbucketbenjamin
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE

region=eu-central-1

aws configure set aws_access_key_id $AWSKEY
aws configure set aws_secret_access_key $AWSSECRETKEY
aws configure set default.region $region

aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE
aws elasticbeanstalk create-application-version --application-name benjamin-test \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name benjaminTest-env \
    --version-label $SHA1
