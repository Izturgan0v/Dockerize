# syntax=docker/dockerfile:1

# Этап сборки
FROM golang:1.24.3-alpine AS builder

WORKDIR /app

# Копируем go.mod для кэширования зависимостей
COPY go.mod ./
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем бинарник для Linux (для Docker контейнера)
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ascii-art-web main.go

# Финальный образ
FROM alpine:latest

LABEL maintainer="Ваше Имя <ваш.email@example.com>"
LABEL org.opencontainers.image.source="https://github.com/yourusername/ascii-art-web-dockerize"
LABEL project.ascii-art-web.version="1.0"
LABEL org.opencontainers.image.title="ascii-art-web"
LABEL org.opencontainers.image.description="web-приложение для генерации ASCII-арта на Go"

RUN apk add bash

WORKDIR /app

# Копируем бинарник и необходимые файлы
COPY --from=builder /app/ascii-art-web .
COPY asciiart/banners ./asciiart/banners
COPY web ./web

# Открываем порт
EXPOSE 8080

# Запускаем приложение
CMD ["./ascii-art-web"] 