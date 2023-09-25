using BarsuTimetable;
using DataStore;
using Telegram;

namespace Setup {
    
    public class SetupMessages {
        
        public async void post(Message msg) {
            if (msg.text.down().contains("преподаватель")) {
                data.set_state(msg.from.id, UserState.DEPARTMENT);
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    reply_markup = department_keyboard(),
                    text = "🕶️ Выберите свою кафедру"
                });
                
                return;
            }
            
            data.set_state(msg.from.id, UserState.FACULTY);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                reply_markup = faculty_keyboard(),
                text = "🕶️ Выбери свой факультет"
            });
        }
        
        public async void department(Message msg) {
            var department = group_manager.parse_department(msg.text);
            
            if (department == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Выберите кафедру через кнопки!"
                });
                
                return;
            }
            
            data.set_state(msg.from.id, UserState.NAME);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                reply_markup = name_keyboard(department),
                text = @"🧑‍🏫️ Теперь выберите преподавателя"
            });
        }
        
        public async void name(Message msg) {
            var name = group_manager.parse_name(msg.text);
            
            if (name == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Выберите преподавателя через кнопки!"
                });
                
                return;
            }
            var config = data.get_config(msg.from.id);
            config.name = name;
            
            if (config.post != null) {
                config.group = null;
                config.post = UserPost.TEACHER;
                data.set_state(msg.from.id, null);
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = @"🧑‍🏫️ Преподаватель изменён на *$(name)*",
                    reply_markup = Keyboards.main_keyboard
                });
                yield send_settings(msg.chat.id, msg.from.id);
                return;
            }
            
            config.post = UserPost.TEACHER;
            data.set_state(msg.from.id, null);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = Keyboards.main_keyboard,
                text = @"🧑‍🏫️ Вы выбрали преподавателя: *$name*\n" +
                        "Расписание для преподавателей находится в разработке\n" +
                        "Расписание на сегодня - /day\n" +
                        "Расписание на завтра - /tomorrow\n" +
                        "Выбрать день недели - /rasp\n" +
                        "Выбрать день след. недели - /raspnext\n" +
                        "Расписание звонков - /bells\n" +
                        "Показать помощь - /help\n\n" +
                        "⚙️ Изменить преподавателя или включить уведомления - /settings"
            });
        }
        
        public async void faculty(Message msg) {
            var faculty = group_manager.parse_faculty(msg.text);
            
            if (faculty == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Выбери факультет через кнопки!"
                });
                
                return;
            }
            
            data.set_state(msg.from.id, UserState.SPECIALITY);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                reply_markup = speciality_keyboard(faculty),
                text = @"🧠️ Теперь выбери специальность"
            });
        }
        
        public async void speciality(Message msg) {
            var speciality = group_manager.parse_speciality(msg.text);
            
            if (speciality == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Выбери специальность через кнопки!"
                });
                
                return;
            }
            
            data.set_state(msg.from.id, UserState.GROUP);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                reply_markup = group_keyboard(speciality),
                text = @"👥️ А теперь группу"
            });
        }
        
        public async void group(Message msg) {
            var group = group_manager.parse_group(msg.text);
            
            if (group == null) {
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    text = "Выбери группу через кнопки!"
                });
                
                return;
            }
            
            var config = data.get_config(msg.from.id);
            config.group = group;
            
            if (config.post != null) {
                config.name = null;
                config.post = UserPost.STUDENT;
                data.set_state(msg.from.id, null);
                
                yield bot.send(new SendMessage() {
                    chat_id = msg.chat.id,
                    parse_mode = ParseMode.MARKDOWN,
                    text = @"👥️ Группа изменена на *$(group)*",
                    reply_markup = Keyboards.main_keyboard
                });
                yield send_settings(msg.chat.id, msg.from.id);
                return;
            }
            
            config.post = UserPost.STUDENT;
            data.set_state(msg.from.id, null);
            yield bot.send(new SendMessage() {
                chat_id = msg.chat.id,
                parse_mode = ParseMode.MARKDOWN,
                reply_markup = Keyboards.main_keyboard,
                text = @"👥️ Ты выбрал группу: *$(group)*\n\n" +
                       "Расписание на сегодня - /day\n" +
                       "Расписание на завтра - /tomorrow\n" +
                       "Выбрать день недели - /rasp\n" +
                       "Выбрать день след. недели - /raspnext\n" +
                       "Расписание на эту неделю - /week\n" +
                       "Расписание на след. неделю - /weeknext\n" +
                       "Расписание звонков - /bells\n" +
                       "Показать помощь - /help\n\n" +
                       "⚙️ Изменить группу или включить уведомления - /settings\n\n" +
                       "Все команды кликабельны, а также доступны по кнопке 'Меню'\n\n" +
                       "Также бот поддерживает инлайн режим, в любом чате напиши: \n" +
                       "`@BarsuRaspBot `(с пробелом). " +
                       "Так можно быстро отправить расписание своему другу."
            });
        }
        
        public ReplyKeyboardMarkup department_keyboard() {
            var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
            
            foreach (var department in group_manager.get_departments()) {
                keyboard.add_button(new KeyboardButton() { text = department.name }).new_row();
            }
            
            return keyboard;
        }
        
        public ReplyKeyboardMarkup name_keyboard(Department department) {
            var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
            
            foreach (var teacher in department.teachers) {
                keyboard.add_button(new KeyboardButton() { text = teacher }).new_row();
            }
            
            return keyboard;
        }
        
        public ReplyKeyboardMarkup faculty_keyboard() {
            var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
            
            foreach (var faculty in group_manager.get_faculties()) {
                keyboard.add_button(new KeyboardButton() { text = faculty.name }).new_row();
            }
            
            return keyboard;
        }
        
        public ReplyKeyboardMarkup speciality_keyboard(Faculty faculty) {
            var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
            
            foreach (var speciality in faculty.specialties) {
                keyboard.add_button(new KeyboardButton() { text = speciality.name }).new_row();
            }
            
            return keyboard;
        }
        
        public ReplyKeyboardMarkup group_keyboard(Speciality speciality) {
            var keyboard = new ReplyKeyboardMarkup() { is_persistent = true, resize_keyboard = true };
            
            foreach (var group in speciality.groups) {
                keyboard.add_button(new KeyboardButton() { text = group }).new_row();
            }
            
            return keyboard;
        }
    }
}
