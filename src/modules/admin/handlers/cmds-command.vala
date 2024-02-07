using Telegram;

namespace Admin {
    
    public async void cmds_command(Message msg) {
        var day = new BotCommand() {
            command = Commands.day(),
            description = Strings.day_desc()
        };
        var tomorrow = new BotCommand() {
            command = Commands.tomorrow(),
            description = Strings.tomorrow_desc()
        };
        var rasp = new BotCommand() {
            command = "rasp",
            description = Strings.rasp_desc()
        };
        var raspnext = new BotCommand() {
            command = "raspnext",
            description = Strings.raspnext_desc()
        };
        var next = new BotCommand() {
            command = "next",
            description = "Следующая пара"
        };
        var bells = new BotCommand() {
            command = "bells",
            description = "Звонки"
        };
        var bus = new BotCommand() {
            command = "bus",
            description = "Ближайшие автобусы"
        };
        var settings = new BotCommand() {
            command = "settings",
            description = "Настройки"
        };
        var help = new BotCommand() {
            command = "help",
            description = "Показать помощь"
        };
        var apk = new BotCommand() {
            command = "apk",
            description = "Приложение для расписания"
        };
        
        yield bot.send(new SetMyCommands() {
            commands = { day, tomorrow, rasp, raspnext, next, bells, bus, help, apk },
            scope = new BotCommandScopeDefault()
        });
        yield bot.send(new SetMyCommands() {
            commands = { day, tomorrow, rasp, raspnext, next, bells, bus, settings, help, apk },
            scope = new BotCommandScopeAllPrivateChats()
        });
        yield bot.send(new SetMyCommands() {
            commands = { day, tomorrow, rasp, raspnext, next, bells, bus, settings, help, apk },
            scope = new BotCommandScopeAllChatAdministrators()
        });
    }
}