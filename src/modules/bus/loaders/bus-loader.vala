using Gee;

namespace Bus {
    
    public class BusLoader {
        public ArrayList<BusInfo> buses = new ArrayList<BusInfo>();
        
        public async void load_config() {
            var file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/buses.json");
            
            if (file.query_exists()) {
                try {
                    var stream = yield file.open_readwrite_async();
                    var parser = new Json.Parser();
                    
                    yield parser.load_from_stream_async(stream.input_stream);
                    
                    var obj = parser.get_root().get_object();
                    
                    foreach (var element in obj.get_array_member("buses").get_elements())
                        buses.add(new BusInfo.from_json(element.get_object()));
                } catch (Error error) {
                    warning("Error while reading buses: %s\n", error.message);
                }
            }
        }
        
        public async void save_config() {
            var file = File.new_for_path(".cache/TelegramBots/BarsuRaspBot/buses.json");
            
            try {
                var builder = new Json.Builder();
                builder.begin_object();
                
                builder.set_member_name("buses");
                builder.begin_array();
                foreach (var bus in buses)
                    bus.to_builder(ref builder);
                
                builder.end_array();
                
                builder.end_object();
                
                var generator = new Json.Generator();
                
                generator.set_root(builder.get_root());
                generator.to_file(file.get_path());
            } catch (Error error) {
                warning("Error while saving configs: %s\n", error.message);
            }
        }
        
        public async void load_buses() {
            try {
                var msg = new Soup.Message("GET", @"https://barautopark.by/services/freight/5/");
                var main_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
                var doc = new GXml.XHtmlDocument.from_string((string) main_page.get_data());
                
                var links = doc.get_elements_by_tag_name("tbody")
                               .get_element(0)
                               .get_elements_by_tag_name("a")
                               .to_array();
                
                var bus_directions = new ArrayList<BusDirection?>();
                int prev_bus = 0;
                foreach (var link in links) {
                    int bus_number;
                    string bus_name;
                    int bus_id;
                    
                    parse_bus_direction(link, out bus_name, out bus_number, out bus_id);
                    BusDirection? bus_direction = null;
                    
                    if (bus_number == prev_bus) {
                        bus_direction = bus_directions.last();
                        bus_direction.backward_name = bus_name;
                        bus_direction.backward = bus_id;
                        
                        bus_directions.set(bus_directions.size - 1, bus_direction);
                    } else {
                        bus_direction = BusDirection() {
                            bus_number = bus_number,
                            name = bus_name,
                            forward = bus_id
                        };
                        
                        bus_directions.add(bus_direction);
                    }
                    prev_bus = bus_number;
                }
                
                foreach (var bus_direction in bus_directions) {
                    var bus = yield load_bus_info(bus_direction);
                    
                    buses.add(bus);
                }
                
                yield save_config();
            } catch (Error error) {
                warning("Error while loading buses: %s\n", error.message);
            }
        }
        
        private async BusInfo load_bus_info(BusDirection bus_direction) throws Error {
            var info = new BusInfo() {
                name = bus_direction.name,
                backward_name = bus_direction.backward_name,
                number = bus_direction.bus_number
            };
            
            var stops = yield load_bus_stops(bus_direction.forward);
            info.stops = stops;
            
            if (bus_direction.backward != null) {
                stops = yield load_bus_stops(bus_direction.backward);
                info.backward_stops = stops;
            }
            
            return info;
        }
        
        private async BusStop[] load_bus_stops(int direction_id) throws Error {
            var msg = new Soup.Message("GET", @"https://barautopark.by/services/freight/$direction_id/?print=y");
            var bus_dir_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
            var doc = new GXml.XHtmlDocument.from_string((string) bus_dir_page.get_data());
            
            BusStop[] stops = {};
            var stops_elements = doc.get_elements_by_class_name("tabs-category")
                                    .get_element(0)
                                    .get_elements_by_tag_name("div")
                                    .to_array();
            
            foreach (var element in stops_elements) {
                stops += yield load_bus_stop(
                    int.parse(element.get_attribute("id")),
                    element.get_elements_by_tag_name("a").get_element(0).text_content
                );
            }
            return stops;
        }
        
        public async BusStop load_bus_stop(int stop_id, string name) throws Error {
            var msg = new Soup.Message("GET", @"https://barautopark.by/bitrix/templates/barautopark/ajax.php?action=getBusPath&element_id=$stop_id");
            var bus_dir_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
            var doc = new GXml.XHtmlDocument.from_string((string) bus_dir_page.get_data());
            
            //doc.get_elements_by_tag_name("h3").get_element(0).text_content) wrong encoding for name but why?
            return new BusStop(doc.get_elements_by_tag_name("tbody")) {
                name = name
            };
        }
        
        private void parse_bus_direction(GXml.DomElement link, out string name, out int number, out int id) {
            name = link.text_content.substring(link.text_content.index_of(" ") + 1);
            number = int.parse(link.text_content.split(" ")[0].replace("№", ""));
            id = int.parse(link.get_attribute("href").split("/")[3]);
        }
        
        public async string? load_direction_info(int bus_number, bool forward = true)
            requires (bus_number > 0 && bus_number < 33)
        {
            try {
                var bus_dir_num = 172;
                var message = new Soup.Message("GET", @"https://barautopark.by/bitrix/templates/barautopark/ajax.php?action=getBusPath&element_id=$bus_dir_num&path_type=forward");
                
                var rasp_page = yield session.send_and_read_async(message, Soup.MessagePriority.NORMAL, null);
                
                //var doc = new GXml.XHtmlDocument.from_string((string) rasp_page.get_data());
                
                var str = (string) rasp_page.get_data();
                
                GLib.message(str);
                return str;
            } catch (Error error) {
                warning("Error while loading bus info: %s\n", error.message);
                
                return null;
            }
        }
    }
}
