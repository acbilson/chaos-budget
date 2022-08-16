set dotenv-load

## builds a production docker image
build:
	COMMIT_ID=$(git rev-parse --short HEAD); \
	docker build \
	--build-arg EXPOSED_PORT=${EXPOSED_PORT} \
	-t acbilson/budget:latest \
	-t acbilson/budget:${COMMIT_ID} .

## starts a production docker image
start:
	docker run \
	-it --rm \
	--expose ${EXPOSED_PORT} \
	-p ${EXPOSED_PORT}:5000 \
	-v ${CONTENT_PATH}/journals:/journals \
	-v ${SOURCE_PATH}/import:/data \
	-v ${CONTENT_PATH}/docs:/docs \
	-v ${SOURCE_PATH}/importers:/importers \
	--name budget \
	acbilson/budget:latest

## runs bean-identify to check my importers
identify:
	docker run -it --rm \
	-v ~/source/chaos-budget/data:/data \
	-v ~/source/chaos-budget/importers:/importers \
	acbilson/budget:latest
	sh -c "bean-identify /importers/config.py /data"

## runs bean-check for my default journal
check:
	docker run -it --rm \
	-v ~/source/chaos-budget-content/journals:/journals \
	acbilson/budget:latest \
	bean-check journal.beancount

## runs bean-format on my default journal
format:
	docker run -it --rm \
	-v ~/source/chaos-budget-content/journals:/journals \
	acbilson/budget:latest \
	sh -c "bean-format journal.beancount > journal-formatted.beancount"

