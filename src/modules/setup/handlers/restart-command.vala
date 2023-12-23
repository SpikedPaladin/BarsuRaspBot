using DataStore;
using Telegram;

namespace Setup {
    
    public async void restart_command(Message msg) {
        data.remove_config(msg.from.id);
        
        yield start(msg);
    }
}