using DataStore;
using Telegram;

namespace Barsu {
    
    public class InlineTimetable {
        
        public async void send_group_incorrect(InlineQuery query) {
            yield bot.send(new AnswerInlineQuery() {
                inline_query_id = query.id,
                cache_time = 600,
                
                results = { new InlineQueryResultArticle() {
                    title = "⚠️ Группа не найдена!",
                    description = "Такой группы не найдено ❌️",
                    input_message_content = new InputTextMessageContent() {
                        message_text = "⚠️ *Группа не найдена!*\n\nПерейди в диалог со мной (@BarsuRaspBot) чтобы выбрать группу.",
                        parse_mode = ParseMode.MARKDOWN
                    }
                }}
            });
        }
        
        public async void send_no_group(InlineQuery query) {
            yield bot.send(new AnswerInlineQuery() {
                inline_query_id = query.id,
                is_personal = true,
                cache_time = 5,
                
                results = { new InlineQueryResultArticle() {
                    title = "⚠️ Группа не выбрана!",
                    description = "✍️ Напиши название группы либо выбери ее в диалоге со мной",
                    input_message_content = new InputTextMessageContent() {
                        message_text = "⚠️ *Группа не выбрана*\n\nПерейди в диалог со мной (@BarsuRaspBot) чтобы выбрать группу или напиши название группы чтобы отправить её расписание",
                        parse_mode = ParseMode.MARKDOWN
                    }
                }}
            });
        }
        
        public async void send_timetable(InlineQuery query) {
            yield send_inline_timetable(query.id, get_config(query.from.id).group);
        }
        
        public async void send_group_timetable(InlineQuery query) {
            var group = data.parse_group(query.query);
            
            if (group == null) {
                yield send_group_incorrect(query);
                
                return;
            }
            
            yield send_inline_timetable(query.id, group);
        }
        
        private async void send_inline_timetable(string query_id, string group) {
            var timetable = yield timetable_manager.get_timetable(group, get_current_week().format("%F"));
            InlineQueryResult[] results = {};
            
            if (timetable != null) {
                // results += new InlineQueryResultPhoto() {
                //     id = @"week:$group",
                //     photo_url = "https://i.ibb.co/9TwR5S7/week-preview.png",
                //     thumbnail_url = "https://i.ibb.co/9TwR5S7/week-preview.png",
                //     title = "Расписание на неделю",
                //     description = "Отправить картинкой"
                // };
                foreach (var day in timetable.days) {
                    results += new InlineQueryResultArticle() {
                        title = @"🗓️ $(day.day_of_week) $(day.date)",
                        description = @"✍️ Количество пар - $(day.number_of_lessons)",
                        thumbnail_url = "https://i.ibb.co/D5xCKn5/day-of-week.png",
                        input_message_content = new InputTextMessageContent() {
                            message_text = @"👥️ Группа: *$(group)*\n" + timetable.to_string(day.day_of_week),
                            parse_mode = ParseMode.MARKDOWN
                        }
                    };
                }
            } else
                results += new InlineQueryResultArticle() {
                    title = "⚠️ Расписание не найдено!",
                    description = "Расписания пока что нет попробуй позже",
                    input_message_content = new InputTextMessageContent() {
                        message_text = "⚠️ *Расписание не найдено!*",
                        parse_mode = ParseMode.MARKDOWN
                    }
                };
            
            yield bot.send(new AnswerInlineQuery() {
                inline_query_id = query_id,
                is_personal = true,
                results = results
            });
        }
    }
}
