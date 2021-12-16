provider "aws" {
    region = var.REGION
  
}

#  This is a template for a backend 
# please make sure you provide the values

terraform {
  backend "s3" {
      bucket = " " # provide the name of a bucket that exist for the state file
      key = "dev/terraform.state" # a folder called dev will be created and the state file place in it
      region = " " # the region where the bucket is located 
      # Use DynamoDB for state locking 
      dynamodb_table = " " # name of the dynamodb table to use please make the partition key is set to LockID 
  }
}