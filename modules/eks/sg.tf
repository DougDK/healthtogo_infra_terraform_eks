# resource "aws_security_group" "cluster" {
#   name        = "${var.env}-eks-cluster"
#   description = "Cluster communication with worker nodes"
#   vpc_id      = var.vpc_id

#   ingress {
#     cidr_blocks       = var.ingress_cidr_blocks
#     from_port         = 443
#     protocol          = "tcp"
#     to_port           = 443
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name                     = "${var.env}-eks-cluster"
#     env                      = "${var.env}"
#     "kubernetes.io/cluster"  = "${var.cluster_prefix}-${var.env}"
#   }
# }
