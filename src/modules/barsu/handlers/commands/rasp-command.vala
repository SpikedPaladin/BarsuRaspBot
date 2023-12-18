using DataStore;
using Telegram;

namespace Barsu {
    
    public async void rasp_command(Message msg) {
        var args = msg.get_command_arguments();
        
        var date = (msg.is_command() && msg.get_command_name().has_suffix("next") || msg.text == "🗓️ След. неделя") ? get_next_week() : get_current_week();
        string? group = null;
        
        if (msg.chat.type != Chat.Type.PRIVATE)
            group = data.get_chat_group(msg.chat.id) ?? data.get_group(msg.from.id);
        else
            group = data.get_group(msg.from.id);
        
        if (args != null)
            group = data.parse_group(args);
        
        var str_date = date.format("%F");
        
        if (group != null)
            yield send_timetable_keyboard(group, str_date, msg.chat.id);
        else if (data.get_post(msg.from.id) == UserPost.TEACHER)
            yield send_teacher_keyboard(data.get_config(msg.from.id).name, str_date, msg.chat.id);
        else if (msg.chat.type == Chat.Type.PRIVATE)
            yield send_group_warning(msg.chat.id, msg.from.id);
        else
            yield send_group_error("rasp", msg.chat.id);
    }
}