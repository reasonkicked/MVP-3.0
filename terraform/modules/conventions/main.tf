locals {
  settings = yamldecode(file("${path.module}/settings.yml"))

  location_code = var.location == null ? null : local.settings.locations[lower(var.location)]

  resource_settings = {
    for type, resource in local.settings.resources : type => merge(local.settings.defaults, resource)
  }

  generated_names = {
    for function in setunion(var.functions, [""]) : function => {
      for type, settings in local.resource_settings :
      type => join(settings.separator, compact(flatten([settings.prefix, var.environment, settings.application_name ? var.application_name : "", var.application_instance, function, local.location_code, format("%02d", var.resource_instance)])))
    }
  }

  sanitized_names = {
    for input_name, resources in local.generated_names : input_name => {
      for type, generated_name in resources :
      type => replace(
        substr(
          replace(
            replace(
              replace(
                local.resource_settings[type].lower ? lower(generated_name) : generated_name,
                "_",
                "-"
              ),
              "/${local.resource_settings[type].regex}/",
              ""
            ),
            "/-{2,}/",
            "-"
          ),
          0,
          local.resource_settings[type].max_length
        ),
        "/-+$/",
        ""
      )
    }
  }

  prefixed_names = {
    for input_name, resources in local.sanitized_names : input_name => merge(resources, { for type, name in resources : "azurerm_${type}" => name })
  }
}