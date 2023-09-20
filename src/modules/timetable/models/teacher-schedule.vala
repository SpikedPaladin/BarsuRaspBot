namespace BarsuTimetable {
    
    public class TeacherSchedule {
        public string day;
        public string date;
        
        public TeacherLesson[] lessons;
    }
    
    public class TeacherLesson {
        public string time;
        public string? name;
        public string? type;
        public string? groups;
        public string? place;
    }
}
