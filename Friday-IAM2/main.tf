# the goal was to create an Instance, create a role that has s3 read and write (Get and Put) permissions to an existing bucket
# add permission to the dynamoDB table we created if it exist.

resource "aws_instance" "foo" {
  ami           = var.ami  #ami is found in the variable.tf file You must provide an ami from the region you are running this code
  instance_type = var.intance_type #instance_type is found in the variable.tf file
  iam_instance_profile = aws_iam_instance_profile.test_profile.id # This is the instance profile we created below 

}

# This role will grant s3 and DynamoDB access based on the permission we have in 
# data "aws_iam_policy_document" "source"
resource "aws_iam_role" "S3_Dynamo_role" {
  name               = "S3_Dynamo_role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  inline_policy {
    policy = data.aws_iam_policy_document.source.json

  }
 
}

# Here, We need to tell which service/account this role will be used
data "aws_iam_policy_document" "instance-assume-role-policy" {
   statement {
    actions = ["sts:AssumeRole"]  # This is going to be an assumed role

    principals {
      type        = "Service"  # A service will be using this role. If it was an account, use "AWS"
      identifiers = ["ec2.amazonaws.com"] # Here is the name of the service that is assuming this role. If this 
                                          # was an account, put the account arn here.
    }
  }
}




# This is the instance profile that we will use to attach the role to 
# the instace.
# Here we give the profile a name and specify what role to use.
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.S3_Dynamo_role.name
  
}


# These are the policies, stating what service this role can access.
# Here we are granting access to s3 and DynamoDB.
# Add a statement block for every service you need access too.
data "aws_iam_policy_document" "source" {
    # This is the statement block for s3
  statement {
      sid = "s3 get and put"
      effect = "Allow"
      actions = [ 
          "s3:Get*",
          "s3:put*",
          "s3:List*"
       ]
       resources = ["arn:aws:s3:::terry-infra-testing222/*"]
  }

# This is the statement block for DynamoDB
  statement {
    sid = "Dynamo access"
    effect = "Allow"
    actions   = [
        "dynamodb:CreateBackup",
        "dynamodb:CreateTable",
        "dynamodb:DeleteBackup",
        "dynamodb:DeleteItem",
        "dynamodb:DeleteTable"
    ]
    resources = ["arn:aws:dynamodb:us-east-1:262139658630:table/mystate"]
  }
}
