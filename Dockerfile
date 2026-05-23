FROM debian:bookworm-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git unzip xz-utils libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone --branch stable --depth 1 \
    https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    flutter precache --web

WORKDIR /app
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get
COPY . .
RUN flutter gen-l10n
ARG API_BASE_URL=https://ooh-api.appstersolutions.com
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
