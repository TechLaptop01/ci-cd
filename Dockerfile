# Use a base image with Flutter already installed
FROM ubuntu:20.04 AS base

# Set the timezone non-interactively to UTC
ENV TZ=UTC

RUN apt-get update \
    && apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 \
    && apt-get clean

# Clone Flutter SDK if not already present
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter || true

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Switch to a builder stage to build the Flutter application
FROM base AS builder

# Create a directory for the application code
WORKDIR /app/

# Copy only the pubspec.yaml to install dependencies
COPY pubspec.yaml .

# Install Flutter dependencies
RUN flutter pub get

# Copy the entire application code
COPY . .

# Build the Flutter web application
RUN flutter build web

# Final stage for the production image
FROM base AS production

# Copy the built application from the builder stage
COPY --from=builder /app/build/web/ /app/

# Expose port 8080
EXPOSE 8080

# Make server startup script executable and start the web server
RUN ["chmod", "+x", "/app/server/server.sh"]

ENTRYPOINT [ "/app/server/server.sh"]



## Previous docker file
## Install Operating system and dependencies
#FROM ubuntu:20.04
#
#
#RUN apt-get update
#RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3
#RUN apt-get clean
#
## download Flutter SDK from Flutter Github repo
#RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
#
## Set flutter environment path
#ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
#
## Run flutter doctor
##RUN flutter doctor
#
## Enable flutter web
##RUN flutter channel master
##RUN flutter upgrade
##RUN flutter config --enable-web
#
## Copy files to container and build
#RUN mkdir /app/
#COPY . /app/
#WORKDIR /app/
#RUN flutter build web
##RUN flutter run -d web
## Record the exposed port
#EXPOSE 8080
#
## make server startup script executable and start the web server
#RUN ["chmod", "+x", "/app/server/server.sh"]
#
#ENTRYPOINT [ "/app/server/server.sh"]