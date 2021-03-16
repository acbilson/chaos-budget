.POSIX:

.PHONY: build-beancount
build-beancount: ## builds a beancount container
	docker build . -f beancount/Dockerfile -t acbilson/beancount-2.3.3:latest

.PHONY: build-fava
build-fava: ## builds a fava container
	docker build . -f fava/Dockerfile -t acbilson/fava-2.3.3:latest

.PHONY: build
build: build-beancount build-fava ## builds both fava and beancount containers
	echo 'complete'

.PHONY: run
run: build ## runs fava container
	docker run -it --rm -p 5000:5000 \
    -v ~/source/chaos-budget/journals:/journals \
    -v ~/source/chaos-budget/importers:/importers \
    acbilson/fava-2.3.3:latest

.PHONY: identify
identify: ## runs bean-identify on my ingestion folder
	docker run -it --rm \
    -v ~/source/chaos-budget/data:/data \
    -v ~/source/chaos-budget/importers:/importers \
    acbilson/beancount-2.3.3:latest sh -c "bean-identify /importers/config.py /data"

.PHONY: check
check: ## runs bean-check for my default journal
	docker run -it --rm -v ~/source/chaos-budget/journals:/journals acbilson/beancount-2.3.3:latest bean-check journal.beancount

.PHONY: import
import: ## runs bean-extract to import all csv data in the ./data folder
	docker run -it --rm \
    -v ~/source/chaos-budget/data:/data \
    -v ~/source/chaos-budget/importers:/importers \
    acbilson/beancount-2.3.3:latest sh -c "bean-extract /importers/config.py /data > /data/import.beancount"

.PHONY: reload
reload: ## creates a new import file from all statements to-date
	rm -f data/* && cp docs/checking/* data/ && cp docs/saving/* data/ && \
	docker run -it --rm \
    -v ~/source/chaos-budget/data:/data \
    -v ~/source/chaos-budget/importers:/importers \
    acbilson/beancount-2.3.3:latest sh -c "bean-extract /importers/config.py /data > /data/import.beancount"


.PHONY: format
format: ## runs bean-format on my default journal
	docker run -it --rm -v ~/source/chaos-budget/journals:/journals acbilson/beancount-2.3.3:latest sh -c "bean-format journal.beancount > journal-formatted.beancount"

.PHONY: help
help: ## show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | \
	sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

