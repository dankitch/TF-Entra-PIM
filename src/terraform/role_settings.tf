/* For more information on the role settings see: 
   https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy
*/

resource "azuread_group_role_management_policy" "application_administrator" {
  group_id = azuread_group.pim_group["Application Administrator"].object_id
  role_id  = "member"

  eligible_assignment_rules {
    expiration_required = false
  }

  activation_rules {
    require_approval                   = false
    require_justification              = true
    require_multifactor_authentication = true
  }

  notification_rules {
    eligible_activations {
      admin_notifications {
        default_recipients    = false
        notification_level    = "All"
        additional_recipients = ["user1@mydomain.com"]
      }
    }
  }
}

resource "azuread_group_role_management_policy" "helpdesk_administrator" {
  group_id = azuread_group.pim_group["Helpdesk Administrator"].object_id
  role_id  = "member"

  eligible_assignment_rules {
    expiration_required = false
  }

  activation_rules {
    require_approval                   = false
    require_justification              = true
    require_multifactor_authentication = true
  }
}

// add more group role settings as needed

