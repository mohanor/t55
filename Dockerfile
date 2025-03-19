# Use official Node.js image
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the app's source code
COPY . .

# Build the Next.js application
RUN npm run build

# Use a lightweight Node.js runtime for production
FROM node:18-alpine AS runner
WORKDIR /app

# Copy built files from builder
COPY --from=builder /app/package.json .
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# Set environment variable
ENV NODE_ENV=production

# Expose the port Next.js runs on
EXPOSE 3000

# Start the Next.js server
# CMD ["npm", "run", "start"]
CMD ["next", "start", "-H", "0.0.0.0"]