module "cluster" {
  source = "./modules/eks"
  env = local.env
  eks_version = "1.21"
  vpc_cidr_block = "10.0.0.0/16"
  subnet_cidr_block = ["10.0.0.0/24", "10.0.1.0/24"]
}
