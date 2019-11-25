#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

#IAM Role
resource "aws_iam_role" "cluster-role" {
  name = "cluster-iam-role"

  assume_role_policy = <<POLICY
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

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster-role.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster-role.name}"
}

#Security Group
resource "aws_security_group" "cluster-sg" {
  name        = "clusterSG"
  description = "Cluster communication with worker nodes"
  vpc_id      = "vpc-0db18af1534983557"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg-test"
  }
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster-sg.id}"
  source_security_group_id = "${aws_security_group.worker-node-sg.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.cluster-sg.id}"
  to_port           = 443
  type              = "ingress"
}

#EKS Service
resource "aws_eks_cluster" "eks-cluster" {
  name     = "eksclustertest"
  role_arn = "${aws_iam_role.cluster-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster-sg.id}"]
    subnet_ids         = ["subnet-0ee44c4bea2dbb0d6", "subnet-017bde34c2265144d", "subnet-09158d63ef844c783","subnet-094ecae332c3eee46", "subnet-0b4aab7f34b911066", "subnet-0483d21a4dba06d1e"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy",
  ]
}
