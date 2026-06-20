# --- Stage 1: build the jar -------------------------------------------------
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Copy only what's needed to resolve dependencies first.
# This layer only re-runs when pom.xml changes, not on every code edit.
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN ./mvnw dependency:go-offline -B

COPY src ./src
RUN ./mvnw clean package -DskipTests

# --- Stage 2: run it in a minimal JRE image ---------------------------------
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Don't run as root inside the container
RUN addgroup --system spring && adduser --system --ingroup spring spring
USER spring:spring

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health | grep -q '"status":"UP"' || exit 1

# JAVA_OPTS lets you tune heap size etc. at runtime without rebuilding,
# e.g. JAVA_OPTS="-Xmx512m -Xms256m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
