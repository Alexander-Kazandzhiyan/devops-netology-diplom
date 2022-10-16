aws s3 mb s3://diplom-ak-backend-tfstate --region us-east-1
aws s3api put-public-access-block \
    --bucket diplom-ak-backend-tfstate \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
