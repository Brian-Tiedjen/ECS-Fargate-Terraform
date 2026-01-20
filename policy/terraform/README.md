# Policy-as-Code (Conftest + OPA)

This folder contains Conftest policies that validate Terraform plan output.
CI renders `tfplan.json` via `terraform show -json` and runs Conftest against it.

## How it works

- Conftest evaluates `deny` rules in the `main` package.
- Any `deny` result fails the CI job.
- The helper in `lib.rego` walks Terraform plan resources for reuse.

## Current rules

- Block security groups that allow SSH (port 22) from `0.0.0.0/0`.
- Require an S3 SSE config resource when any `aws_s3_bucket` exists.

## Add a new rule

1. Create or update a `.rego` file in this folder.
2. Use `package main`.
3. Add a `deny[msg] { ... }` rule that returns a clear message.

Example:

```rego
package main

deny[msg] {
  r := resources[_]
  r.type == "aws_lb"
  r.values.internal == true
  msg := sprintf("ALB %s must be public in dev", [r.address])
}
```

## Run locally

From an environment folder (e.g., `infra/envs/dev`):

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json -p ../../policy/terraform
```
