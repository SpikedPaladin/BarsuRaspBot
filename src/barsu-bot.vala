using BarsuTimetable;
using Telegram;
using Gee;

public class BarsuRaspBot : Bot {
    public HashMap<string, string> users_map = new HashMap<string, string>();
    
    public override bool on_my_chat_member(ChatMemberUpdated chat_member) {
        if (chat_member.new_chat_member is ChatMemberBanned || chat_member.new_chat_member is ChatMemberLeft) {
            if (chat_member.chat.type == Chat.Type.PRIVATE)
                config_manager.remove_config(chat_member.from.id, false);
            else
                config_manager.remove_config(chat_member.from.id, true);
        }
        return true;
    }
    
    public override bool on_chosen_inline_result(ChosenInlineResult result) {
        if (result.result_id.has_prefix("week"))
            GLib.message(result.result_id);
        
        return true;
    }
}
