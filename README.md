# Django Base within a Docker Container

This document outlines how to set up a basic Django project within a Docker container using a named volume for development and deployment. This approach allows for persistent data and code updates without rebuilding the Docker image.

## Prerequisites

* Docker and Docker Compose installed.
    * Linux/Ubuntu: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
    * MacOS: [https://docs.docker.com/desktop/setup/install/mac-install/](https://docs.docker.com/desktop/setup/install/mac-install/)
    * Windows: [https://docs.docker.com/desktop/setup/install/windows-install/](https://docs.docker.com/desktop/setup/install/windows-install/)

## Project Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
└── requirements.txt
```

## Files

### 1. `Dockerfile`

```dockerfile
FROM python:latest

WORKDIR /app

COPY requirements.txt /app/
RUN pip install -r requirements.txt

RUN django-admin startproject my_project .  # Creates the Django project

COPY . /code # Copy project code to /code within the container

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh", "python", "manage.py", "runserver", "0.0.0.0:8000"]
```

### 2. `docker-compose.yml`

```yaml
version: "3.9"  # Or your preferred version

services:
  web:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - web_data:/app  # Mount the named volume to /app

volumes:
  web_data:  # Define the named volume
```

### 3. `entrypoint.sh`

```bash
#!/bin/bash

# Copy the code from /code to /app (the volume mount)
cp -r /code/* /app

# Run the original command (Django development server)
exec "$@"
```

### 4. `requirements.txt`

```
django==5.1.6  # Or your desired Django version
# Add other dependencies as needed
```

## Setup and Usage

1. **Create Project Files:** Create the files listed above in your project directory.  Make sure `entrypoint.sh` has execute permissions (`chmod +x entrypoint.sh`).

2. **Initialize Django Project:**  You can create a basic `my_project` structure beforehand locally and then copy that in.  Or you can let the Dockerfile create it for you.

3. **Build the Image:**

   ```bash
   docker compose build
   ```

4. **Run the Container:**

   ```bash
   docker compose up
   ```
or to run it detached:
```bash
docker compose up -d
```
5. **Access Django:** Open your web browser and go to `http://localhost:8000/`.

## Explanation

* **Dockerfile:**
    * Installs Python dependencies from `requirements.txt`.
    * Creates the initial Django project structure.
    * Copies your project code to `/code` inside the container.
    * Copies the `entrypoint.sh` script and makes it executable.
    * Sets the command to run the `entrypoint.sh` script, which then starts the Django development server.

* **docker-compose.yml:**
    * Defines the `web` service.
    * Builds the Docker image using the `Dockerfile`.
    * Maps port 8000 on your host machine to port 8000 in the container.
    * Creates and mounts a named volume called `web_data` to `/app` inside the container. This is crucial for persisting data and code changes.

* **entrypoint.sh:**
    * Copies the code from `/code` to `/app` (the named volume mount).  This ensures that your code is actually in the persistent volume.
    * Executes the command passed to it (which is the Django development server command).

* **requirements.txt:** Lists the Python packages required for your project.

## Key Advantages of this Approach

* **Persistent Data:** The named volume ensures that your database and other data are not lost when the container is stopped or removed.
* **Code Updates:** Changes you make to your code locally are immediately reflected in the container (after the initial copy), without needing to rebuild the image.
* **Clean Separation:** Your code is separated from the container's internal files, making it easier to manage and update.
* **Production-Ready:** This approach is much closer to how you would deploy a Django application in a production environment.

## Further Development

* **Database Configuration:** Configure your Django project to use a database (e.g., PostgreSQL, MySQL). You might want to use a separate Docker container for your database and link them together using Docker Compose.
* **Static Files:** Configure Django to serve static files (CSS, JavaScript, images).
* **Gunicorn/Nginx:** For production, replace the Django development server with Gunicorn (a WSGI HTTP server) and Nginx (a web server/reverse proxy).

This setup provides a solid foundation for developing and deploying Django applications using Docker.  Remember to adapt the `requirements.txt` and project structure to your specific needs.
