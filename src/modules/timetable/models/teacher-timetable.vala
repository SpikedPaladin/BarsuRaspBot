namespace BarsuTimetable {
    
    public class TeacherTimetable {
        public TeacherSchedule[] days;
        public DateTime last_fetch;
        public string name;
        public string date;
        
        public TeacherSchedule? get_day_schedule(DateTime date) {
            foreach (var day in days)
                if (day.date == date.format("%d.%m"))
                    return day;
            
            return null;
        }
        
        public string to_string(string? day_of_week = null) {
            var str = "";
            
            foreach (var day in days) {
                if (day_of_week != null && day.day != day_of_week)
                    continue;
                
                str += day.to_string();
                str += "\n\n";
            }
            
            return str;
        }
    }
}
