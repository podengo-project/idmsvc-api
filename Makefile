srcdir = .

PYTHON = python3
VENV = $(srcdir)/.venv
PYTHON_VENV = $(VENV)/bin/python
VALIDATOR = $(VENV)/bin/openapi-spec-validator
NODE_BIN = node_modules/.bin
BIN = bin
TMP = tmp
OAPI_CODEGEN = $(BIN)/oapi-codegen
OAPI_CODEGEN_VERSION ?= v1.14.0

SWAGGER_CONTAINER = swagger-editor

.PHONY: all
all:
	$(MAKE) openapi-sort
	$(MAKE) validate
	$(MAKE) oapi-codegen
	$(MAKE) vacuum
	$(MAKE) generate-json

.PHONY: clean
clean:
	rm -rf $(VENV) $(BIN) $(TMP)


$(PYTHON_VENV):
	$(PYTHON) -m venv $(VENV)
	$(PYTHON_VENV) -m pip install -U pip
	$(PYTHON_VENV) -m pip install -r requirements-dev.txt

$(VALIDATOR): $(PYTHON_VENV)

$(NODE_BIN)/%: package.json package-lock.json
	npm install
	touch $(NODE_BIN)/*

.PHONY: validate
validate: $(VALIDATOR)
	$(VALIDATOR) public.openapi.yaml
	$(VALIDATOR) internal.openapi.yaml
	$(VALIDATOR) metrics.openapi.yaml

.PHONY: openapi-sort
openapi-sort: $(PYTHON_VENV)
	$(PYTHON_VENV) yamlsort.py *.openapi.yaml

.PHONY: vacuum
vacuum: $(NODE_BIN)/vacuum
	npm run vacuum:lint public.openapi.yaml
	npm run vacuum:lint internal.openapi.yaml
	npm run vacuum:lint metrics.openapi.yaml

.PHONY: swagger-editor
swagger-editor:
	podman run --rm --detach \
	  -p 8080:8080 \
	  -v $(shell pwd):/api:ro,Z \
	  --name $(SWAGGER_CONTAINER) \
	  -e SWAGGER_FILE=/api/public.openapi.yaml \
	  docker.io/swaggerapi/swagger-editor
	xdg-open http://localhost:8080

.PHONY: swagger-editor-stop
swagger-editor-stop:
	podman stop $(SWAGGER_CONTAINER)

.PHONY: generate-json
generate-json: public.openapi.json internal.openapi.json metrics.openapi.json

%.openapi.json: %.openapi.yaml $(PYTHON_VENV)
	$(PYTHON_VENV) yaml2json.py $< $@
