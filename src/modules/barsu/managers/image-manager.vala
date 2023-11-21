using Gee;

namespace Barsu {
    
    public class ImageManager {
        private ImageLoader loader = new ImageLoader();
        
        public ImageManager() {
            loader.load_cache.begin();
        }
        
        public async void load() {
            yield loader.load_cache();
        }
        
        public void update_cache(TimetableImage image) {
            loader.images.add(image);
        }
        
        public async TimetableImage? get_image(string date, string? group = null, string? name = null) {
            var image = loader.images.first_match((image) => {
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
                            loader.images.remove(image);
                            
                            return new TimetableImage() {
                                bytes = loader.create_image(timetable),
                                last_fetch = new DateTime.now(),
                                group = group,
                                date = date
                            };
                        }
                    } else {
                        var timetable = yield timetable_manager.get_teacher(name, date);
                        
                        if (timetable != null) {
                            loader.images.remove(image);
                            
                            return new TimetableImage() {
                                bytes = loader.create_teacher_image(timetable),
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
                    bytes = loader.create_image(timetable),
                    last_fetch = new DateTime.now(),
                    group = group,
                    date = date
                };
            } else {
                var timetable = yield timetable_manager.get_teacher(name, date);
                
                if (timetable == null)
                    return null;
                
                return new TimetableImage() {
                    bytes = loader.create_teacher_image(timetable),
                    last_fetch = new DateTime.now(),
                    name = name,
                    date = date
                };
            }
        }
    }
}

