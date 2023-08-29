.PHONY: all
all: help

.PHONY: fetch_docs
fetch_docs:
	./get_k8s_openapi_docs.sh

.PHONY: fetch_docs_group
fetch_docs_group:
	./get_k8s_openapi_docs.sh $(filter-out $@,$(MAKECMDGOALS))

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  fetch_docs               Fetch all the OpenAPI docs"
	@echo "  fetch_docs_group <group> Fetch docs for API groups containing <group>"

%:
	@:
