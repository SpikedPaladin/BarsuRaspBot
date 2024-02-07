using DataStore;
using Telegram;

namespace Barsu {
    
    public async void next_command(Message msg) {
        var args = msg.get_command_arguments();
        
        string? group = null;
        
        if (msg.chat.type != Chat.Type.PRIVATE)
            group = get_chat_config(msg.chat.id).group ?? get_config(msg.from.id).group;
        else
            group = get_config(msg.from.id).group;
        
        if (args != null)
            group = data.parse_group(args);
        
        if (group != null)
            yield send_next_lesson(group, msg.chat.id);
        else if (get_config(msg.from.id).post == UserPost.TEACHER)
            yield send_next_teacher(get_config(msg.from.id).name, msg.chat.id);
        else if (msg.chat.type == Chat.Type.PRIVATE)
            yield send_group_warning(msg.chat.id, msg.from.id);
        else
            yield send_group_error("next", msg.chat.id);
    }
}