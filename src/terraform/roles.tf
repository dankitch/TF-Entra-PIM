/* 
Add or remove roles as required. 
Add additional roles by using the Display Name of the role. A list of Entra roles can be found here:
https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference

 Define the role settings for each role in role_settings.tf
 */

locals {
  roles = [
    {
      role_display_name = "Application Administrator"
      privileged        = true
      members = [
        //"user1@mydomain.com",
        //"user2@mydomain.com"
      ]
    },
    {
      role_display_name = "Attack Simulation Administrator"
      privileged        = false
      members = [
        //"user3@mydomain.com"
      ]
    },
    {
      role_display_name = "Helpdesk Administrator"
      privileged        = true
      members = [
        //"user4@mydomain.com"
      ]
    },

    {
      role_display_name = "Application Developer"
      privileged        = true
      members = [
        //"user5@mydomain.com"
      ]
    }
  ]
}
