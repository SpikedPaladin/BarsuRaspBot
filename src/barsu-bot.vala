using BarsuTimetable;
using DataStore;
using Telegram;
using Gee;

public class BarsuRaspBot : Bot {
    
    public override bool on_my_chat_member(ChatMemberUpdated chat_member) {
        if (chat_member.new_chat_member is ChatMemberBanned || chat_member.new_chat_member is ChatMemberLeft) {
            if (chat_member.chat.type == Chat.Type.PRIVATE)
                data.remove_config(chat_member.from.id);
            else
                data.remove_config(chat_member.from.id, true);
        }
        return true;
    }
    
    public override bool on_chosen_inline_result(ChosenInlineResult result) {
        if (result.result_id.has_prefix("week"))
            GLib.message(result.result_id);
        
        return true;
    }
}
