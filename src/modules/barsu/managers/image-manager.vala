using Gee;

namespace Barsu {
    
    public class ImageManager {
        private ConcurrentList<TimetableImage> cache = new ConcurrentList<TimetableImage>();
        private ImageLoader loader = new ImageLoader();
        
        public void update_cache(TimetableImage image) {
            cache.add(image);
        }
        
        public async TimetableImage? get_image(string date, string? group = null, string? name = null) {
            var theme = new ClassicTheme();
            
            var image = cache.first_match((image) => {
                if (group != null)
                    return image.group == group && image.date == date;
                else
                    return image.name == name && image.date == date;
            });
            
            if (image != null) {
                if (image.last_fetch.add_minutes(30).compare(new DateTime.now()) < 1) {
                    if (group != null) {
                        var timetable = yield timetable_manager.get_timetable(group, date);
                        
                        if (timetable != null) {
                            cache.remove(image);
                            
                            return new TimetableImage() {
                                bytes = loader.create_image(timetable, theme),
                                last_fetch = new DateTime.now(),
                                group = group,
                                date = date
                            };
                        }
                    } else {
                        var timetable = yield timetable_manager.get_teacher(name, date);
                        
                        if (timetable != null) {
                            cache.remove(image);
                            
                            return new TimetableImage() {
                                bytes = loader.create_teacher_image(timetable, theme),
                                last_fetch = new DateTime.now(),
                                name = name,
                                date = date
                            };
                        }
                    }
                    return image;
                }
                return image;
            }
            
            if (group != null) {
                var timetable = yield timetable_manager.get_timetable(group, date);
                
                if (timetable == null)
                    return null;
                
                return new TimetableImage() {
                    bytes = loader.create_image(timetable, theme),
                    last_fetch = new DateTime.now(),
                    group = group,
                    date = date
                };
            } else {
                var timetable = yield timetable_manager.get_teacher(name, date);
                
                if (timetable == null)
                    return null;
                
                return new TimetableImage() {
                    bytes = loader.create_teacher_image(timetable, theme),
                    last_fetch = new DateTime.now(),
                    name = name,
                    date = date
                };
            }
        }
    }
}

