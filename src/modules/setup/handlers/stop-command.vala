using DataStore;
using Telegram;
using Barsu;

namespace Setup {
    
    public async void stop_command(Message msg) {
        data.remove_config(msg.from.id);
    }
}