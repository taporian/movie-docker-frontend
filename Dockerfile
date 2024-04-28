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
