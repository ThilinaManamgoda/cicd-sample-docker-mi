FROM maven:3.3.9-jdk-8 AS builder

# Cache maven dependencies
ENV MAVEN_OPTS="-Dmaven.repo.local=/root/m2repo/"
COPY helloworld/pom.xml /usr/src/mymaven/helloworld/
RUN mvn -f /usr/src/mymaven/helloworld/pom.xml dependency:go-offline -B

COPY helloworld /usr/src/mymaven/helloworld
COPY helloworldCompositeApplication /usr/src/mymaven/helloworldCompositeApplication
RUN mvn -f /usr/src/mymaven/helloworld/pom.xml clean install -Dmaven.test.skip=true
RUN mvn -f /usr/src/mymaven/helloworldCompositeApplication/pom.xml clean install -Dmaven.test.skip=true

FROM gcr.io/research-n-development-209206/wso2mi:1.2.0
COPY --from=builder /usr/src/mymaven/helloworldCompositeApplication/target/helloworldCompositeApplication_1.0.0.car ${WSO2_SERVER_HOME}/repository/deployment/server/carbonapps
