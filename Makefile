COMPONENT_NAME ?= dds

ifeq (${SILENT},1)
	VERBOSE_TEST :=
else
	VERBOSE_TEST := -v
endif

LIBDDS_BUILD_DIR := libdds/.build

include bridge-hackathon/make/Makefile

# Make sure submodules have been initialized and libdds has latest code
libdds/.git submodule-update bridge-hackathon/make/Makefile:
	git submodule update --init --recursive

# Configure libdds build
# Dependency makes sure submodules have been initialized
${LIBDDS_BUILD_DIR}/CMakeCache.txt: libdds/.git
	mkdir -p ${LIBDDS_BUILD_DIR}
	cd ${LIBDDS_BUILD_DIR} && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ..

# Build libdds
# Dependencies makes sure that configure has been run and code is the latest one
libdds-build: ${LIBDDS_BUILD_DIR}/CMakeCache.txt submodule-update
	+make -C ${LIBDDS_BUILD_DIR}

run_local_tests: libdds-build
	python3 -m unittest discover ${VERBOSE_TEST}

curl_local_URL := http://localhost:5000/api/dds-table/
curl_prod_URL  := https://dds.prod.globalbridge.app/api/dds-table/
CURL_URL       ?= ${$@_URL}

# Slightly unusual approach in order to keep the command-line output legible.
# May need to add "--insecure" when we add more targets.
curl_local curl_prod:
	curl \
	--header "Content-Type: application/json" \
	--data \
	'{"hands": { \
		"S":["D3", "C6", "DT", "D8", "DJ", "D6", "CA", "C3", "S2", "C2", "C4", "S9", "S7"],    \
		"W":["DA", "S4", "HT", "C5", "D4", "D7", "S6", "S3", "DK", "CT", "D2", "SK", "H8"],    \
		"N":["C7", "H6", "H7", "H9", "CJ", "SA", "S8", "SQ", "D5", "S5", "HK", "C8", "HA"],    \
		"E":["H2", "H5", "CQ", "D9", "H4", "ST", "HQ", "SJ", "HJ", "DQ", "H3", "C9", "CK"] }}' \
	${CURL_URL}

logfile := logs/src.api.$(shell date +%FT%T).log
pidfile := logs/server.PID

start_local_server: libdds-build stop_local_server
	@echo
	@echo Starting a local test service as a background process. You can stop it with \`make stop_local_service\`
	@echo The server log will be written to \'${logfile}\'.
	@echo
	python3 -m src.api > ${logfile} 2>&1 & echo $$! > ${pidfile}

stop_local_server:
	[ ! -e ${pidfile} ] || (kill $$(cat ${pidfile}) ; rm ${pidfile})
