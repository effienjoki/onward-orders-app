# Stage 1: compile the app. Needs the full JDK.
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /build
COPY src/OrderApp.java .
RUN javac OrderApp.java

# Stage 2: run the app. JRE only, small Alpine base, non root user.
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /build/*.class ./
RUN addgroup -S onward && adduser -S onward -G onward
USER onward

# Version label, set by the pipeline. Last, because it changes on every build (layer cache).
ARG APP_VERSION=local
ENV APP_VERSION=${APP_VERSION}

EXPOSE 8080
CMD ["java", "-cp", "/app", "OrderApp"]