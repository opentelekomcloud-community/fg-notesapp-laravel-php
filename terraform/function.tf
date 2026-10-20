##########################################################
# Create event function using container image 
##########################################################
resource "opentelekomcloud_fgs_function_v2" "MyFunction" {

  name   = format("%s_%s", var.prefix, var.function_name)
  app    = "default"
  agency = opentelekomcloud_identity_agency_v3.agency.name

  handler   = "-"
  code_type = "Custom-Image-Swr"
  runtime   = "http"

  # initializer_handler = "-"
  # initializer_timeout = 30

  custom_image {
    url = var.image_url
  }

  description      = var.description
  memory_size      = 256
  timeout          = 300
  max_instance_num = 400
  enable_dynamic_memory = "true"

  # if you need security access key, security secret key and security token
  # to access other OTC services, set enable_auth_in_header to true
  enable_auth_in_header = true

  log_group_id   = opentelekomcloud_lts_group_v2.MyLogGroup.id
  log_group_name = opentelekomcloud_lts_group_v2.MyLogGroup.group_name

  log_topic_id   = opentelekomcloud_lts_stream_v2.MyLogStream.id
  log_topic_name = opentelekomcloud_lts_stream_v2.MyLogStream.stream_name

  # set some environment variables
  user_data = jsonencode({    
    "PROJECT_ID" : var.OTC_SDK_PROJECTID,
    "REGION" : split("_", var.OTC_SDK_PROJECTNAME)[0],
    
    "DB_CONNECTION" : "pgsql",
    "DB_HOST": var.DB_HOST,
    "DB_PORT": var.DB_PORT,
    "DB_DATABASE": var.DB_DATABASE,
    "DB_USERNAME": var.DB_USERNAME,
    
    "APP_URL": format("https://%s.apic.%s.otc.t-systems.com/", 
                opentelekomcloud_apigw_group_v2.group1.id , 
                opentelekomcloud_apigw_group_v2.group1.region),
    "RUN_MIGRATIONS": var.RUN_MIGRATIONS,
    "ADMIN_EMAILS": var.ADMIN_EMAILS,

  })

  encrypted_user_data = jsonencode({    
    "DB_PASSWORD": var.DB_PASSWORD,
    "APP_KEY": var.APP_KEY,
  })

  
  tags = {
    "app_group" = var.tag_app_group
  }

  network_controller {
    disable_public_network = true
  }

  vpc_id = var.VPC_ID

  network_id = var.NETWORK_ID

}

output "MY_FUNCTION_URN" {
  value = opentelekomcloud_fgs_function_v2.MyFunction.urn
}

output "MY_FUNCTION_VERSION" {
  value = opentelekomcloud_fgs_function_v2.MyFunction.version
}
