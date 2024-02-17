using Gee;

namespace Barsu {
    
    public class ImageLoader {
        private const int FONT_SIZE = 22;
        
        public Bytes create_teacher_image(Teacher.Timetable timetable, ImageTheme theme) {
            var surface = new Cairo.ImageSurface(Cairo.Format.RGB24, 1000, get_teacher_height(timetable));
            var cr = new Cairo.Context(surface);
            
            cr.select_font_face("Nimbus Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
            theme.background(cr);
            cr.paint();
            
            var time_x = 100;
            var type_x = 240;
            var name_x = 280;
            var teacher_x = 620;
            var place_x = 850;
            
            theme.title_background(cr);
            round_rect(cr, 10, 10, 980, 50, 15);
            cr.fill();
            
            theme.title_text(cr);
            cr.set_font_size(20);
            
            cr.move_to(20, 40);
            cr.show_text("Дата");
            
            cr.move_to(time_x, 40);
            cr.show_text("Время");
            
            cr.move_to(name_x, 40);
            cr.show_text("Дисциплина");
            
            cr.move_to(teacher_x, 40);
            cr.show_text("Группы");
            
            cr.move_to(place_x, 40);
            cr.show_text("Аудитория");
            
            int offset = 80;
            foreach (var day in timetable.days) {
                int lesson_offset = 0;
                
                var card_offset = get_teacher_card_offset(day);
                
                theme.card_background(cr);
                round_rect(cr, 10, offset, 982, card_offset - 3, 15);
                cr.fill();
                
                round_rect(cr, 10, offset - 2, 979, card_offset - 5, 15);
                cr.clip();
                cr.new_path();
                
                foreach (var lesson in day.lessons) {
                    if (lesson.empty)
                        continue;
                    
                    var row_height = FONT_SIZE * 1;
                    
                    if (lesson.replaced)
                        theme.lesson_replaced(cr);
                    else
                        theme.lesson(cr);
                    
                    cr.rectangle(80, offset + lesson_offset, 910, row_height + 10 + (6 * 1));
                    cr.fill();
                    
                    theme.lesson_text(cr);
                    cr.set_font_size(FONT_SIZE);
                    
                    if (1 > 1)
                        cr.move_to(time_x, offset + lesson_offset + 16 + (row_height / 2) + 1);
                    else
                        cr.move_to(time_x, offset + lesson_offset + 26);
                    cr.show_text(lesson.time);
                    
                    //var sublesson_number = 1;
                    //foreach (var sublesson in lesson.sublessons) {
                        var sublesson_y = offset + lesson_offset + (20 * 1) + (6 * 1);
                        
                        var type = lesson.type;
                        if (type.contains(" "))
                            type = type.split(" ")[0];
                        
                        draw_type(theme, cr, type, type_x, sublesson_y);
                        cr.set_font_size(20);
                        
                        var name = lesson.name;
                        theme.lesson_text(cr);
                        cr.move_to(name_x, sublesson_y);
                        cr.show_text(name);
                        
                        cr.move_to(teacher_x, sublesson_y);
                        cr.show_text(lesson.groups);
                        
                        if (lesson.place != null) {
                            cr.move_to(place_x, sublesson_y);
                            cr.show_text(lesson.place);
                        }
                        //sublesson_number++;
                    //}
                    
                    lesson_offset += row_height + 10 + (6 * 1) + 4;
                }
                
                theme.card_text(cr);
                cr.set_font_size(20);
                cr.move_to(30, offset + (card_offset / 2) - 11);
                cr.show_text(day.day);
                
                cr.move_to(20, offset + (card_offset / 2) + 11);
                cr.show_text(day.date);
                
                cr.reset_clip();
                
                offset += card_offset + 10;
            }
            
            cr.translate(0, 0);
            theme.credits_text(cr);
            cr.set_font_size(30);
            cr.move_to(420, offset + 20);
            cr.show_text("t.me/BarsuRaspBot");
            
            theme.extra_text(cr);
            cr.move_to(20, offset + 20);
            cr.show_text(@"$(timetable.name) | $(timetable.date)");
            
            uchar[] data = {};
            surface.write_to_png_stream((png_data) => {
                foreach (var byte in png_data)
                    data += byte;
                
                return Cairo.Status.SUCCESS;
            });
            
            return new Bytes.take(data);
        }
        
        public Bytes create_image(Student.Timetable timetable, ImageTheme theme) {
            var surface = new Cairo.ImageSurface(Cairo.Format.RGB24, 1000, calculate_surface_height(timetable));
            var cr = new Cairo.Context(surface);
            
            cr.select_font_face("Nimbus Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
            theme.background(cr);
            cr.paint();
            
            var time_x = 100;
            var type_x = 240;
            var name_x = 280;
            var teacher_x = 620;
            var place_x = 850;
            
            theme.title_background(cr);
            round_rect(cr, 10, 10, 980, 50, 15);
            cr.fill();
            
            theme.title_text(cr);
            cr.set_font_size(20);
            
            cr.move_to(20, 40);
            cr.show_text("Дата");
            
            cr.move_to(time_x, 40);
            cr.show_text("Время");
            
            cr.move_to(name_x, 40);
            cr.show_text("Дисциплина");
            
            cr.move_to(teacher_x, 40);
            cr.show_text("Преподаватель");
            
            cr.move_to(place_x, 40);
            cr.show_text("Аудитория");
            
            int offset = 80;
            foreach (var day in timetable.days) {
                int lesson_offset = 0;
                
                var card_offset = calculate_card_offset(day);
                
                theme.card_background(cr);
                round_rect(cr, 10, offset, 982, card_offset - 3, 15);
                cr.fill();
                
                round_rect(cr, 10, offset - 2, 979, card_offset - 5, 15);
                cr.clip();
                cr.new_path();
                
                foreach (var lesson in day.lessons) {
                    if (lesson.empty)
                        continue;
                    
                    var row_height = FONT_SIZE * lesson.sublessons.length;
                    
                    if (lesson.replaced)
                        theme.lesson_replaced(cr);
                    else
                        theme.lesson(cr);
                    
                    cr.rectangle(80, offset + lesson_offset, 910, row_height + 10 + (6 * lesson.sublessons.length));
                    cr.fill();
                    
                    theme.lesson_text(cr);
                    cr.set_font_size(FONT_SIZE);
                    
                    if (lesson.sublessons.length > 1)
                        cr.move_to(time_x, offset + lesson_offset + 16 + (row_height / 2) + lesson.sublessons.length);
                    else
                        cr.move_to(time_x, offset + lesson_offset + 26);
                    cr.show_text(lesson.time);
                    
                    var sublesson_number = 1;
                    foreach (var sublesson in lesson.sublessons) {
                        var sublesson_y = offset + lesson_offset + (20 * sublesson_number) + (6 * sublesson_number);
                        
                        var type = sublesson.type;
                        if (type.contains(" "))
                            type = type.split(" ")[0];
                        
                        draw_type(theme, cr, type, type_x, sublesson_y);
                        cr.set_font_size(20);
                        
                        var name = sublesson.name;
                        if (sublesson.subgroup != null)
                            name += @" $(sublesson.subgroup)";
                        theme.lesson_text(cr);
                        cr.move_to(name_x, sublesson_y);
                        cr.show_text(name);
                        
                        cr.move_to(teacher_x, sublesson_y);
                        cr.show_text(sublesson.teacher);
                        
                        if (sublesson.place != null) {
                            cr.move_to(place_x, sublesson_y);
                            cr.show_text(sublesson.place);
                        }
                        sublesson_number++;
                    }
                    
                    lesson_offset += row_height + 10 + (6 * lesson.sublessons.length) + 4;
                }
                
                theme.card_text(cr);
                cr.set_font_size(20);
                cr.move_to(30, offset + (card_offset / 2) - 11);
                cr.show_text(day.day_of_week);
                
                cr.move_to(20, offset + (card_offset / 2) + 11);
                cr.show_text(day.date);
                
                cr.reset_clip();
                
                offset += card_offset + 10;
            }
            
            cr.translate(0, 0);
            theme.credits_text(cr);
            cr.set_font_size(30);
            cr.move_to(380, offset + 20);
            cr.show_text("t.me/BarsuRaspBot");
            
            theme.extra_text(cr);
            cr.move_to(20, offset + 20);
            cr.show_text(@"$(timetable.group) | $(timetable.pretty_date())");
            
            uchar[] data = {};
            surface.write_to_png_stream((png_data) => {
                foreach (var byte in png_data)
                    data += byte;
                
                return Cairo.Status.SUCCESS;
            });
            
            return new Bytes.take(data);
        }
        
        private int get_teacher_height(Teacher.Timetable timetable) {
            int offset = 80;
            foreach (var day in timetable.days) {
                int lesson_offset = 0;
                
                var card_offset = get_teacher_card_offset(day);
                foreach (var lesson in day.lessons) {
                    if (lesson.empty)
                        continue;
                    
                    var row_height = FONT_SIZE * 1;
                    lesson_offset += row_height + 10 + (6 * 1) + 4;
                }
                offset += card_offset + 10;
            }
            return offset + 40;
        }
        
        private int calculate_surface_height(Student.Timetable timetable) {
            int offset = 80;
            foreach (var day in timetable.days) {
                int lesson_offset = 0;
                
                var card_offset = calculate_card_offset(day);
                foreach (var lesson in day.lessons) {
                    if (lesson.empty)
                        continue;
                    
                    var row_height = FONT_SIZE * lesson.sublessons.length;
                    lesson_offset += row_height + 10 + (6 * lesson.sublessons.length) + 4;
                }
                offset += card_offset + 10;
            }
            return offset + 40;
        }
        
        private int calculate_card_offset(Student.DaySchedule day) {
            var card_offset = 0;
            
            foreach (var lesson in day.lessons) {
                if (lesson.empty)
                    continue;
                
                card_offset += (FONT_SIZE * lesson.sublessons.length) + 10 + (6 * lesson.sublessons.length) + 4;
            }
            return card_offset;
        }
        
        private int get_teacher_card_offset(Teacher.DaySchedule day) {
            var card_offset = 0;
            
            foreach (var lesson in day.lessons) {
                if (lesson.empty)
                    continue;
                
                card_offset += (FONT_SIZE * 1) + 10 + (6 * 1) + 4;
            }
            
            return card_offset;
        }
        
        private void draw_type(ImageTheme theme, Cairo.Context cr, string type, double x, double y) {
            var zach_rect = type.up() == "ЗАЧ" ? 13 : 0;
            var zach_x = type.up() == "ЗАЧ" ? 8 : 0;
            paint_type_color(theme, cr, type, false);
            round_rect(cr, (int) x - 8 - zach_x, (int) y - 18, 40 + zach_rect, 22, 11);
            cr.fill();
            
            cr.set_font_size(18);
            paint_type_color(theme, cr, type);
            cr.move_to(x - zach_x, y - 1);
            cr.show_text(type);
        }
        
        private void paint_type_color(ImageTheme theme, Cairo.Context cr, string type, bool is_text = true) {
            switch (type.up()) {
                case "ЛК":
                    theme.chip_1(cr, is_text);
                    break;
                case "ПЗ":
                    theme.chip_2(cr, is_text);
                    break;
                case "ЛЗ":
                    theme.chip_3(cr, is_text);
                    break;
                case "КП":
                    theme.chip_4(cr, is_text);
                    break;
                case "ЗАЧ":
                    theme.chip_5(cr, is_text);
                    break;
                case "СЗ":
                    theme.chip_6(cr, is_text);
                    break;
                default:
                    theme.chip_7(cr, is_text);
                    break;
            }
        }
        
        private void round_rect(Cairo.Context cr, int x, int y, int width, int height, int radius) {
            var degrees = Math.PI / 180;
            
            cr.new_sub_path();
            cr.arc(x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
            cr.arc(x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
            cr.arc(x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
            cr.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
            cr.close_path();
        }
    }
}
