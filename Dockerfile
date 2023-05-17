# Use a base image with Node.js pre-installed
FROM --platform=arm64 node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port that the Nest.js application runs on
EXPOSE 3000

# Run the Nest.js application
CMD [ "npm", "run", "start:prod" ]
