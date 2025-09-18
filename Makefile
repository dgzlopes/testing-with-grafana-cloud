.PHONY: tf-bootstrap
tf-bootstrap: node-init tf-init tf-setup tf-apply

.PHONY: node-init
node-init:
	@echo "🔹 Installing Node dependencies"
	@npm install
	
.PHONY: tf-init
tf-init:
	@echo "🔹 Initializing Terraform"
	@terraform -chdir="./terraform" init

.PHONY: tf-plan
tf-plan:
	@echo "🔹 Planning Terraform changes"
	@terraform -chdir="./terraform" plan

.PHONY: tf-setup
tf-setup:
	@echo "🔹 Setting up base Terraform resources"
	@terraform -chdir=./terraform apply \
		-target=resource.grafana_cloud_stack_service_account.testing_sa \
		-target=resource.grafana_cloud_stack_service_account_token.testing_sa_token \
		-target=resource.grafana_k6_installation.k6_installation \
		-auto-approve

.PHONY: tf-apply
tf-apply:
	@echo "🔹 Applying Terraform resources"
	@terraform -chdir="./terraform" apply -auto-approve

.PHONY: tf-destroy
tf-destroy:
	@echo "💣 Destroying Terraform resources"
	@terraform -chdir="./terraform" destroy -auto-approve

.PHONY: gen-openapi-client
gen-openapi-client:
	@echo "🔹 Generating OpenAPI client"
	@npx openapi-to-k6 specs/quickpizza.openapi.yaml src/_lib/http_client.ts


# Studio sync helpers
STUDIO_DIR ?= $(HOME)/Documents/k6-studio
ifeq ($(OS),Windows_NT)
	STUDIO_DIR ?= $(USERPROFILE)/Documents/k6-studio
endif

.PHONY: studio-update-local
studio-update-local:
	@echo "🔹 Updating local Studio installation at $(STUDIO_DIR) with repo artifact"
	@mkdir -p "$(STUDIO_DIR)/Data" "$(STUDIO_DIR)/Generators" "$(STUDIO_DIR)/Recordings"
	@changes=0; \
	out=$$(rsync -a --out-format='%n' src/_studio/data/ "$(STUDIO_DIR)/Data/" | grep -v '^./$$' || true); \
	if [ -n "$$out" ]; then echo "Data"; echo "$$out" | sed 's/^/  ++ /'; changes=1; fi; \
	out=$$(rsync -a --out-format='%n' src/_studio/generators/ "$(STUDIO_DIR)/Generators/" | grep -v '^./$$' || true); \
	if [ -n "$$out" ]; then echo "Generators"; echo "$$out" | sed 's/^/  ++ /'; changes=1; fi; \
	out=$$(rsync -a --out-format='%n' src/_studio/recordings/ "$(STUDIO_DIR)/Recordings/" | grep -v '^./$$' || true); \
	if [ -n "$$out" ]; then echo "Recordings"; echo "$$out" | sed 's/^/  ++ /'; changes=1; fi; \
	if [ $$changes -eq 1 ]; then echo "✅ Studio updated from repo!"; else echo "No changes"; fi

.PHONY: studio-update-repo
studio-update-repo:
	@echo "🔹 Updating repo with local Studio installation artifacts from $(STUDIO_DIR)"
	@mkdir -p src/_data src/_studio/generators src/_studio/recordings
	@changes=0; \
	out=$$(rsync -a --out-format='%n' "$(STUDIO_DIR)/Data/" src/_studio/data/ | grep -v '^./$$' || true); \
	if [ -n "$$out" ]; then echo "Data"; echo "$$out" | sed 's/^/  ++ /'; changes=1; fi; \
	out=$$(rsync -a --out-format='%n' "$(STUDIO_DIR)/Generators/" src/_studio/generators/ | grep -v '^./$$' || true); \
	if [ -n "$$out" ]; then echo "Generators"; echo "$$out" | sed 's/^/  ++ /'; changes=1; fi; \
	out=$$(rsync -a --out-format='%n' "$(STUDIO_DIR)/Recordings/" src/_studio/recordings/ | grep -v '^./$$' || true); \
	if [ -n "$$out" ]; then echo "Recordings"; echo "$$out" | sed 's/^/  ++ /'; changes=1; fi; \
	if [ $$changes -eq 1 ]; then echo "✅ Repo updated from Studio!"; else echo "No changes"; fi
