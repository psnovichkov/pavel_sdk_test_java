SERVICE = pavel_sdk_test_java
SERVICE_CAPS = pavel_sdk_test_java
SPEC_FILE = pavel_sdk_test_java.spec
URL = https://kbase.us/services/pavel_sdk_test_java
DIR = $(shell pwd)
LIB_DIR = lib
SCRIPTS_DIR = scripts
LBIN_DIR = bin
TARGET ?= /kb/deployment
JARS_DIR = $(TARGET)/lib/jars
EXECUTABLE_SCRIPT_NAME = run_$(SERVICE_CAPS)_async_job.sh
STARTUP_SCRIPT_NAME = start_server.sh
KB_RUNTIME ?= /kb/runtime
ANT = $(KB_RUNTIME)/ant/bin/ant

default: compile-kb-module build-startup-script build-executable-script

compile-kb-module:
	kb-mobu compile $(SPEC_FILE) \
		--out $(LIB_DIR) \
		--plclname $(SERVICE_CAPS)::$(SERVICE_CAPS)Client \
		--jsclname javascript/Client \
		--pyclname $(SERVICE_CAPS).$(SERVICE_CAPS)Client \
		--javasrc src \
		--java \
		--javasrv \
		--javapackage .;
	$(ANT) war -Djars.dir=$(JARS_DIR)
	chmod +x $(SCRIPTS_DIR)/entrypoint.sh

build-executable-script:
	mkdir -p $(LBIN_DIR)
	$(ANT) build-executable-script -Djars.dir=$(JARS_DIR) -Dexec.cmd.file=$(EXECUTABLE_SCRIPT_NAME)
	chmod +x $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)

build-startup-script:
	mkdir -p $(LBIN_DIR)
	echo '#!/bin/bash' > $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'cd $(SCRIPTS_DIR)' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	echo 'java -cp $(JARS_DIR)/jetty/jetty-start-7.0.0.jar:$(JARS_DIR)/jetty/jetty-all-7.0.0.jar:$(JARS_DIR)/servlet/servlet-api-2.5.jar \
		-DKB_DEPLOYMENT_CONFIG=$(DIR)/deploy.cfg -Djetty.port=5000 org.eclipse.jetty.start.Main jetty.xml' >> $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)
	chmod +x $(SCRIPTS_DIR)/$(STARTUP_SCRIPT_NAME)

clean:
	rm -rfv $(LBIN_DIR)
