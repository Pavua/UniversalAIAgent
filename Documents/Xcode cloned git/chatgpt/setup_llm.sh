#!/bin/bash

echo "=== Настройка LLM контейнеров ==="

# Запуск контейнеров
echo "Запуск LLM контейнеров..."
docker-compose up -d llama32-main llama32-test llama32-exp

# Ожидание запуска
echo "Ожидание запуска контейнеров..."
sleep 10

# Загрузка моделей в каждый контейнер
echo "Загрузка llama3.2 в основной контейнер..."
docker exec llama32-main ollama pull llama3.2

echo "Загрузка llama3.2 в тестовый контейнер..."
docker exec llama32-test ollama pull llama3.2

echo "Загрузка llama3.2 в экспериментальный контейнер..."
docker exec llama32-exp ollama pull llama3.2

# Проверка статуса
echo "Проверка статуса LLM контейнеров..."
for port in 11434 11435 11436; do
    echo "Проверка порта $port..."
    curl -s http://localhost:$port/api/tags | jq '.models[].name' || echo "Контейнер на порту $port не готов"
done

echo "=== Настройка завершена ==="
echo "Доступные LLM эндпоинты:"
echo "- Основной: http://localhost:11434"
echo "- Тестовый: http://localhost:11435" 
echo "- Экспериментальный: http://localhost:11436"
echo ""
echo "Для тестирования используйте:"
echo "curl -X POST http://localhost:11434/api/generate -d '{\"model\":\"llama3.2\",\"prompt\":\"Hello\"}'"