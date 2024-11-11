
# IAM Role for App Runner service
resource "aws_iam_role" "app_runner_role" {
  name = "app-runner-ecr-access"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "build.apprunner.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
})
}


resource "aws_iam_role_policy_attachment" "apprunner_service_policy" {
  role       = aws_iam_role.app_runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
  
}




# App Runner Service
resource "aws_apprunner_service" "flask_app_service" {
  service_name = "flask-app-runner"

  source_configuration {

    auto_deployments_enabled = false

    authentication_configuration {
      connection_arn = aws_ssm_parameter.connection_arn.value
    }

    image_repository {
      image_configuration {
      port = "80"  # Port where Flask app is listening
      }
      image_identifier      = var.imageUrl
      image_repository_type = "ECR"
    }
  }
    

  health_check_configuration {
    protocol = "TCP"
    interval = 10
    timeout  = 5
    healthy_threshold = 1
    unhealthy_threshold = 2
  }

  instance_configuration {
    cpu    = "1024"  # 1 vCPU
    memory = "2048"  # 2 GB RAM
  }

}

output "service_url" {
  description = "URL to access the Flask app in App Runner"
  value       = aws_apprunner_service.flask_app_service.service_url
}





//when you call a module in Terraform, everything listed other than 
//the source are variables for that module "left side var name". These variables are essentially 
//arguments values that you're passing into the module.
//you need to define these vars in the module's vars.tf file.

# provider "aws" {
#   region = "us-east-1"
# }

# module "network" {
#   source             = "./modules/network"
#   vpc_cidr           = var.vpc_cidr
#   availability_zones = var.availability_zones
#   serviceName        = var.serviceName
#   region             = var.region
# }

# module "iam" {
#   source       = "./modules/iam"
#   cluster_name = var.cluster_name
#   serviceName = var.serviceName
#   region = var.region
#   vpc_cidr = var.vpc_cidr
#   regionShortName = var.regionShortName
#   availability_zones = var.availability_zones
# }


# module "eks" {
#   source       = "./modules/eks"
#   cluster_name = var.cluster_name
#   eks_role_arn     = module.iam.eks_role_arn  # Pass the role_arn from IAM module
#   node_role_arn    = module.iam.node_role_arn # Pass the role_arn from IAM module
#   public_subnet_ids   = module.network.public_subnet_ids  # Pass the subnet_ids from the network module
#   private_subnet_ids  = module.network.private_subnet_ids # Pass the subnet_ids from the network module
#   vpc_id              = module.network.vpc_id             # Pass the vpc_id from the network module
#   vpc_cidr      = var.vpc_cidr     # Pass the vpc_cidr_block from the network module
#   serviceName = var.serviceName
#   region = var.region

# }







