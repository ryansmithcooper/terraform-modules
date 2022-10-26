# Terraform README

**GROUPS, RULES, & BOOKMARKS:** These objects are now managed using dynamic (for_each) resource blocks. To add/change these objects, please refer to the locals modules found at the top of each associated .tf file. To add a new resource, simply copy & paste a similar resource and change the necessary parameters. To edit a resource, find the one in question and edit the parameters there. To refer to these objects, use the following convention "okta_group.example_group["key"]". Additionally, using the Terraform CLI, these objects need to be passed inside of ''. For instance, *tf state rm 'okta_group.example_group["key"]'*.  **Remember: do not edit the resource block but the locals instead!!**

Due to the "create_before_destroy" lifecycle rule, you will have to change the name of the rule on each change in rules.tf