using Gee;

namespace Barsu {
    
    public class ImageManager {
        private ImageLoader loader = new ImageLoader();
        
        public async TimetableImage? get_image(ImageTheme theme, string date, string? group = null, string? name = null) {
            if (group != null) {
                var timetable = yield timetable_manager.get_timetable(group, date);
                
                if (timetable == null)
                    return null;
                
                return new TimetableImage() {
                    bytes = loader.create_image(timetable, theme),
                    group = group,
                    date = date
                };
            } else {
                var timetable = yield timetable_manager.get_teacher(name, date);
                
                if (timetable == null)
                    return null;
                
                return new TimetableImage() {
                    bytes = loader.create_teacher_image(timetable, theme),
                    name = name,
                    date = date
                };
            }
        }
    }
}

