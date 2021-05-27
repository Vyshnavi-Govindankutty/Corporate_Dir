provider "aws"{
	region="us-east-2"
}

data "aws_cognito_user_pools" "corp_user_pool"{

name="Corp-dir"
}

resource "aws_cognito_user_pool_client" "client"{
name="okta"
user_pool_id="us-east-2_da85SdwAK"
allowed_oauth_flows= ["implicit"]
allowed_oauth_scopes= ["aws.cognito.signin.user.admin","email","openid"]
supported_identity_providers=["okta"]
allowed_oauth_flows_user_pool_client="true"

callback_urls=["https://d3p2ikv6jmwxlt.cloudfront.net"]

}


