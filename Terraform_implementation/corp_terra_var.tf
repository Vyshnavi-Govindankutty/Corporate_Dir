variable "aws_region"{
	type=string
	default="us-east-2"
}

variable "ami_id"{
	type=string
}

variable "instance_type"{
	type=string	
}

variable "aws_instance_name"{
	type=string	
}

variable "cognito_user_pool_name"{
	type=string
}

variable "iam_role"{
	type=string
	
}


variable "rds_name"{
	type=string
} 

variable "db_username"{
	type=string
	sensitive=true
}

variable "db_password"{
	type=string
	sensitive=true
}

variable key{
	type=string
}

variable app_client_name{
	type=string
} 


