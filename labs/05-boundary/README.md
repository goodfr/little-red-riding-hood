# Bounary

```
terraform init
```

Run terraform apply against the kubernetes terraform module:

```

aws-vault exec custom -- kubectl create ns boundary
aws-vault exec custom -- terraform apply -target module.kubernetes -auto-approve

export BOUNDARY_ADDR="http://ac6c7a66b9daf4986939b7e7dae09ff0-1723290738.eu-west-1.elb.amazonaws.com:9200" 
aws-vault exec custom -- terraform apply -auto-approve
```

Expose all 3 Boundary services running on minikube, on your local host using `kubectl port-forward` (you'll
need to do this in 3 separate long running shells):

```
$ kubectl port-forward pods/$(kubectl get pods | grep boundary | cut -d " " -f 1) 9200:9200
Forwarding from 127.0.0.1:9200 -> 9200
Forwarding from [::1]:9200 -> 9200

$ kubectl port-forward pods/$(kubectl get pods | grep boundary | cut -d " " -f 1) 9201:9201
Forwarding from 127.0.0.1:9201 -> 9201
Forwarding from [::1]:9201 -> 9201

$ kubectl port-forward pods/$(kubectl get pods | grep boundary | cut -d " " -f 1) 9202:9202
Forwarding from 127.0.0.1:9202 -> 9202
Forwarding from [::1]:9202 -> 9202
Handling connection for 9202
```

Run terraform apply against the boundary terraform module using the value for Boundary's 
address found in the previous command:

```
# Set the external address for your service
export KUBE_SERVICE_ADDRESS=$(echo "http://127.0.0.1:9200")
terraform apply -target module.boundary -var boundary_addr=$KUBE_SERVICE_ADDRESS
```

### Verify

Check the deployments:

```
$ kubectl get deployments
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
boundary   1/1     1            1           12m
postgres   1/1     1            1           12m
redis      1/1     1            1           12m
```

### Login to Boundary

In the shell you intend to run `boundary` commands, export the `BOUNDARY_ADDR` variable with 
the value from the `kubectl port-forward` command:

```
$ export BOUNDARY_ADDR=http://localhost:9200
```

Get the auth method ID for the password auth method in the `primary` scope. We're going to use 
some jq foo to to get the correct ID (remember resource ID's are unique, so yours will be different
from the one I get here): 

```

boundary scopes list -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]"

$ boundary auth-methods list -scope-id $(boundary scopes list -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"')

boundary auth-methods list -scope-id  -format json $(boundary scopes list -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"')

# set BOUNDARY_AUTH_METHOD_ID

export BOUNDARY_SCOPE=$(boundary scopes list -keyring-type=none -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]")

export BOUNDARY_AUTH_METHOD_ID=$(boundary auth-methods list -keyring-type=none -format json -scope-id $(boundary scopes list -keyring-type=none -format json | jq -c ".items[]  | select(.name | contains(\"primary\")) | .[\"id\"]" | tr -d '"') | jq -c ".items[] | .id" |  sed -e 's/^"//' | sed -e 's/"$//' )


Auth Method information:
  ID:             ampw_1234567890
    Description:  Provides initial administrative authentication into Boundary
    Name:         Generated global scope initial auth method
    Type:         password
    Version:      1
```

Now login:

```
$ boundary authenticate password \
  -login-name=mark \
  -password=foofoofoo \
  -auth-method-id=${BOUNDARY_AUTH_METHOD_ID}
```

From the UI or the CLI, grab the target ID for the redis container in the databases project. If
you're doing this on the CLI, you'll want to list the scopes from the `primary` org scope we 
created using Terraform:

```
$ boundary scopes list
<get scope ID for primary org>
$ boundary scopes list -scope-id <primary org ID>
```

Once you have the databases project scope ID, you can list the targets (again, using some JQ foo to get the correct scope ID for the `primary` scope).

```
$ boundary targets list -scope-id <project_scope_id>
```

You can also navigate to the admin console, login, go to projects, and then targets and copy it from the UI.

You'll want the target ID for the Redis container. Use that target ID to start a session:

```
$ boundary connect -exec redis-cli -target-id ttcp_TBjC1bYRIQ -- -h {{boundary.ip}} -p {{boundary.port}}
127.0.0.1:57159> ping
PONG
127.0.0.1:57159>
```

Congrats! You've just deployed Boundary onto Kubernetes and are able to access other containers running on Kubernetes using it.
