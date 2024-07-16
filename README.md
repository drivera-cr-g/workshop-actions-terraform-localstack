# Workshop: Deployments using GitHub Actions, Terraform and Localstack

## Requirements

- `Docker` **without Desktop** (to avoid licensing issues); either use:
  - [lima](https://lima-vm.io/docs/installation/) with [lima-gui](https://github.com/afbjorklund/lima-gui) (recommended, used in this guide)
  - [colima](https://github.com/abiosoft/colima)
  - [WSL2 with Ubuntu and docker engine](https://medium.com/@sociable_flamingo_goose_694/setup-wsl-for-local-docker-development-on-windows-f0767e0a72d4) for Windows
- [Docker Compose V2](https://docs.docker.com/compose/install/linux/#install-using-the-repository)
- [Docker buildx](https://docs.docker.com/reference/cli/docker/buildx/): install using [brew](https://formulae.brew.sh/formula/docker-buildx) or follow the instructions for [Linux/WSL2](https://docs.docker.com/build/buildkit/configure/)
- Optional (but it helps a lot): Docker Desktop replacement using [Portainer CE](https://docs.portainer.io/start/install-ce/server/docker/linux#deployment). Note: to get the sock info on Lima VMs, log into the machine by running `LIMA_INSTANCE=<instance_name> lima` followed by `docker context ls`, which will get you something like this: `unix:///run/user/505/docker.sock`
- AWS CLI & awslocal (follow the instructions [here](https://docs.localstack.cloud/user-guide/integrations/aws-cli/))
- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)
- [nektos/act](https://nektosact.com/installation/index.html#installation-via-software-package-manager)

## Set and spin-up local resources with `localstack`

- Start `localstack` by making use of the included `Makefile` scripts (requires `make` or `cmake` tools and Docker Compose V2):

```sh
make localstack-up
```

  This creates a `localstack` environment running on a single container; a DynamoDB UI (available at [http://localhost:8001/](http://localhost:8001/), and a S3 UI (available at [http://localhost:8080/buckets](http://localhost:8080/buckets))

- To stop it and remove it, simply run

```sh
make localstack-down
```

**Note**: the service detailed below will also be stopped and removed.

## Start a local service

- Run a local simple service

```sh
make service
```

You will get a simple service to use with DynamoDB and S3, available at [http://0.0.0.0:8088/docs](http://0.0.0.0:8088/docs)

## Run GitHub Actions locally (using `act`)

- You can get the Docker socket for Lima VMs by running:

```sh
limactl list docker -f 'unix://{{.Dir}}/sock/docker.sock'
# You will get an output similar to this
unix:///Users/<username>/.lima/<machine_name>/sock/docker.sock
```

- Set docker context for `act` by running the following command (or using the output from the command above):

```sh
export DOCKER_HOST=$(docker context inspect --format '{{.Endpoints.docker.Host}}')
```

- Run Actions locally:

```sh
act
```

- You should see an output similar to this for the "Hello, world!" step:

```sh
INFO[0000] Using docker host 'unix:///Users/<username>/.lima/<vm_name>/sock/docker.sock', and daemon socket 'unix:///Users/<username>/.lima/<vm_name>/sock/docker.sock'
[CI/CD Pipeline/deploy] 🚀  Start image=catthehacker/ubuntu:act-latest
[CI/CD Pipeline/deploy]   🐳  docker pull image=catthehacker/ubuntu:act-latest platform= username= forcePull=true
[CI/CD Pipeline/deploy] using DockerAuthConfig authentication for docker pull
[CI/CD Pipeline/deploy]   🐳  docker create image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[] network="host"
[CI/CD Pipeline/deploy]   🐳  docker run image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[] network="host"
[CI/CD Pipeline/deploy] ⭐ Run Main Hello world
[CI/CD Pipeline/deploy]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/workflow/0] user= workdir=
| Hello, world!
[CI/CD Pipeline/deploy]   ✅  Success - Main Hello world
[CI/CD Pipeline/deploy] Cleaning up container for job deploy
[CI/CD Pipeline/deploy] 🏁  Job succeeded
```

## Exercises

### Terraform

- Use the following values to create a `terraform.tfvars` file inside the `terraform` directory:

```tf
region   = "us-east-1"
endpoint = "http://localhost:4566"
dynamo_tables = [{
  name         = "SampleTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "MainIndexKey"
  }
]
s3_bucket = "terraform-output-s3-bucket"
s3_key    = "terraform-output.json"
```

**Notes**:

- The AWS account ID, access key ID and access secret are secrets and should be passed either as an environment variable (using the recommended syntax, `TF_VAR_<var_name>`, i.e. `TF_VAR_account_id`) or as an argument when running the `terraform apply` command.
- When using `nektos/act`, the endpoint should be `"http://localstack:4566"` (`localstack` is the container hostname) instead of `"http://localhost:4566"`.
- `act` let you set environment and secret variables using a `.env` and `.secrets` files, respectively (guide [here](https://nektosact.com/usage/index.html?highlight=secrets#envsecrets-files-structure)).

**Tasks**:

1. Create a `dynamodb` module
2. Add a "SampleTable", to be consumed by the included container service
3. Consume the module on the main module (`main.tf`)
4. Create a `s3` module
5. Add an S3 bucket (use the `s3_bucket` variable name)
6. Add an output file to the S3 bucket (use the `s3_key` variable name), creating a JSON file, and adding some custom info to it (use a JSON format, {"key":"value"}, saving info from the terraform process by means of `outputs`)
7. Either:

  Run the included script to initialize terraform

  ```sh
  make terraform-init
  ```

  Or change to `terraform` directory and init terraform

  ```sh
  cd terraform
  terraform init
  ```

8. Run
  
  ```sh
  make terraform-plan
  ```
  
  to check what is going to be applied

9. Run

  ```sh
  make terraform-apply
  ```  
  
  to apply changes and create tables, buckets and outputs.
  Check the created tables, buckets and logs by using the OpenAPI UI at [http://0.0.0.0:8088/docs](http://0.0.0.0:8088/docs); as an alternative, you could use the included Dynamo and S3 UIs mentioned above.
  If you were able to create the Dynamo table, you would be able to use the POST and GET endpoints to create an object in the table and retrieve it using its `MainIndexKey`

10. Run

  ```sh
  make terraform-destroy
  ```  
  
  to remove any created resource.

### GitHub Actions

**Tasks**:

1. Add a step to run `terraform plan`.
2. Add another step such as, if the previous plan is successful, `terraform apply` would be run.
3. Add a step to destroy the resources that were created in the previous steps, by running `terraform destroy`, always, but only if the apply step was successful.
4. Run
  
    ```sh
    make pipeline
    ```

    to run GitHub Actions locally using `act`. Note `act` runs inside docker, thus you should use the endpoint `"http://localstack:4566"` instead of `"http://localhost:4566"`.

5. Add steps to save and consume the backend configuration state (`terraform.tfstate`) to a custom S3 bucket and a lock state to a dynamo table (check the `terraform/backend.tf` file). Prepare the bucket by running:

    ```sh
    make backend
    ```

    **Note**: the bucket name should be `tfstate`; the table name should be `tfstate`, which uses the key `LockID` to save the lock data.

6. Capture important information regarding the GitHub Actions job and save it to a `gha_logs` dynamo table using AWS CLI configured for localstack (you can find hints [here](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)); prepare the table by running:

    ```sh
    make gha-logs-table
    ```

7. Try to capture part of the data to be saved on the previous step from the running service (this is available from within the `act` container on a `docker` network context URL: `http://workshop:80/logs`)