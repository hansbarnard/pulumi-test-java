VERSION          := $(shell pulumictl get version --language generic)

PACK             := ipidp
PROJECT          := github.com/pulumi/pulumi-${PACK}

PROVIDER         := pulumi-resource-${PACK}
CODEGEN          := pulumi-gen-${PACK}
VERSION_PATH     := provider/pkg/version.Version

WORKING_DIR      := $(shell pwd)
SCHEMA_PATH      := ${WORKING_DIR}/schema.json

SRC              := provider/cmd/pulumi-resource-${PACK}
JAVA_GEN         := pulumi-java-gen
JAVA_GEN_VERSION := v0.9.2

# generate:: gen_go_sdk gen_dotnet_sdk gen_nodejs_sdk gen_python_sdk bin/pulumi-java-gen

CURRENT_VERSION := $(shell cat ${SRC}/${PACK}_provider/VERSION 2> /dev/null)

check_version:
	@if [ "$(CURRENT_VERSION)" != "$(VERSION)" ]; then echo "${VERSION}" > ${SRC}/${PACK}_provider/VERSION; fi

build:: build_python_sdk build_dotnet_sdk build_nodejs_sdk build_java gen_go_sdk

# Provider

# java SDK
build_java: bin/pulumi-java-gen
	rm -rf sdk/java
	$(WORKING_DIR)/bin/$(JAVA_GEN) generate --schema ${SCHEMA_PATH} --out sdk/java  --build gradle-nexus
	cd sdk/java/ && \
		echo "module fake_java_module // Exclude this directory from Go tools\n\ngo 1.17" > go.mod && \
		PACKAGE_VERSION=$(VERSION) gradle --console=plain build

bin/pulumi-java-gen:
	mkdir -p bin/
	pulumictl download-binary -n pulumi-language-java -v $(JAVA_GEN_VERSION) -r pulumi/pulumi-java


# Go SDK
gen_go_sdk::
	rm -rf sdk/go
	cd provider/cmd/$(CODEGEN) && go run main.go go ../../../sdk/go ${SCHEMA_PATH} $(VERSION)
	

# .NET SDK
build_dotnet_sdk:: DOTNET_VERSION := $(shell pulumictl get version --language dotnet)
build_dotnet_sdk::
	rm -rf sdk/dotnet
	cd provider/cmd/$(CODEGEN) && go run main.go dotnet ../../../sdk/dotnet ${SCHEMA_PATH} $(VERSION)
	cd sdk/dotnet/ && \
		echo "module fake_dotnet_module // Exclude this directory from Go tools\n\ngo 1.17" > go.mod && \
		echo "${DOTNET_VERSION}" >version.txt && \
		dotnet build /p:Version=${DOTNET_VERSION}


# Node.js SDK
gen_nodejs_sdk::
	rm -rf sdk/nodejs
	cd provider/cmd/${CODEGEN} && go run . nodejs ../../../sdk/nodejs ${SCHEMA_PATH}

build_nodejs_sdk:: gen_nodejs_sdk
	cd sdk/nodejs/ && \
		yarn install && \
		yarn run tsc --version && \
		yarn run tsc && \
		cp -R scripts/ bin && \
		cp ../../README.md ../../LICENSE package.json yarn.lock ./bin/ && \
		sed -i.bak -e "s/\$${VERSION}/$(VERSION)/g" ./bin/package.json && \
		rm ./bin/package.json.bak


# Python SDK
build_python_sdk:: PYPI_VERSION := $(shell pulumictl get version --language python)
build_python_sdk::
	rm -rf sdk/python
	cd provider/cmd/$(CODEGEN) && go run main.go python ../../../sdk/python ${SCHEMA_PATH} $(VERSION)
	cd sdk/python/ && \
		echo "module fake_python_module // Exclude this directory from Go tools\n\ngo 1.17" > go.mod && \
		cp ../../README.md . && \
		python3 setup.py clean --all 2>/dev/null && \
		rm -rf ./bin/ ../python.bin/ && cp -R . ../python.bin && mv ../python.bin ./bin && \
		sed -i.bak -e 's/^VERSION = .*/VERSION = "$(PYPI_VERSION)"/g' -e 's/^PLUGIN_VERSION = .*/PLUGIN_VERSION = "$(VERSION)"/g' ./bin/setup.py && \
		rm ./bin/setup.py.bak && \
		cd ./bin && python3 setup.py build sdist



