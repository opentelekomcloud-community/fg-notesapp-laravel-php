##########################################################
# RDS security group: allow the FunctionGraph function to
# reach PostgreSQL.
# FunctionGraph functions get ephemeral IPs from the subnet
# pool and are NOT members of the RDS security group, so an
# explicit inbound rule for the subnet CIDR is required
# (without it the function gets "port 5432 failed: timeout expired").
##########################################################

# Find the RDS instance (and its security group) in the function's VPC.
# Errors if more than one PostgreSQL instance matches - add a name filter then.
data "opentelekomcloud_rds_instance_v3" "rds" {
  vpc_id         = var.VPC_ID
  datastore_type = "PostgreSQL"
}

# Function subnet CIDR (source of the inbound rule)
data "opentelekomcloud_vpc_subnet_v1" "fn" {
  id = var.NETWORK_ID
}

# The RDS list API cannot filter by host, so the private FQDN of the instance
# found above is verified against DB_HOST (catches a wrong instance or a typo
# in DB_HOST). This terraform build has no check framework (no
# precondition/postcondition blocks, no error() function), so the guard
# substitutes a sentinel security-group id on a mismatch: the plan shows it
# in the diff, and the apply fails on the create step (see
# create_before_destroy), leaving the existing rule untouched.
locals {
  rds_host_matches = data.opentelekomcloud_rds_instance_v3.rds.private_fqdn == var.DB_HOST
  rds_sg_id        = local.rds_host_matches ? data.opentelekomcloud_rds_instance_v3.rds.security_group_id : "DB_HOST-MISMATCH: RDS FQDN ${data.opentelekomcloud_rds_instance_v3.rds.private_fqdn} != DB_HOST ${var.DB_HOST}"
}

resource "opentelekomcloud_vpc_secgroup_rule_v3" "rds_ingress_rule" {
  security_group_id = local.rds_sg_id
  direction         = "ingress"
  ether_type        = "IPv4"
  protocol          = "tcp"
  multi_port        = var.DB_PORT
  remote_ip_prefix  = data.opentelekomcloud_vpc_subnet_v1.fn.cidr
  action            = "allow"
  priority          = 1
  # matches the rule originally created in the console (adopted via terraform import)
  description = "PG"

  # on a DB_HOST mismatch the (sentinel) rule is created first and the API
  # rejects it, so the existing rule is never deleted
  lifecycle {
    create_before_destroy = true
  }
}

# Shown in every plan: true when the found instance is the one DB_HOST points at.
output "RDS_HOST_MATCH" {
  value = local.rds_host_matches
}
