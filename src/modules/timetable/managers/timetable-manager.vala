using Gee;

namespace BarsuTimetable {
    
    public class TimetableManager {
        public ConcurrentList<Timetable> cache = new ConcurrentList<Timetable>();
        private TimetableLoader loader = new TimetableLoader();
        
        public async Timetable? get_timetable(string group, string date) {
            var timetable = cache.first_match((timetable) => {
                return timetable.group == group && timetable.date == date;
            });
            
            if (timetable != null) {
                if (timetable.last_fetch.add_minutes(20).compare(new DateTime.now()) < 1) {
                    var new_timetable = yield loader.load_timetable(group, date);
                    
                    if (new_timetable.last_update.to_string() != timetable.last_update.to_string()) {
                        cache.remove(timetable);
                        cache.add(new_timetable);
                        
                        return new_timetable;
                    } else
                        return timetable;
                } else {
                    return timetable;
                }
            }
            
            timetable = yield loader.load_timetable(group, date);
            
            if (timetable != null) // Блять ебаный я дегенерат добавлял сука null в non-null список блять
                cache.add(timetable);
            
            return timetable;
        }
    }
}
