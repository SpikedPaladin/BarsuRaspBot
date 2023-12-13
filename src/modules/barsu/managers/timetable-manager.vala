using Gee;

namespace Barsu {
    
    public class TimetableManager {
        public ConcurrentList<Teacher.Timetable> teacher_cache = new ConcurrentList<Teacher.Timetable>();
        public ConcurrentList<Student.Timetable> cache = new ConcurrentList<Student.Timetable>();
        private Teacher.TimetableLoader teacher = new Teacher.TimetableLoader();
        private Student.TimetableLoader student = new Student.TimetableLoader();
        
        public async Teacher.Timetable? get_teacher(string name, string date) {
            var timetable = teacher_cache.first_match((timetable) => {
                return timetable.name == name && timetable.date == date;
            });
            
            if (timetable != null) {
                if (timetable.last_fetch.add_minutes(30).compare(new DateTime.now()) < 1) {
                    var new_timetable = yield teacher.load(name, date);
                    
                    if (new_timetable != null) {
                        teacher_cache.remove(timetable);
                        teacher_cache.add(new_timetable);

                        return new_timetable;
                    } else
                        return timetable;
                }
                
                return timetable;
            }
            
            timetable = yield teacher.load(name, date);
            
            if (timetable != null)
                teacher_cache.add(timetable);
            
            return timetable;
        }
        
        public async Student.Timetable? get_timetable(string group, string date) {
            var timetable = cache.first_match((timetable) => {
                return timetable.group == group && timetable.date == date;
            });
            
            if (timetable != null) {
                if (timetable.last_fetch.add_minutes(30).compare(new DateTime.now()) < 1) {
                    var new_timetable = yield student.load(group, date);
                    
                    if (new_timetable != null && new_timetable.last_update.to_string() != timetable.last_update.to_string()) {
                        cache.remove(timetable);
                        cache.add(new_timetable);
                        
                        return new_timetable;
                    } else
                        return timetable;
                } else {
                    return timetable;
                }
            }
            
            timetable = yield student.load(group, date);
            
            if (timetable != null)
                cache.add(timetable);
            
            return timetable;
        }
    }
}
