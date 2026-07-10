# CST8918 - A09: Husky Pre-commit Hook + GitHub Actions CI

**Course:** CST8918 - DevOps: Infrastructure as Code  
**Author:** Divyang  
**Lab:** Hybrid-A09  

## What this lab is about

Terraform code is still code - it needs quality checks before it reaches
production. This lab builds **two safety gates** around a Terraform project:

1. **Local gate (Husky pre-commit hook):** runs automatically on every
   `git commit` on the developer's machine. Bad code never even gets
   committed.
2. **Remote gate (GitHub Actions workflow):** runs automatically on every
   **pull request**. Catches anything that slipped past the local hook
   (for example, a commit made with `--no-verify`).

Fast, cheap checks run early and often; this pattern is called
**shifting left**.

## The checks

| Check                | What it does                                               |
| -------------------- | ---------------------------------------------------------- |
| `terraform fmt`      | Verifies consistent code formatting (indentation, spacing) |
| `terraform validate` | Verifies syntax and internal consistency                    |
| `tflint`             | Static analysis - catches errors and bad practices          |

None of these need Azure credentials and nothing is ever deployed - the
Terraform script in `infrastructure/` only exists as something to check.

## Repository structure

```
.
├── .github/workflows/action-terraform-verify.yml   # CI workflow (2 jobs)
├── .husky/pre-commit                                # local git hook
├── infrastructure/main.tf                           # simple Terraform script
└── package.json                                     # husky dev dependency
```

## The pre-commit hook

```sh
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

set -e

terraform fmt -check -recursive
terraform -chdir=infrastructure validate
tflint --chdir=infrastructure
```

`set -e` makes the hook stop at the first failing check, so a failure in any
check blocks the commit.

## The GitHub Actions workflow

Two jobs run on every pull request to `main`:

1. **terraform fmt check** - runs `terraform fmt -check` on every `.tf` file
   changed in the PR.
2. **terraform validate** - runs `terraform init -backend=false` and
   `terraform validate` on the `infrastructure/` folder.

## How the gates were tested

- **Local:** committed a badly formatted file → the hook rejected the commit
  (`pre-commit hook exited with code 3`). After `terraform fmt -recursive`,
  the commit succeeded.
- **Remote:** committed broken code with `git commit --no-verify` (bypassing
  the hook) and opened a pull request → the workflow **failed** (run #1).
  After fixing the code and pushing, the workflow **passed** (run #2) and the
  PR was merged.

## What I learned

- A local hook is fast feedback for the developer; CI is enforcement for the
  whole team. You need both, because local hooks can be bypassed.
- `terraform fmt` only fixes formatting of *valid* code - syntax errors are
  caught by `validate`, which is why the workflow needs both jobs.
- Reading exit codes matters: in this lab, a failing check with red output is
  often the *expected, correct* result.
