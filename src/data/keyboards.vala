using Telegram;

namespace Keyboards {
    public static InlineKeyboardMarkup cancel_keyboard;
    public static InlineKeyboardMarkup enable_sub_keyboard;
    public static InlineKeyboardMarkup disable_sub_keyboard;
    
    public static ReplyKeyboardMarkup post_keyboard;
    
    public static void load() {
        cancel_keyboard = new InlineKeyboardMarkup()
            .add_button(new InlineKeyboardButton() { text = "Отмена", callback_data = "cancel" });
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
    }
    
    public static ReplyKeyboardMarkup department_keyboard() {
        var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
        
        keyboard.add_button(new KeyboardButton() { text = "Без кафедры" })
                .new_row()
                .add_button(new KeyboardButton() { text = "БУХ" })
                .add_button(new KeyboardButton() { text = "ГиУПД" })
                .add_button(new KeyboardButton() { text = "ДиНО" })
                .add_button(new KeyboardButton() { text = "ЕНД" })
                .new_row()
                .add_button(new KeyboardButton() { text = "ИТиФМД" })
                .add_button(new KeyboardButton() { text = "ОПДиГУ" })
                .add_button(new KeyboardButton() { text = "ПИП" })
                .add_button(new KeyboardButton() { text = "ПиСГД" })
                .new_row()
                .add_button(new KeyboardButton() { text = "ПиФВ" })
                .add_button(new KeyboardButton() { text = "ТиПЭ" })
                .add_button(new KeyboardButton() { text = "ТОМ" })
                .add_button(new KeyboardButton() { text = "ТОСПиА" })
                .new_row()
                .add_button(new KeyboardButton() { text = "ТПГЯ" })
                .add_button(new KeyboardButton() { text = "Филол" })
                .new_row()
                .add_button(new KeyboardButton() { text = "Заново" });
        
        return keyboard;
    }
}
