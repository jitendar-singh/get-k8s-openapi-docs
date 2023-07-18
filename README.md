# get-k8s-openapi-docs
Generate OpenAPI docs of the Kubernetes APIs from the running cluster.

With `kubectl proxy` used, each OpenAPI doc file for an API group(listed in `kubectl api-versions`) will be fetched from the cluster respectively.

## Usage
Assuming that you have access to your cluster (e.g. `$ export KUBECONFIG=kubeconfig`), run the following command. The downloaded OpenAPI doc files will be saved in the `apidocs`(hardcoded in the script file at the moment) directory.

###   - Fetch all the OpenAPI docs: $ ./get_k8s_openapi_docs.sh
```
$ ./get_k8s_openapi_docs.sh
```
###    - Fetch the OpenAPI docs for API groups that contain a string
```
$ ./get_k8s_openapi_docs.sh <substring-of-API-group>
```

