# get-k8s-openapi-docs
Generate OpenAPI docs of the Kubernetes APIs from the running cluster.
Each OpenAPI doc file for an API group(listed in `kubectl api-versions`) will be fetched from the cluster respectively.

## Usage
Assuming that you have access to your cluster (e.g. `$ export KUBECONFIG=kubeconfig`), run the following command.
"""
$ ./get_k8s_openapi_docs.sh
"""

OpenAPI doc files will be saved in the 'apidocs' directory.
