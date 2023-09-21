using Gee;

namespace BarsuTimetable {
    
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
        
        public async TimetableImage? get_image(string group, DateTime date) {
            var image = loader.images.first_match((image) => {
                return image.group == group && image.date == date.format("%F");
            });
            
            // TODO add last update check
            if (image != null)
                return image;
            
            var timetable = yield timetable_manager.get_timetable(group, date.format("%F"));
            
            if (timetable == null)
                return null;
            
            return new TimetableImage() {
                bytes = loader.create_image(timetable),
                group = group,
                date = date.format("%F")
            };
        }
    }
}

