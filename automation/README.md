# automation

Creates an Azure Automation instance, and optionally enables Change Tracking, Log Collection, Update Management; and update schedules for Definition updates and monthly patches.

## Usage

I recommend reusing the Azure Security Center workspace, because that means servers will be automatically onboarded to ASC, Defender, and Azure Automation, all with the same (Azure-managed) MMA config.

```terraform
module "automation" {
  source          = "github.com/jlaundry/terraform-azure-library/automation"

  env                 = "Test"
  location            = "Australia East"
  resource_group_name = var.azure_security_center_workspace_resource_group_name

  enable_change_tracking = true
  enable_logs_collection = true
  enable_update_management = true

  log_analytics_workspace_name      = var.azure_security_center_workspace_id
  log_analytics_resource_group_name = var.azure_security_center_workspace_resource_group_name

  update_scope = "/subscriptions/506d2d7a-b6e2-4af4-97b0-06698a67bc10"

  tags = var.tags
}
```

If you're not going to reuse the Azure Security Center workspace, you'll need to create one, and ideally reuse the instance ID:

```terraform
module "automation-log" {
  source              = "github.com/jlaundry/terraform-azure-library/log-analytics"

  env                 = "Test"
  location            = "Australia East"

  tags = var.tags
}

module "automation" {
  source          = "github.com/jlaundry/terraform-azure-library/automation"

  env                 = "Test"
  instance_id         = module.automation-log.instance_id
  location            = "Australia East"
  resource_group_name = module.automation-log.resource_group_name

  enable_change_tracking = true
  enable_logs_collection = true
  enable_update_management = true

  log_analytics_workspace_name      = module.automation-log.name
  log_analytics_resource_group_name = module.automation-log.resource_group_name

  update_scope = "/subscriptions/506d2d7a-b6e2-4af4-97b0-06698a67bc10"

  tags = var.tags
}
```

Monthly update schedules are key'd on their scope (so that you can split out test/prod environments), like so:

```terraform

  update_schedule = [
    {
      scope      = "/subscriptions/506d2d7a-b6e2-4af4-97b0-06698a67bc10"
      start_time = "18:00:00"
      week_days  = ["Friday", "Saturday"]
    }
  ]

```
