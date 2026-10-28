FROM node:22-alpine AS base
WORKDIR /app

FROM base AS development
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

FROM base AS build
# Baked into the client bundle at build time. Override via compose build.args.
ARG NEXT_PUBLIC_API_URL=https://api.tafakkur.org/api/v1
ARG NEXT_PUBLIC_APP_URL=https://lms.tafakkur.org
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN if [ -z "$NEXT_PUBLIC_API_URL" ] || echo "$NEXT_PUBLIC_API_URL" | grep -qiE 'localhost|127\.0\.0\.1'; then \
        echo "ERROR: NEXT_PUBLIC_API_URL must be a public API URL (got: '${NEXT_PUBLIC_API_URL:-empty}')" >&2; \
        exit 1; \
    fi
RUN npm run build

FROM base AS production
ENV NODE_ENV=production
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
EXPOSE 3000
CMD ["npm", "run", "start"]
