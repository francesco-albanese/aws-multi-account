SHELL := /bin/bash

.DEFAULT_GOAL := help

PROJECT_NAME ?= aws-multi-account
ACCOUNT ?= sandbox
AWS_PROFILE ?= sandbox
terraform = AWS_PROFILE=$(AWS_PROFILE) terraform

include makefiles/terraform.mk

.PHONY: init plan apply destroy validate fmt