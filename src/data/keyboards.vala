using Telegram;

namespace Keyboards {
    public static InlineKeyboardMarkup apk_keyboard;
    public static InlineKeyboardMarkup start_keyboard;
    public static InlineKeyboardMarkup owner_keyboard;
    public static InlineKeyboardMarkup cancel_keyboard;
    public static InlineKeyboardMarkup fast_bus_keyboard;
    public static InlineKeyboardMarkup open_bot_keyboard;
    public static InlineKeyboardMarkup enable_sub_keyboard;
    public static InlineKeyboardMarkup disable_sub_keyboard;
    
    public static ReplyKeyboardMarkup main_keyboard;
    public static ReplyKeyboardMarkup post_keyboard;
    
    public static void load() {
        apk_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Скачать", url = "https://play.google.com/store/apps/details?id=me.paladin.barsurasp" })
            .new_row()
            .add_button(new InlineKeyboardButton() { text = "У меня нет Google Play!", callback_data = "get_apk" });
        start_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Выбрать группу/преподавателя", callback_data = "change_group" });
        cancel_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Отмена", callback_data = "cancel" });
        owner_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Установить", callback_data = "install" })
            .new_row()
            .add_button(new InlineKeyboardButton() { text = "Отмена", callback_data = "cancel" })
            .new_row()
            .add_button(new InlineKeyboardButton() { text = "Выбрать другую", url = "t.me/BarsuRaspBot" });
        open_bot_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Отмена", callback_data = "cancel" })
            .new_row()
            .add_button(new InlineKeyboardButton() { text = "Выбрать группу", url = "t.me/BarsuRaspBot" });
        fast_bus_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Уборевича ➡️ Университет", callback_data = "busfasttest:from_sweethome" })
            .new_row()
            .add_button(new InlineKeyboardButton() { text = "Университет ➡️ Уборевича", callback_data = "busfasttest:to_sweethome" })
            .new_row()
            .add_button(new InlineKeyboardButton() { text = "Выбрать номер", callback_data = "busfasttest:choose" });
        enable_sub_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Вкл. уведомления", callback_data = "enable_sub" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "Изменить группу", callback_data = "change_group" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "Изменить тему", callback_data = "change_theme" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "🔥️ Приложение для Android", callback_data = "get_app" });
        disable_sub_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Выкл. уведомления", callback_data = "disable_sub" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "Изменить группу", callback_data = "change_group" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "Изменить тему", callback_data = "change_theme" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "🔥️ Приложение для Android", callback_data = "get_app" });
        
        post_keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true }
            .add_button(new KeyboardButton() { text = "🧑‍🎓️ Студент" })
            .new_row()
            .add_button(new KeyboardButton() { text = "🧑‍🏫️ Преподаватель" });
        
        main_keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true }
            .add_button(new KeyboardButton() { text = "▶️ Сегодня" })
            .add_button(new KeyboardButton() { text = "⏭️ Завтра" })
            .add_button(new KeyboardButton() { text = "⏩️ След. пара" })
            .new_row()
            .add_button(new KeyboardButton() { text = "🗓️ Эта неделя" })
            .add_button(new KeyboardButton() { text = "🗓️ След. неделя" })
            .new_row()
            .add_button(new KeyboardButton() { text = "🔔️ Звонки" })
            .add_button(new KeyboardButton() { text = "🚍️ Автобусы" })
            .add_button(new KeyboardButton() { text = "⚙️ Настройки" });
    }
}
