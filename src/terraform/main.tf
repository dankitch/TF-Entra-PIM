data "azuread_user" "pim_group_member" {
  for_each            = toset(flatten([for role in local.roles : role.members]))
  user_principal_name = each.value
}

resource "azuread_directory_role" "pim_role" {
  for_each     = { for role in local.roles : role.role_display_name => role }
  display_name = each.value.role_display_name
}

resource "azuread_group" "pim_group" {
  for_each                = { for role in local.roles : role.role_display_name => role }
  display_name            = "entra_pim_${replace(lower(each.value.role_display_name), " ", "_")}"
  description             = "PIM group for ${each.value.role_display_name}."
  security_enabled        = true
  assignable_to_role      = true
  prevent_duplicate_names = true
  members                 = [for upn in each.value.members : data.azuread_user.pim_group_member[upn].object_id]

}

resource "azuread_directory_role_eligibility_schedule_request" "pim_eligible_role" {
  for_each           = { for role in local.roles : role.role_display_name => role if role.privileged }
  role_definition_id = azuread_directory_role.pim_role[each.key].template_id
  principal_id       = azuread_group.pim_group[each.key].object_id
  directory_scope_id = "/"
  justification      = "Initial Setup Assignments"
}

resource "azuread_directory_role_assignment" "pim_assigned_role" {
  for_each            = { for role in local.roles : role.role_display_name => role if !role.privileged }
  role_id             = azuread_directory_role.pim_role[each.key].object_id
  principal_object_id = azuread_group.pim_group[each.key].object_id
}
