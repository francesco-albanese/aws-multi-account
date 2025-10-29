SHELL := /bin/bash

.DEFAULT_GOAL := help

ACCOUNT ?= sandbox
AWS_PROFILE ?= sandbox
terraform = AWS_PROFILE=$(AWS_PROFILE) terraform

include makefiles/terraform.mk

.PHONY: help init plan apply destroy validate fmt
help:
	@echo "Available targets:"
	@echo "  init        - Initialize Terraform"
	@echo "  plan        - Show Terraform plan"
	@echo "  apply       - Apply Terraform changes"
	@echo "  destroy     - Destroy Terraform-managed infrastructure"
	@echo "  validate    - Validate Terraform configuration"
	@echo "  fmt         - Format Terraform files"
	@echo ""  Usage:"
	@echo "    make <target> ACCOUNT=<account_name> AWS_PROFILE=<aws_profile>"
	@echo ""  Example:"
	@echo "    make plan ACCOUNT=prod AWS_PROFILE=prod-profile"
	@echo ""  Note:"
	@echo "    ACCOUNT and AWS_PROFILE default to 'sandbox' if not provided."
	@echo " help        - Show this help message"