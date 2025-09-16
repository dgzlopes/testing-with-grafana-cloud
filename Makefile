.PHONY: tf-bootstrap
tf-bootstrap: tf-init tf-setup tf-apply

.PHONY: tf-init
tf-init:
	terraform -chdir="./terraform" init

.PHONY: tf-plan
tf-plan:
	terraform -chdir="./terraform" plan

.PHONY: tf-setup
tf-setup:
	terraform -chdir=./terraform apply \
		-target=resource.grafana_cloud_stack_service_account.testing_sa \
		-target=resource.grafana_cloud_stack_service_account_token.testing_sa_token \
		-target=resource.grafana_k6_installation.k6_installation \
		-auto-approve

.PHONY: tf-apply
tf-apply:
	terraform -chdir="./terraform" apply -auto-approve

.PHONY: tf-destroy
tf-destroy:
	terraform -chdir="./terraform" destroy -auto-approve

.PHONY: gen-openapi-client
gen-openapi-client:
	npx openapi-to-k6 specs/quickpizza.openapi.yaml src/_lib/http_client.ts