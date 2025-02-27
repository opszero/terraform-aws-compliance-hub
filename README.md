<!-- BEGIN_TF_DOCS -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudtrail_enabled"></a> [cloudtrail\_enabled](#input\_cloudtrail\_enabled) | Enables AWS CloudTrail. Defaults to true. Setting this to false will disable CloudTrail. | `bool` | `true` | no |
| <a name="input_ebs_enabled"></a> [ebs\_enabled](#input\_ebs\_enabled) | Enables Amazon EBS. Defaults to true. Setting this to false will disable EBS. | `bool` | `true` | no |
| <a name="input_guard_duty_enabled"></a> [guard\_duty\_enabled](#input\_guard\_duty\_enabled) | Enables AWS GuardDuty. Defaults to true. Setting this to false will disable GuardDuty. | `bool` | `true` | no |
| <a name="input_logs_enabled"></a> [logs\_enabled](#input\_logs\_enabled) | Enables logging. Defaults to true. Setting this to false will pause logging. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name used for identifying resources. This can be used for naming EBS, GuardDuty, and other services. | `string` | `"secure"` | no |
| <a name="input_product_arns"></a> [product\_arns](#input\_product\_arns) | A list of additional ARNs for the Security Hub products. | `list(string)` | `[]` | no |
| <a name="input_security_hub_enabled"></a> [security\_hub\_enabled](#input\_security\_hub\_enabled) | Enables AWS Security Hub. Defaults to true. Setting this to false will disable Security Hub. | `bool` | `true` | no |
| <a name="input_standards_arns"></a> [standards\_arns](#input\_standards\_arns) | A list of additional ARNs for the Security Hub standards. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to CloudTrail resources. | `map(string)` | `{}` | no |
## Resources

| Name | Type |
|------|------|
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
## Outputs

No outputs.
# 🚀 Built by opsZero!

<a href="https://opszero.com"><img src="https://opszero.com/wp-content/uploads/2024/07/opsZero_logo_svg.svg" width="300px"/></a>

Since 2016 [opsZero](https://opszero.com) has been providing Kubernetes
expertise to companies of all sizes on any Cloud. With a focus on AI and
Compliance we can say we seen it all whether SOC2, HIPAA, PCI-DSS, ITAR,
FedRAMP, CMMC we have you and your customers covered.

We provide support to organizations in the following ways:

- [Modernize or Migrate to Kubernetes](https://opszero.com/solutions/modernization/)
- [Cloud Infrastructure with Kubernetes on AWS, Azure, Google Cloud, or Bare Metal](https://opszero.com/solutions/cloud-infrastructure/)
- [Building AI and Data Pipelines on Kubernetes](https://opszero.com/solutions/ai/)
- [Optimizing Existing Kubernetes Workloads](https://opszero.com/solutions/optimized-workloads/)

We do this with a high-touch support model where you:

- Get access to us on Slack, Microsoft Teams or Email
- Get 24/7 coverage of your infrastructure
- Get an accelerated migration to Kubernetes

Please [schedule a call](https://calendly.com/opszero-llc/discovery) if you need support.

<br/><br/>

<div style="display: block">
  <img src="https://opszero.com/wp-content/uploads/2024/07/aws-advanced.png" width="150px" />
  <img src="https://opszero.com/wp-content/uploads/2024/07/AWS-public-sector.png" width="150px" />
  <img src="https://opszero.com/wp-content/uploads/2024/07/AWS-eks.png" width="150px" />
</div>
<!-- END_TF_DOCS -->