localstack-up:
	docker compose -f localstack/docker-compose.yaml up -d

localstack-down:
	@docker stop workshop && echo "Service stopped" || echo "Service not running"
	@docker rm workshop && echo "Service removed" || echo "Service does not exist"
	docker compose -f localstack/docker-compose.yaml down

service:
	docker-buildx build -t workshop-service-image:latest -f services/docker/Dockerfile .
	@docker stop workshop && echo "Service stopped" || echo "Service not running"
	@docker rm workshop && echo "Service removed" || echo "Service does not exist"
	docker run -p 8088:80 --name workshop --network localstack_local -d workshop-service-image

terraform-init:
	@rm -drf ./terraform/.terraform
	@rm -f ./terraform/.terraform.lock.hcl
	@cd terraform && terraform init || echo "Failed terraform init"

terraform-plan:
	@cd terraform && terraform plan || echo "Failed terraform plan"

terraform-apply:
	@cd terraform && terraform apply -auto-approve || echo "Failed terraform apply"

terraform-destroy:
	@cd terraform && terraform destroy -auto-approve || echo "Failed terraform destroy"

backend:
	@awslocal s3 mb s3://tfstate --region us-east-1
	@awslocal dynamodb create-table \
		--table-name tfstate \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
		--region us-east-1 \
		&& echo "Backend persistence created" || echo "Failed to create backend"
	
gha-logs-table:
	@awslocal dynamodb create-table \
		--table-name gha_logs \
		--attribute-definitions AttributeName=TimeStamp,AttributeType=S \
		--key-schema AttributeName=TimeStamp,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
		--region us-east-1 \
		&& echo "GHA Logs Table created" || echo "Failed to create GHA Logs Table"

pipeline:
	act --network localstack_local