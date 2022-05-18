resource "aws_iam_role" "cluster" {
  name = "${var.env}-eks-cluster"

  assume_role_policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "node" {
  name = "${var.env}-eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

//////////////////////////////////////////////////////////////////////////
///////////////// ALB
//////////////////////////////////////////////////////////////////////////

resource "aws_iam_role" "eks-alb-ingress-controller" {
  name = "${var.env}-eks-alb-ingress-controller"
  assume_role_policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.cluster_trust_oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.cluster_trust_oidc_provider}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
POLICY

}

resource "aws_iam_policy" "alb-ingress-policy" {
  name   = "${var.env}-alb-ingress-policy"
  policy = file("${path.module}/files/alb-ingress-policy.json")
}

resource "aws_iam_role_policy_attachment" "alb-ingress-attachment" {
  role       = aws_iam_role.eks-alb-ingress-controller.id
  policy_arn = aws_iam_policy.alb-ingress-policy.arn
}

//////////////////////////////////////////////////////////////////////////
///////////////// External DNS
//////////////////////////////////////////////////////////////////////////

resource "aws_iam_role" "external-dns" {
  name = "${var.env}-external-dns"

  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.cluster_trust_oidc_provider}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringLike": {
            "${local.cluster_trust_oidc_provider}:sub": "system:serviceaccount:dns:*"
          }
        }
      }
    ]
  }
  POLICY
}

resource "aws_iam_policy" "external-dns-policy" {
  name = "${var.env}-external-dns-policy"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "external-dns-policy" {
  role       = aws_iam_role.external-dns.id
  policy_arn = aws_iam_policy.external-dns-policy.arn
}

//////////////////////////////////////////////////////////////////////////
///////////////// Health To Go
//////////////////////////////////////////////////////////////////////////

resource "aws_iam_role" "healthtogo_app" {
  name = "${var.env}-healthtogo-app"
  assume_role_policy = <<-POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${local.aws_account_id}:oidc-provider/${local.cluster_trust_oidc_provider}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringLike": {
            "${local.cluster_trust_oidc_provider}:sub":
              [
                "system:serviceaccount:healthtogo:*"
              ]
          }
        }
      }
    ]
  }
  POLICY
}

resource "aws_iam_policy" "healthtogo-app-ses-policy" {
  name = "${var.env}-healthtogo-app-ses-policy"
  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ses:SendEmail"
              ],
              "Resource": "arn:aws:ses:us-east-1:470778815705:identity/healthtogo.com.br"
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "healthtogo_app" {
  role = aws_iam_role.healthtogo_app.id
  policy_arn = aws_iam_policy.healthtogo-app-ses-policy.arn
}
