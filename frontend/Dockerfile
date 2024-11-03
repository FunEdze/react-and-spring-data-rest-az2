# Stage 1: Build the React application
FROM node:16 as build

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy all other files
COPY . .

# Build the application
RUN npm run build

# Move the built files to a known location for NGINX to serve
RUN mkdir -p /app/build
RUN mv src/main/resources/static/built/* /app/build/ || echo "No build output found in /src/main/resources/static/built/."

# Stage 2: Serve the app with NGINX
FROM nginx:alpine

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy build artifacts from the previous stage
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
