using Telegram;

namespace Keyboards {
    public static InlineKeyboardMarkup owner_keyboard;
    public static InlineKeyboardMarkup cancel_keyboard;
    public static InlineKeyboardMarkup open_bot_keyboard;
    public static InlineKeyboardMarkup enable_sub_keyboard;
    public static InlineKeyboardMarkup disable_sub_keyboard;
    
    public static ReplyKeyboardMarkup main_keyboard;
    public static ReplyKeyboardMarkup post_keyboard;
    
    public static void load() {
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
        enable_sub_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Вкл. уведомления", callback_data = "enable_sub" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "Изменить группу", callback_data = "change_group" });
        disable_sub_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Выкл. уведомления", callback_data = "disable_sub" }).new_row()
            .add_button(new InlineKeyboardButton() { text = "Изменить группу", callback_data = "change_group" });
        
        post_keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true }
            .add_button(new KeyboardButton() { text = "🧑‍🎓️ Студент" })
            .new_row()
            .add_button(new KeyboardButton() { text = "🧑‍🏫️ Преподаватель" });
        
        main_keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true }
            .add_button(new KeyboardButton() { text = "▶️ Сегодня" })
            .add_button(new KeyboardButton() { text = "⏭️ Завтра" })
            .new_row()
            .add_button(new KeyboardButton() { text = "⏩️ След. пара" })
            .add_button(new KeyboardButton() { text = "🗓️ Выбрать день" })
            .new_row()
            .add_button(new KeyboardButton() { text = "🖼️ Вся неделя" })
            .new_row()
            .add_button(new KeyboardButton() { text = "🔔️ Звонки" })
            .add_button(new KeyboardButton() { text = "🚍️ Автобусы" })
            .add_button(new KeyboardButton() { text = "⚙️ Настройки" });
    }
}
