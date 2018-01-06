# Configure AWS Credentials & Region
provider "aws" {
  region  = "us-east-1"
}

resource "aws_iam_instance_profile" "beanstalk_service" {
    name = "beanstalk-service-user"
    roles = ["${aws_iam_role.beanstalk_service.name}"]
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
    name = "beanstalk-ec2-user"
    roles = ["${aws_iam_role.beanstalk_ec2.name}"]
}

resource "aws_iam_role" "beanstalk_service" {
    name = "beanstalk-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
    name = "beanstalk-ec2-role"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
    name = "elastic-beanstalk-service"
    roles = ["${aws_iam_role.beanstalk_service.id}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk_service_health" {
    name = "elastic-beanstalk-service-health"
    roles = ["${aws_iam_role.beanstalk_service.id}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_worker" {
    name = "elastic-beanstalk-ec2-worker"
    roles = ["${aws_iam_role.beanstalk_ec2.id}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
    name = "elastic-beanstalk-ec2-web"
    roles = ["${aws_iam_role.beanstalk_ec2.id}"]
    policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_elastic_beanstalk_application" "api" {
    name = "api"
    description = "REST api"
}

resource "aws_elastic_beanstalk_environment" "apienv" {
  name                = "apienv"
  application         = "api"
  solution_stack_name = "64bit Amazon Linux 2016.03 v2.1.6 running PHP 5.5"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCID"
    value     = "vpc-7420b012"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "subnet-09d09452"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "ebs"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "sg-f98d1885"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_instance_profile.beanstalk_service.name}"
  }
}
