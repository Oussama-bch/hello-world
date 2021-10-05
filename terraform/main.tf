#######################################################
#####      Terraform Provider
#######################################################
provider "aws" {
  region      = "eu-west-3"
  alias       = "eu_west_3"
  shared_credentials_file = "~/.aws/credentials"
}
