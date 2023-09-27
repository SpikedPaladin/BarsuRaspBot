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
        
        public async TimetableImage? get_image(string group, string date) {
            var image = loader.images.first_match((image) => {
                return image.group == group && image.date == date;
            });
            
            // TODO add last update check
            if (image != null)
                return image;
            
            var timetable = yield timetable_manager.get_timetable(group, date);
            
            if (timetable == null)
                return null;
            
            return new TimetableImage() {
                bytes = loader.create_image(timetable),
                group = group,
                date = date
            };
        }
    }
}
