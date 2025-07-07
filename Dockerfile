# --- STAGE 1: Build the Angular application ---
# Use a Node.js image with Alpine Linux for a smaller base
FROM node:20-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker caching
# This ensures that npm install is only re-run if dependencies change
COPY package.json package-lock.json ./

# Install npm dependencies
RUN npm install

# Copy the rest of the Angular application source code
COPY . .

# Build the Angular application for production
# Replace 'your-app-name' with the actual output folder name found in angular.json
# (usually 'dist/<your-project-name>')
RUN npm run build --configuration=production

# --- STAGE 2: Serve the application with Nginx ---
# Use a lightweight Nginx image
FROM nginx:alpine

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the compiled Angular application from the 'build' stage to Nginx's HTML directory
# IMPORTANT: Adjust 'dist/your-app-name' to match your Angular project's output path.
# This path is usually 'dist/<your-project-name>' in newer Angular CLI versions.
# You can find the actual output path in your angular.json file under "outputPath".
COPY --from=build /app/dist/my-angular-app/browser /usr/share/nginx/html

# Expose port 80, which Nginx listens on
EXPOSE 80

# Command to start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
