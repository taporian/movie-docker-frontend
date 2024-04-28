# Dockerized MERN Stack Application Documentation

## Overview

This documentation outlines the process of Dockerizing a MERN stack application. The Dockerfiles included in the project are designed to containerize the backend (Node.js with MongoDB) and frontend (React.js with Nginx).

## Approach

### Backend Dockerfile

The backend Dockerfile uses the official Node.js version 18 as the base image. It sets the working directory, copies the package.json files, installs dependencies, copies the application code, exposes port 3002 and defines a health check using curl.

```dockerfile
FROM node:18

WORKDIR /backend

COPY package*.json ./

RUN npm install

COPY . .

ENV PORT=3002

EXPOSE 3002

HEALTHCHECK CMD curl --fail http://localhost:3200 || exit 1

CMD ["npm","start"]
```

### MongoDB Dockerfile

For the MongoDB service, the Dockerfile utilizes the official MongoDB version 5.0.3 image. It copies an initialization script for database setup during container startup for default values.

```dockerfile
FROM mongo:5.0.3

COPY init.js /docker-entrypoint-initdb.d/
```

### Frontend Dockerfile

The frontend Dockerfile uses Node.js version 16.1.0 in a multi-stage build approach due to deprecated dependencies. It installs dependencies, builds the React app for production, and then uses Nginx as the production server.

```dockerfile
# Use the official Node.js runtime as the base image
FROM node:16.1.0 as build

# Set the working directory in the container
WORKDIR /frontend

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the entire application code to the container
COPY . .

# Build the React app for production
RUN npm run build

# Use Nginx as the production server
FROM nginx:alpine

# Remove the default Nginx configuration file
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built React app to Nginx's web server directory
COPY --from=build /frontend/build /usr/share/nginx/html

# Expose port 80 for the Nginx server
EXPOSE 80

# Start Nginx when the container runs
CMD ["nginx", "-g", "daemon off;"]
```

## Challenges Faced

1. Deprecated Dependencies: Managed conflicting node versions required for React and Node.js.
2. Nginx Routing: Initially encountered 404 errors due to misconfiguration in nginx.conf file, Commenting out the line include /etc/nginx/conf.d/\*.conf; in nginx.conf resolved conflicts by ensuring only the custom Nginx configuration was used, eliminating the 404 errors.
3. Path Configuration: Ensured accurate paths and configurations in Docker Compose file to avoid path-related issues.
4. Volume Setup Challenges: struggled with setting up volumes in Docker Compose as I didn't realize the need to explicitly mount the volume.

## Setup

### Backend Setup

1. Navigate to the backend directory.
2. Create an .env file with necessary environment variables (for the purpose of this task the env is availabe on the github repo).
3. Run the following command to start the backend service:

```bash
docker-compose --env-file .env up
```

### Frontend Setup

1. Navigate to the frontend directory.
2. Run the following command to start the frontend service:

```
docker-compose up
```

## Benefits of Dockerization

By Dockerizing the MERN stack application, the following benefits are achieved:

- **Consistency**: Ensures consistent development and production environments.
- **Dependency Management**: Simplifies handling of dependencies and libraries.
- **Isolation**: Provides isolation for each component, enhancing security.
- **Portability**: Facilitates easy deployment across different environments.
- **Efficiency**: Improves development cycles and collaboration.
- **Scalability**: Enables seamless scaling using container orchestration tools.

## Dockerignore

A .dockerignore file is used to ignore the node_modules directory during Docker builds. This is important to avoid unnecessarily copying large amount of files into the Docker image.
