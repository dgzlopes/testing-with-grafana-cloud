# testing-with-grafana-cloud

> This repo is very wip and things will change a lot. Keep that in mind.

Requirements:
- Terraform (>= 1.13.0)
- Grafana Cloud Account with an existing Stack

## How to get started

After cloning the repository create a .env file based on the .env.example file.

```bash
cp .env.example .env
```

Then, edit the .env file and add a Grafana Cloud API Key and the details of your stack.
```
STACK_SLUG=mystack
CLOUD_REGION=prod-eu-west-2
CLOUD_ACCESS_POLICY_TOKEN=abdc123
```

That's it! Now run the following command to create the resources in your Grafana Cloud Stack.

```
make tf-apply
```

**Where to find the Stack Slug and Cloud Region?**
TBD

**What scopes are required for the API Key?**
stacks:read
stacks:write
subscriptions:read
orgs:read
stack-service-accounts	