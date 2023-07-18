#!/bin/bash

#########################################################################
##  Fetch OpenAPI docs of the Kubernetes APIs from the running cluster
##  Author: Jeremy Choi (jechoi@redhat.com)
#########################################################################
 
PORT=7777
APIDOCS_DIR=apidocs

mkdir -p $APIDOCS_DIR

# start oc/k8s proxy
(kubectl proxy --port=$PORT &) | grep -q "Starting to serve on"
echo "The proxy has been created on port $PORT"

for apipath in $(kubectl api-versions); do

  ## save openAPI files
  if [[ $apipath == *"/"* ]]    # e.g. 'node.k8s.io/v1'
  then
    echo "Fetching the Openapi doc for the API group: $apipath"
    version=${apipath#*/}
    api=${apipath%/$version}

    download_url=http://localhost:$PORT/openapi/v3/apis/$apipath
    result_filepath=$APIDOCS_DIR/api-$api-$version-openapi.json
  else   # e.g. 'v1'
    echo "Fetching the Openapi doc for the core API version: $apipath"
    download_url=http://localhost:$PORT/openapi/v3/api/$apipath
    result_filepath=$APIDOCS_DIR/api-core-$apipath-openapi.json
  fi

  http_status=$(curl -s -o /dev/null -w "%{http_code}" "$download_url")

  if [[ $http_status -eq 200 ]]; then
  curl -s $download_url > $result_filepath
  else 
  echo "The Openapi doc is not found in the URL: $download_url"
  fi

done

## stop the proxy
echo "Stopping the proxy"
kill `pgrep -f 'kubectl proxy'`
