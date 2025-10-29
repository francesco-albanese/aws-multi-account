SHELL := /bin/bash

terraform = AWS_PROFILE=$(AWS_PROFILE) terraform
STACKS = $(dir $(wildcard terraform/*/.))
STACKS := $(sort $(notdir $(STACKS:/=)))

all:

.SECONDEXPANSION:
$(STACKS): $$@-init $$@-validate $$@-plan $$@-apply $$@-destroy

STATE_CONF := state.conf
environmental_KEY := $(PROJECT_NAME)
environmental_ACCOUNT := $(ACCOUNT)
environmental_FLAGS := -var-file=env/$(ACCOUNT).tfvars
shared-services-KEY := $(PROJECT_NAME)
shared-services-ACCOUNT := shared-services
shared-services_FLAGS := 

tf-setup:
@if [ ! -d "$$HOME/.tfenv" ]; then git clone https://github.com/tfutils/tfenv.git $$HOME/.tfenv && echo 'export PATH="$$HOME/.tfenv/bin:$$PATH"' >> $$HOME/.zshrc; fi
@if ! type tflint >/dev/null; then curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash; fi

tf-configure: ## swap terraform to correct version using tfenv
tf-configure: TF_VERSION := $(shell grep required_version $(PWD)/terraform/environmental/terraform.tf | sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$$/\1/')
tf-configure:
	@tfenv use $(TF_VERSION)

clean: ## reset all terraform stacks
clean: $(addsuffix -clean, $(STACKS))

lint: ## run tflint on all terraform stacks
lint: $(addsuffix -lint, $(STACKS))

init: ## initialize all terraform stacks
init: $(addsuffix -init, $(STACKS))

init-no-backend: ## initialize all terraform stacks with -backend=false
init-no-backend: $(addsuffix -init-no-backend, $(STACKS))

upgrade: ## upgrade all terraform stacks
upgrade: TF_FLAGS ?= -upgrade
upgrade: $(addsuffix -init, $(STACKS))


validate: ## validate all terraform stacks
validate: $(addsuffix -validate, $(STACKS))

plan: ## show plan for all terraform stacks
plan: $(addsuffix -plan, $(STACKS))

apply: ## apply all terraform stacks
apply: 
	@echo "++++ Applying environmental stack ++++"
	$(terraform) -chdir=terraform/environmental apply $(environmental_FLAGS) $(TF_FLAGS)

destroy: ## destroy all terraform stacks
destroy: $(addsuffix -destroy, $(STACKS))

.PHONY: fmt
fmt: ## format all terraform
	@terraform fmt -recursive terraform/

help: ## show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s - %s\n", $$1, $$2}'
	@echo ""
	@echo " Usage:"
	@echo "    make <target> ACCOUNT=<account_name> AWS_PROFILE=<aws_profile>"