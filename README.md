# AWS Elastic Beanstalk + Terraform provisioning Setup

Purpose of this repo is to document and simplify deployment & setup process of applications on AWS Elastic Beanstalk.


Amazon linux EC2 instance with IAM role is used for security.

### Deployment steps

For example:
```
sh deploy.sh api staging us-east-1 f0478bd7c2f584b41a49405c91a439ce9d944657
```


For deletion:
```
./terraform destroy

#Wait for 5 mins


sh clean.sh 
```