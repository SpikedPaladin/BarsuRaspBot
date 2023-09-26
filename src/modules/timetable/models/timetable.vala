namespace BarsuTimetable {
    
    public class Timetable {
        /**
         * List of day schedules
         */
        public DaySchedule[] days;
        /**
         * Last update on Barsu site
         */
        public DateTime last_update;
        /**
         * Real time when timetable was loaded from Barsu server
         */
        public DateTime last_fetch;
        /**
         * Timetable group
         */
        public string group;
        /**
         * Timetable date (start of week)
         */
        public string date;
        
        public DaySchedule? get_day_schedule(DateTime date) {
            foreach (var day in days)
                if (day.date == date.format("%d.%m"))
                    return day;
            
            return null;
        }
        
        public string pretty_date() {
            var parts = date.split("-");
            return parts[2] + "." + parts[1] + "." + parts[0];
        }
        
        public string to_string(string? day_of_week = null) {
            var str = "";
            
            foreach (var day in days) {
                if (day_of_week != null && day.day_of_week != day_of_week)
                    continue;
                
                str += day.to_string();
                str += "\n\n";
            }
            
            return str;
        }
    }
}
