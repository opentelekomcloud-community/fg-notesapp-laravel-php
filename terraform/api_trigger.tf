locals {
  API_GATEWAY_INSTANCE_ID = var.API_GATEWAY_INSTANCE_ID
  ENV_NAME                = "RELEASE"
  ENV_ID                  = "DEFAULT_ENVIRONMENT_RELEASE_ID"
}

##########################################################
# opentelekomcloud_apigw_group_v2.group
##########################################################
resource "opentelekomcloud_apigw_group_v2" "group1" {
  # depends_on = [ opentelekomcloud_fgs_function_v2.MyFunction ]
  name        = replace(format("%s_%s_api_group", var.prefix, var.function_name), "-", "_")
  instance_id = local.API_GATEWAY_INSTANCE_ID
  description = format("API Group for %s, %s", var.prefix, var.function_name)
}

##########################################################
# opentelekomcloud_apigw_api_v2.api1
# This is used to create the API Gateway trigger for the
# FunctionGraph function.
##########################################################
resource "opentelekomcloud_apigw_api_v2" "api1" {

  # TRIGGER-INSTANCE_id
  gateway_id = local.API_GATEWAY_INSTANCE_ID

  # TRIGGER-GROUP_id
  group_id = opentelekomcloud_apigw_group_v2.group1.id

  # TRIGGER-Name
  name = replace(format("%s_%s_apig_trigger", var.prefix, var.function_name), "-", "_")

  # TRIGGER-TYPE:1
  type = "Public"

  # TRIGGER-PROTOCOL: HTTPS
  request_protocol = "HTTPS"

  # TRIGGER-REG_METHOD: HTTPS
  request_method = "ANY"

  # TRIGGER-PATH
  request_uri = "/"

  # TRIGGER-AUTH: NONE
  security_authentication_type = "NONE"

  # TRIGGER-MATCH_MODE: SWA
  match_mode       = "PREFIX"

  success_response = "Success response"
  failure_response = "Failed response"
  description      = format("Created by script for %s-%s", var.prefix, var.function_name)

  func_graph {
    function_urn    = opentelekomcloud_fgs_function_v2.MyFunction.urn
    version         = "latest"
    timeout         = 60000
    invocation_type = "sync"
    network_type    = "NON-VPC"
  }

}

##########################################################
# Publish API to specific environment
##########################################################
resource "opentelekomcloud_apigw_api_publishment_v2" "default" {  
  gateway_id     = local.API_GATEWAY_INSTANCE_ID
  environment_id = local.ENV_ID
  api_id         = opentelekomcloud_apigw_api_v2.api1.id
  version_id     = opentelekomcloud_apigw_api_v2.api1.version

  # force publishing on change of api
  lifecycle {
    replace_triggered_by = [
      opentelekomcloud_apigw_api_v2.api1
    ]
  }

}

output "API_GATEWAY_TRIGGER_URL" {
  description = "The URL of the API Gateway triggering the FunctionGraph function"
  value       = format("https://%s.apic.%s.otc.t-systems.com", 
                opentelekomcloud_apigw_group_v2.group1.id , 
                opentelekomcloud_apigw_group_v2.group1.region)
  
}