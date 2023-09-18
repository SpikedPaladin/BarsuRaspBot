namespace Bus {
    
    public class BusInfo {
        public int number;
        public string name;
        public string? backward_name;
        public BusStop[] stops;
        public BusStop[]? backward_stops;
        
        public bool has_backward {
            get {
                return backward_name != null;
            }
        }
        
        public BusInfo() {}
        
        public BusInfo.from_json(Json.Object object) {
            number = (int) object.get_int_member("number");
            name = object.get_string_member("name");
            
            BusStop[] temp = {};
            foreach (var stop in object.get_array_member("stops").get_elements()) {
                temp += new BusStop.from_json(stop.get_object());
            }
            stops = temp;
            
            if (object.has_member("backward_name")) {
                backward_name = object.get_string_member("backward_name");
                temp = {};
                
                foreach (var stop in object.get_array_member("backward_stops").get_elements()) {
                    temp += new BusStop.from_json(stop.get_object());
                }
                backward_stops = temp;
            }
        }
        
        public void to_builder(ref Json.Builder builder) {
            builder.begin_object();
            
            builder.set_member_name("number");
            builder.add_int_value(number);
            
            builder.set_member_name("name");
            builder.add_string_value(name);
            
            builder.set_member_name("stops");
            builder.begin_array();
            foreach (var stop in stops)
                stop.to_builder(ref builder);
            
            builder.end_array();
            
            if (backward_name != null) {
                builder.set_member_name("backward_name");
                builder.add_string_value(backward_name);
                
                builder.set_member_name("backward_stops");
                builder.begin_array();
                foreach (var stop in backward_stops)
                    stop.to_builder(ref builder);
                
                builder.end_array();
            }
            
            builder.end_object();
        }
        
        public string get_name(bool forward) {
            return forward ? name : backward_name;
        }
    }
}
