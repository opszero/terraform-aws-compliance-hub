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
| <a name="input_enable_kubernetes_protection"></a> [enable\_kubernetes\_protection](#input\_enable\_kubernetes\_protection) | Configure and enable Kubernetes audit logs as a data source for Kubernetes protection. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_enable_malware_protection"></a> [enable\_malware\_protection](#input\_enable\_malware\_protection) | Configure and enable Malware Protection as data source for EC2 instances with findings for the detector. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_enable_s3_protection"></a> [enable\_s3\_protection](#input\_enable\_s3\_protection) | Configure and enable S3 protection. Defaults to `true`. | `bool` | `true` | no |
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

<a href="https://opszero.com"><img src="https://opszero.com/img/common/opsZero-Logo-Large.webp" width="300px"/></a>

[opsZero](https://opszero.com) provides software and consulting for Cloud + AI. With our decade plus of experience scaling some of the world’s most innovative companies we have developed deep expertise in Kubernetes, DevOps, FinOps, and Compliance.

Our software and consulting solutions enable organizations to:

- migrate workloads to the Cloud
- setup compliance frameworks including SOC2, HIPAA, PCI-DSS, ITAR, FedRamp, CMMC, and more.
- FinOps solutions to reduce the cost of running Cloud workloads
- Kubernetes optimized for web scale and AI workloads
- finding underutilized Cloud resources
- setting up custom AI training and delivery
- building data integrations and scrapers
- modernizing onto modern ARM based processors

We do this with a high-touch support model where you:

- Get access to us on Slack, Microsoft Teams or Email
- Get 24/7 coverage of your infrastructure
- Get an accelerated migration to Kubernetes

Please [schedule a call](https://calendly.com/opszero-llc/discovery) if you need support.

<br/><br/>

<div style="display: block">
  <img src="https://opszero.com/img/common/aws-advanced.png" alt="AWS Advanced Tier" width="150px" >
  <img src="https://opszero.com/img/common/aws-devops-competency.png" alt="AWS DevOps Competency" width="150px" >
  <img src="https://opszero.com/img/common/aws-eks.png" alt="AWS EKS Delivery" width="150px" >
  <img src="https://opszero.com/img/common/aws-public-sector.png" alt="AWS Public Sector" width="150px" >
</div>
<!-- END_TF_DOCS -->