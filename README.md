# Бот [Расписание БарГУ](https://t.me/BarsuRaspBot)
[![Telegram group badge](https://img.shields.io/badge/Telegram-Join_the_chat-2CA5E0?style=flat&logo=telegram)](https://t.me/BarsuChat)  
Бот с расписанием занятий университета БарГУ

## Функции
* Просмотр расписания занятий для учебных групп и преподавателей
* Выбор основной группы/преподавателя
* Быстрый поиск по группам/преподавателям
* Просмотр расписания автобусов
* Создание изображений с расписанием на неделю
* Цветовые темы для изображений

## Сборка и запуск
Бот создан на языке Vala с использованием библиотеки [TelegramGLib](https://github.com/SpikedPaladin/TelegramGLib)

### Зависимости
> telegram-glib-1.0  
> json-glib-1.0  
> libsoup-3.0  
> gxml-0.20  
> cairo

### Сборка
	$ meson setup build
	$ ninja -C build
Готовый исполняемый файл находится по пути `build/src`

### Запуск
Для запуска требуется только наличие `telegram-glib`, `gxml`, `cairo`

	$ ./barsu-rasp-bot
