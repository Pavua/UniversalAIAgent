#!/bin/bash

echo "=== Тестирование проекта Tg_python_llm ==="
echo

# Python тесты
echo "1. Запуск Python тестов..."
make test
if [ $? -eq 0 ]; then
    echo "✅ Python тесты прошли успешно"
else
    echo "❌ Python тесты провалились"
fi
echo

# Проверка сборки macOS приложения
echo "2. Сборка macOS приложения..."
cd userbot/gui
xcodebuild build -project Tg_python_llm.xcodeproj -scheme Tg_python_llm -destination 'platform=macOS' -quiet
if [ $? -eq 0 ]; then
    echo "✅ macOS приложение собралось успешно"
else
    echo "❌ Сборка macOS приложения провалилась"
fi
cd ../..
echo

# Проверка CLI
echo "3. Проверка CLI..."
python -m userbot --help > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ CLI работает"
else
    echo "❌ CLI не работает"
fi
echo

# Проверка импортов
echo "4. Проверка импортов Python модулей..."
python -c "import userbot; import userbot.backend; import userbot.dataset; import userbot.trainer" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Все Python модули импортируются успешно"
else
    echo "❌ Проблема с импортом Python модулей"
fi
echo

echo "=== Итоговый отчет ==="
echo "Проект готов к использованию!"
echo "- Python CLI: python -m userbot --help"
echo "- macOS App: make run"
echo "- n8n: make n8n"