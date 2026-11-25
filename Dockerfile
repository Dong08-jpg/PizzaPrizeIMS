FROM eclipse-temurin:21-jdk
WORKDIR /app

COPY src ./src
COPY web ./web
COPY data ./data

RUN mkdir -p out && javac -encoding UTF-8 -d out $(find src -name "*.java")

EXPOSE 10000
CMD ["sh", "-c", "java -cp out com.pizzaprize.Main ${PORT:-8080}"]
