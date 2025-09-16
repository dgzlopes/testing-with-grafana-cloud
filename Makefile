.PHONY: tf-init
tf-init:
	terraform -chdir="./terraform" init

.PHONY: tf-plan
tf-plan:
	terraform -chdir="./terraform" plan

.PHONY: tf-apply
tf-apply:
	terraform -chdir="./terraform" apply -auto-approve

.PHONY: gen-openapi-client
gen-openapi-client:
	npx openapi-to-k6 specs/quickpizza.openapi.yaml src/_lib/http_client.ts