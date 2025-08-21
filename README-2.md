# 🚀 Dockerизация проекта ascii-art-web

Этот проект демонстрирует, как упаковать веб-приложение на **Go** в Docker-контейнер.  
Здесь вы найдёте пошаговое объяснение `Dockerfile`, зачем нужны метаданные, как правильно собирать образы, запускать контейнеры и очищать "мусор".

---

## 📂 Структура проекта

```
ascii-art-web/
│── ascii-art/          # Логика приложения (баннеры, утилиты)
│── styles/             # CSS-стили
│── templates/          # HTML-шаблоны
│── main.go             # Веб-сервер на Go
│── Dockerfile          # Файл описания образа
│── .dockerignore       # Исключённые файлы из контекста
```

---

## 🐳 Dockerfile (разбор по шагам)

```dockerfile
# 1. Используем официальный образ Go для сборки
FROM golang:1.24.2-alpine AS builder

# 2. Создаём рабочую директорию внутри контейнера
WORKDIR /app

# 3. Копируем только go.mod (ускоряет сборку, т.к. зависимости кешируются)
COPY go.mod ./

# 4. Загружаем зависимости
RUN go mod download

# 5. Копируем всё приложение внутрь контейнера
COPY . .

# 6. Собираем бинарник (CGO отключён для кроссплатформенности)
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o ascii-art-web main.go

# ==================
# Финальный образ
# ==================
FROM alpine:latest

# Добавляем метаданные
LABEL maintainer="Ваше Имя <ваш.email@example.com>"
LABEL org.opencontainers.image.source="https://github.com/yourusername/ascii-art-web-dockerize"
LABEL project.ascii-art-web.version="1.0"
LABEL org.opencontainers.image.title="ascii-art-web"
LABEL org.opencontainers.image.description="web-приложение для генерации ASCII-арта на Go"

# Создаём рабочую директорию (второй WORKDIR уже в финальном образе)
WORKDIR /app

# Копируем бинарник из builder-образа
COPY --from=builder /app/ascii-art-web .

# Копируем ресурсы (HTML, стили, баннеры)
COPY templates ./templates
COPY styles ./styles
COPY ascii-art ./ascii-art

# Открываем порт
EXPOSE 8080

# Запускаем приложение
CMD ["./ascii-art-web"]
```

---

## ❓ Почему повторяется `WORKDIR /app`

- Первый `WORKDIR /app` — в **builder-образе** (на Go).  
  Здесь идёт сборка исходников и компиляция бинарника.

- Второй `WORKDIR /app` — в **финальном образе** (на Alpine).  
  Здесь запускается готовое приложение.

Это разделение позволяет делать контейнер **маленьким и быстрым**.

---

## 🏷️ Метаданные (LABEL)

Мы добавили следующие метки:

```dockerfile
LABEL maintainer="Ваше Имя <ваш.email@example.com>"
LABEL org.opencontainers.image.source="https://github.com/yourusername/ascii-art-web-dockerize"
LABEL project.ascii-art-web.version="1.0"
LABEL org.opencontainers.image.title="ascii-art-web"
LABEL org.opencontainers.image.description="web-приложение для генерации ASCII-арта на Go"
```

Зачем они нужны?  
- 📌 `maintainer` — кто отвечает за проект.  
- 📌 `source` — откуда взять исходники.  
- 📌 `version` — версия проекта.  
- 📌 `title` — имя проекта.  
- 📌 `description` — краткое описание.

Эти данные помогают в **поддержке, поиске и документации**.

---

## 📦 Как собрать образ

Из корня проекта (где лежит Dockerfile):

```bash
docker build -t ascii-art-web .
```

---

## 🛠️ Как запустить контейнер

```bash
docker run -d -p 8080:8080 --name ascii-container ascii-art-web
```

Теперь приложение доступно по адресу:  
👉 http://localhost:8080

---

## 🧹 Как удалять мусор (garbage collection)

После экспериментов остаются **неиспользуемые образы, контейнеры и тома**.  
Очищаем всё ненужное:

```bash
# Удалить остановленные контейнеры
docker container prune -f

# Удалить неиспользуемые образы
docker image prune -a -f

# Удалить неиспользуемые тома
docker volume prune -f

# Удалить всё сразу (опасно!)
docker system prune -a -f
```

---

## 📌 .dockerignore

В проекте есть файл `.dockerignore`, он исключает ненужные файлы:

```txt
# Исключаем временные и служебные файлы
.git
.gitignore
*.md
*.log
*.tmp
*.swp
*.swo
*.DS_Store
node_modules
.idea
.vscode

# Исключаем тестовые и скриптовые файлы
Dockerfile
test_api.sh

# Исключаем Windows-специфичные файлы
*.bat
*.ps1
*.exe
Thumbs.db
desktop.ini
```

Это помогает сделать образ **меньше и чище**.

---

✅ Теперь ваш проект полностью готов для использования с Docker! 🚀
