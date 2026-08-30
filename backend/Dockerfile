# syntax=docker/dockerfile:1

# =============================================================================
# OS base — shared by every stage below. Disables Debian's default apt
# cleanup hook so the cache mounts further down actually persist anything
# across builds (without this, docker-clean wipes /var/cache/apt right
# after every install, cache mount or not).
# =============================================================================
FROM ruby:3.4-slim-bookworm AS os-base

RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# =============================================================================
# Build base — OS packages shared by development and the production builder
# =============================================================================
FROM os-base AS build-base

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    DEBIAN_FRONTEND=noninteractive

# build-essential + libpq-dev: required to compile native gems (pg, etc.)
# Installed once here instead of separately in development and builder.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential libpq-dev git curl libyaml-dev

WORKDIR /app

# =============================================================================
# Development — gems baked into /usr/local/bundle; app code is volume-mounted
# =============================================================================
FROM build-base AS development

ENV RAILS_ENV=development

# postgresql-client is dev/debugging-only, so it's kept out of build-base
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends postgresql-client

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY --chmod=755 docker-entrypoint.dev.sh /usr/local/bin/docker-entrypoint

# App code is volume-mounted in compose — only copy what's needed for a standalone image
COPY config/ config/
COPY swagger/ swagger/
COPY bin/ bin/
COPY lib/ lib/
COPY app/ app/
COPY db/ db/
COPY Rakefile config.ru .ruby-version ./

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# =============================================================================
# Production builder
# =============================================================================
FROM build-base AS builder

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment true && \
    bundle config set --local without "development test" && \
    bundle install && \
    bundle clean --force

COPY . .

# =============================================================================
# Production runtime
# =============================================================================
FROM os-base AS production

ENV BUNDLE_PATH=/usr/local/bundle \
    RAILS_ENV=production \
    DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends libpq5 curl

RUN groupadd --system --gid 1001 rails && \
    useradd --system --uid 1001 --gid rails rails

WORKDIR /app

COPY --from=builder --chown=rails:rails /app /app
COPY --from=builder --chown=rails:rails /usr/local/bundle /usr/local/bundle

USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]