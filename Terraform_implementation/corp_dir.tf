provider "aws"{
	region=var.aws_region
}





//SECURITY GROUPS
resource "aws_security_group" "corp_dir_sc"{
	description="Define inbound and outbound traffic"
	vpc_id="${data.aws_vpc.default.id}"


	ingress {
	from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0","${data.aws_vpc.default.cidr_block}"]
   

	}

	ingress {
	from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0","${data.aws_vpc.default.cidr_block}"]


	}
	
	ingress {
	from_port        = 8888
    to_port          = 8888
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]


	}

	ingress {
	from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]


	}

	ingress {
	from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["${data.aws_vpc.default.cidr_block}"]


	}



	egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



//CLOUDFRONT DISTRIBUTION
resource "aws_cloudfront_distribution" "corp_cloudfront"{
	enabled=true
	is_ipv6_enabled=true
	
	origin{
	origin_id="Custom-vg-corp-dir.tk"
	domain_name="vg-corp-dir.tk"
	  custom_origin_config{
		http_port=80
		https_port=443
		origin_protocol_policy="http-only"
		origin_ssl_protocols=["TLSv1"]
		}
	
   }

viewer_certificate {
    cloudfront_default_certificate = true
  }

restrictions{
	geo_restriction{
	restriction_type="none"
}
}

default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "Custom-vg-corp-dir.tk"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values{
	query_string=false
	cookies{
		forward="none"
		}
	}

}		


}


//S3 BUCKET
resource "aws_s3_bucket" "corp_bucket"{
	bucket="dir-bucket"
}



//RDS INSTANCE
resource "aws_db_instance" "corp_db"{
	allocated_storage=20
	//db_instance_identifier="corp-db"
	engine="mysql"
	engine_version="8.0.20"
	instance_class="db.t2.micro"
	name=var.rds_name
	username=var.db_username
	password=var.db_password
	vpc_security_group_ids=[aws_security_group.corp_dir_sc.id]
	skip_final_snapshot       = true
	
}




//COMPUTE-INSTANCE-PROFILE
resource "aws_iam_instance_profile" "corp_profile"{
	name="corp_profile"
	role="${data.aws_iam_role.corp_role.name}"
} 


//COMPUTE-INSTANCE-EC2
resource "aws_instance" "corp_dir_instance"{
	instance_type=var.instance_type
	ami=var.ami_id
	vpc_security_group_ids=[aws_security_group.corp_dir_sc.id]
	iam_instance_profile="${aws_iam_instance_profile.corp_profile.name}"
	key_name=var.key
	
	
}



//ROUTE53

resource "aws_route53_zone" "corp_route"{
name="vg-corp-dir.tk"

}

resource "aws_route53_record" "corp_rec_1"{
zone_id=aws_route53_zone.corp_route.zone_id
name="vg-corp-dir.tk"
type="A"
ttl="30"
records=[aws_instance.corp_dir_instance.public_ip]

}




//VPC
data "aws_vpc" "default"{
  default=true
}


//IAM ROLE
data "aws_iam_role" "corp_role"{
	name=var.iam_role
}




output "aws_instance_public"{
description="public ip address-instance"
value =aws_instance.corp_dir_instance.public_ip

}

output "cloudnet"{
description="cloudfront domain"
value=aws_cloudfront_distribution.corp_cloudfront.domain_name
}


output "rds_instance"{
sensitive=true
value=var.db_password
description="reds_password"
}


