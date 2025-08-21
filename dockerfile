# syntax=docker/dockerfile:1

# Этап сборки
FROM golang:1.24.2-alpine AS builder

WORKDIR /app

# Копируем go.mod для кэширования зависимостей
COPY go.mod ./
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем бинарник для Linux
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ascii-art-web main.go

# Финальный образ
FROM alpine:latest

LABEL maintainer="Ваше Имя <ваш.email@example.com>"
LABEL org.opencontainers.image.source="https://github.com/yourusername/ascii-art-web-dockerize"
LABEL project.ascii-art-web.version="1.0"
LABEL org.opencontainers.image.title="ascii-art-web"
LABEL org.opencontainers.image.description="web-приложение для генерации ASCII-арта на Go"

WORKDIR /app

# Копируем бинарник и необходимые папки
COPY --from=builder /app/ascii-art-web .
COPY ascii-art/banner ./ascii-art/banner
COPY ascii-art/utils ./ascii-art/utils
COPY templates ./templates
COPY styles ./styles

# Открываем порт
EXPOSE 8080

# Запускаем приложение
CMD ["./ascii-art-web"]
