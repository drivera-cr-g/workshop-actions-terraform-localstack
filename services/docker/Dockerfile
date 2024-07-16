# Slim image for python 3.12
FROM python:3.12-slim

# Copy the requirements
ADD services/docker/app/requirements.txt .

# Install the requirements
RUN pip --no-cache-dir install -r requirements.txt

# Copy the service code
ADD services/docker/app/ /app

# Service entrypoint
ENTRYPOINT [ "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80" ]

