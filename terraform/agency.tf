
##########################################################
# Agency for FunctionGraph
# Attention: Creating agency will take some time.
# Calls to function after creating agency will fail until
# agency is set up.
##########################################################
resource "opentelekomcloud_identity_agency_v3" "agency" {
  delegated_domain_name = "op_svc_cff"

  name        = format("%s-%s-agency", var.prefix, var.function_name)
  description = "Agency for FunctionGraph to access SWR"

  project_role {
    all_projects = true
    roles = [
      "SWR Administrator",
      "VPC FullAccess"
    ]
  }

}
