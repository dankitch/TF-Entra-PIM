# Entra PIM Groups: Role-based Access Control With Terraform

This Terraform project is used to provision Privileged Identity Management (PIM) groups. 
It dynamically creates the groups and assigns the respective Entra role and its members to the group based on the configuration defined in the `locals` block in `roles.tf`.

## Assumptions
This project assumes the following:
- `Privileged` roles are always marked as `eligible` for assignment.
- `Non-privileged` roles always have an `active` assignment. 
- The service principal running terraform will be the `owner` of the PIM groups and as a result, group membership will be controlled via Terraform.

## Prerequisites

When authenticated with a service principal, this resource requires the following application roles: 
- `RoleManagement.ReadWrite.Directory` or `Directory.ReadWrite.All`
- `RoleEligibilitySchedule.ReadWrite.Directory`
- `RoleManagementPolicy.ReadWrite.AzureADGroup`

### ⚠️ User Principal Authentication
There is currently an outstanding issue when authenticating with a `user principal`. Issue [#1407](https://github.com/hashicorp/terraform-provider-azuread/issues/1407)


```
╷
│ Error: Could not parse policy assignment ID, Could not list existing policy assignments, RoleManagementPolicyAssignmentClient.BaseClient.Get(): unexpected status 403 with OData error: UnknownError: {"errorCode":"PermissionScopeNotGranted","message":"Authorization failed due to missing permission scope RoleManagementPolicy.Read.AzureADGroup,RoleManagementPolicy.ReadWrite.AzureADGroup.","instanceAnnotations":[]}
│
│   with azuread_group_role_management_policy.example,
│   on main.tf line 2, in resource "azuread_group_role_management_policy" "example":
│    2: resource "azuread_group_role_management_policy" "example" {
│
│ Could not parse policy assignment ID, Could not list existing policy assignments,
│ RoleManagementPolicyAssignmentClient.BaseClient.Get(): unexpected status 403 with OData error: UnknownError:
│ {"errorCode":"PermissionScopeNotGranted","message":"Authorization failed due to missing permission scope
│ RoleManagementPolicy.Read.AzureADGroup,RoleManagementPolicy.ReadWrite.AzureADGroup.","instanceAnnotations":[]}
╵
```

## Project Structure

- `roles.tf`: Used to define the Entra roles and the members that should be added to the respective PIM group. 

- `main.tf`: Main Terraform configuration file. Used to declare the following resources:
   - azuread_group
   - azuread_directory_role
   - azuread_directory_role_eligibility_schedule_request
   - azuread_directory_role_assignment

   _A data source is used (`azuread_user`) to retrieve information about the members specified in_ `roles.tf`. This is required for populating the `members` attribute in `azuread_group`. 

- `role_settings.tf`: Used to define the specifc role settings for the Entra roles. For more information see, https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy


### roles.tf example:

Define the Entra roles and respective members in the `locals` block:

```
locals {
  roles = [
    {
      role_display_name = "Application Administrator"
      privileged        = true
      members = [
        "user1@mydomain.com",
        "user2@mydomain.com"
      ]
    },
    {
      role_display_name = "Application Developer"
      privileged        = true
      members = [
        "user3@mydomain.com"
      ]
    },
    // Add more roles as needed
  ]
}
```
When adding new roles, set `privileged = true` for roles classified as `PRIVILEGED`; otherwise, set it to `false`. 
A list of roles can be found [here](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference).

### role_settings.tf example:

```
resource "azuread_group_role_management_policy" "application_administrator" {
  group_id = azuread_group.group["Application Administrator"].object_id
  role_id  = "member"

  eligible_assignment_rules {
    expiration_required = false
  }

  activation_rules {
    require_justification              = true
    require_multifactor_authentication = true
  }
}

// add more role settings as needed
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~>3.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.0.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_directory_role.role](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role) | resource |
| [azuread_directory_role_assignment.group_role_assignment](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_group.group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_role_management_policy.application_administrator](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_role_management_policy) | resource |
| [azuread_user.group_member](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |

## Inputs

No inputs.

## Outputs

No outputs.