# ---- build stage ----
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

# Generate code before building
RUN dart run build_runner build --delete-conflicting-outputs

RUN flutter build web --release

# ---- runtime stage ----
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
