#!/bin/bash

PORT=7777
APIDOCS_DIR=apidocs

if [ "$#" -gt 1 ]; then
  echo "Too many arguments"
  echo "Usage:"
  echo " - Fetch all the OpenAPI docs:                      $ ./get_k8s_openapi_docs.sh"
  echo " - Fetch docs for API groups that contain a string: $ ./get_k8s_openapi_docs.sh <substring-of-API-group>"
  exit
fi

mkdir -p $APIDOCS_DIR

# start oc/k8s proxy
(kubectl proxy --port=$PORT &) | grep -q "Starting to serve on"
echo "The proxy has been created on port $PORT"

if [ ! -z "$1" ]; then
  group_name=$1
  echo "You've set to download the API group: $group_name"
  group_found=false
else
  echo "You've set to download all the OpenAPI docs"
fi

for apipath in $(kubectl api-versions); do

  if [ ! -z "$group_name" ]; then
    if [[ $apipath != *"$group_name"* ]]; then
      continue
    else
      group_found=true
    fi
  fi

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
      # Replace all instances of '{namespace}' with 'default'
    echo "Finding {namespace} and replacing it with default in: $result_filepath"
    sed -i 's/{namespace}/default/g' "$result_filepath"
  else 
    echo "The Openapi doc is not found in the URL: $download_url"
  fi

done

if [ ! -z "$group_name" ] && [ "$group_found" = false ]; then
  echo "No '$group_name' API found in the cluster"
fi

## stop the proxy
echo "Stopping the proxy"
kill `pgrep -f 'kubectl proxy'`
