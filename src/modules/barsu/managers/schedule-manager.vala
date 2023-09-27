using Telegram;

namespace Barsu {
    
    public class ScheduleManager {
        public Schedule[] schedules = {
            { 9, 24 },
            { 10, 59 },
            { 12, 54 },
            { 14, 29 },
            { 16, 4 },
            { 17, 49 },
            { 19, 24 }
        };
        
        public ScheduleManager() {
            schedule_next();
        }
        
        public void schedule_next() {
            var timeout = calculate_timeout();
            var broadcast_time = new DateTime.now().add_seconds(timeout);
            
            Util.log(@"Scheduled next broadcast to $(broadcast_time.format("%H:%M %d.%m"))");
            
            GLib.Timeout.add_seconds((uint) timeout, () => {
                broadcast_manager.broadcast_next_lesson.begin();
                
                schedule_next();
                return false;
            });
        }
        
        public double calculate_timeout() {
            var number = get_current_lesson_number();
            var time = new DateTime.now();
            int hours, minutes;
            
            if (number == -1) {
                hours = 7;
                minutes = 45;
            } else {
                var schedule = schedules[number];
                
                hours = schedule.hour;
                minutes = schedule.minute;
            }
            
            var lesson_time = new DateTime.now()
                .add_seconds(-time.get_second()) // Remove seconds
                .add_hours(hours - time.get_hour())
                .add_minutes(minutes - time.get_minute());
            
            if (number == -1 && time.get_hour() > 8)
                lesson_time = lesson_time.add_days(1);
            
            return lesson_time.difference(time) / 1000000;
        }
        
        public int get_current_lesson_number() {
            var time = new DateTime.now();
            int number = -1;
            
            for (var i = schedules.length - 1; i >= 0; i--) {
                if (time.get_hour() < schedules[i].hour)
                    number = i;
                else if (time.get_hour() == schedules[i].hour && time.get_minute() < schedules[i].minute)
                    number = i;
            }
            
            return number;
        }
        
        public struct Schedule {
            int hour;
            int minute;
        }
    }
}
