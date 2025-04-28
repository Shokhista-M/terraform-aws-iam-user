variable "groups" {
    type = map (list(string))
    description = "A map a IAM groups with their associated user lists"
    default = {
        "system_admins" = ["system_admin_1", "system_admin_2", "system_admin_3"]
        "database_admins" = ["database_admin_1", "database_admin_2", "database_admin_3"]
        "read_only" = ["read_only_1", "read_only_2", "read_only_3"]
    }
}
variable "minimum_password_lenght" {
    type = number
    description = "Minimum password length"
    default = 8
}
variable "require_lowercase_characters" {
    type = bool
    description = "Require lowercase characters"
    default = true
}
variable "require_numbers" {
    type = bool
    description = "Require numbers"
    default = true
}
variable "require_uppercase_characters" {
    type = bool
    description = "Require uppercase characters"
    default = true
}
variable "require_symbols" {
    type = bool
    description = "Require symbols"
    default = true
}
variable "allow_users_to_change_password" {
    type = bool
    description = "Allow users to change password"
    default = true
}
variable "hard_expiry" {
    type = bool
    description = "Hard expiry"
    default = false

}
variable "max_password_age" {
    type = number
    description = "Max password age"
    default = 120
}
variable "password_reuse_prevention" {
    type = number
    description = "Password reuse prevention"
}
locals {
    users = distinct(flatten([for group_users in var.groups : group_users]))
}
resource "aws_iam_user" "default" {
    for_each = toset(local.users)
    name = each.value
}
resource "aws_iam_account_password_policy" "strict_policy" {
    minimum_password_length       = var.minimum_password_lenght #8
    require_lowercase_characters  = var.require_lowercase_characters #true
    require_numbers               = var.require_numbers #true
    require_uppercase_characters  = var.require_uppercase_characters #true
    require_symbols               = var.require_symbols #true
    allow_users_to_change_password = var.allow_users_to_change_password #true
    hard_expiry                    = var.hard_expiry #false
    max_password_age               = var.max_password_age #120
    password_reuse_prevention      = var.password_reuse_prevention #3
}
resource "aws_iam_group" "default" {
    for_each = toset(keys(var.groups))
    name = each.value
}
resource "aws_iam_group_membership" "default" {
    for_each = { for group, users in var.groups : group => users}
    name = each.key
    users = each.value
    group = aws_iam_group.default[each.key].name
}
resource "aws_iam_group_policy_attachment" "sysadmin_full_access" {
    group = aws_iam_group.default["system_admins"].name
    policy_arn = "arn:aws:iam:aws:policy/AdminstratorAccess"
}
resource "aws_iam_group_policy_attachment" "dbadmin_full_access" {
    group = aws_iam_group.default["database_admins"].name
    policy_arn = "arn:aws:iam:aws:policy/job-function/DatabaseAdminstrator"
}
resource "aws_iam_group_policy_attachment" "read_only" {
    group = aws_iam_group.default["read_only"].name
    policy_arn = "arn:aws:iam:aws:policy/AmazonMonitronFullAccess"
}