# Use the official Node.js image as the base image
FROM node:20.18-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json into the container
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Build the Next.js application
RUN npm run build

# Use a smaller base image for the final stage
FROM node:20.18-alpine AS runner

# Set the working directory in the container
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.mjs ./next.config.mjs

# Install only production dependencies
RUN npm install --production

# Expose port 3000
EXPOSE 3000

# Command to run the Next.js application
CMD ["npm", "start"]