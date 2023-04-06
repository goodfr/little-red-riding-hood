

# User                                            #
###################################################

# Kubernetes User
resource "aws_iam_user" "admins" {
  count = var.admin_count
  name = "admin${count.index}-${local.env}"

  tags = local.tags 
}
# Generate credential for vault user
resource "aws_iam_access_key" "admins" {
  count = var.admin_count
  user = aws_iam_user.admins[count.index].name
}

# User inline policy mapping
resource "aws_iam_user_policy" "admin_kube" {
  count = var.admin_count

  name =  "admin-${local.env}-kube"
  user   = aws_iam_user.admins[count.index].name
  policy = data.aws_iam_policy_document.admin_kube.json
}

# Kubernetes User
resource "aws_iam_user" "groups" {
  count = var.group_count
  name = "group${count.index}-${local.env}"

  tags = local.tags 
}

# Generate credential for vault user
resource "aws_iam_access_key" "groups" {
  count = var.group_count
  user = aws_iam_user.groups[count.index].name
}

# User inline policy mapping
resource "aws_iam_user_policy" "groups_kube" {
  count = var.group_count

  name =  "groups-${local.env}-kube"
  user   = aws_iam_user.groups[count.index].name
  policy = data.aws_iam_policy_document.groups_kube.json
}