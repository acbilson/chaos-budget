build:
   docker build --target prod -t acbilson/budget-dev:buster-slim .

start:
	. .env && docker run -it --rm --expose ${EXPOSED_PORT} -p ${EXPOSED_PORT}:5000 -v ${CONTENT_PATH}/journals:/journals -v ${SOURCE_PATH}/import:/data -v ${CONTENT_PATH}/docs:/docs -v ${SOURCE_PATH}/importers:/importers --name budget acbilson/budget-dev:buster-slim
