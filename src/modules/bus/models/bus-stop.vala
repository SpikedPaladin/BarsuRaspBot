namespace Bus {
    
    public class BusStop {
        public string name;
        public Time[]? workdays;
        public Time[]? weekends;
        
        public BusStop(GXml.DomHTMLCollection tables) {
            workdays = parse_time(tables.get_element(0));
            weekends = parse_time(tables.get_element(1));
        }
        
        public BusStop.from_json(Json.Object object) {
            name = object.get_string_member("name");
            
            Time[] temp = {};
            if (object.has_member("workdays")) {
                temp = {};
                
                foreach (var time in object.get_array_member("workdays").get_elements())
                    temp += new Time.from_json(time.get_object());
                
                workdays = temp;
            }
            
            if (object.has_member("weekends")) {
                temp = {};
                
                foreach (var time in object.get_array_member("weekends").get_elements())
                    temp += new Time.from_json(time.get_object());
                
                weekends = temp;
            }
        }
        
        public void to_builder(ref Json.Builder builder) {
            builder.begin_object();
            
            builder.set_member_name("name");
            builder.add_string_value(name);
            
            if (workdays != null) {
                builder.set_member_name("workdays");
                builder.begin_array();
                
                foreach (var time in workdays)
                    time.to_builder(ref builder);
                
                builder.end_array();
            }
            
            if (weekends != null) {
                builder.set_member_name("weekends");
                builder.begin_array();
                
                foreach (var time in weekends)
                    time.to_builder(ref builder);
                
                builder.end_array();
            }
            
            builder.end_object();
        }
        
        public Time[]? get_nearest_time(int limit) {
            var date = new DateTime.now();
            Time[] result = {};
            
            if (date.get_day_of_week() > 5) {
                if (weekends == null)
                    return null;
                
                for (var i = 0; i < weekends.length; i++) {
                    if (date.get_hour() < weekends[i].hour)
                        result += weekends[i];
                    else if (date.get_hour() == weekends[i].hour && date.get_minute() < weekends[i].minute)
                        result += weekends[i];
                    
                    if (result.length == limit)
                        break;
                }
            } else {
                if (workdays == null)
                    return null;
                
                for (var i = 0; i < workdays.length; i++) {
                    if (date.get_hour() < workdays[i].hour)
                        result += workdays[i];
                    else if (date.get_hour() == workdays[i].hour && date.get_minute() < workdays[i].minute)
                        result += workdays[i];
                    
                    if (result.length == limit)
                        break;
                }
            }
            
            return result;
        }
        
        private Time[]? parse_time(GXml.DomElement table) {
            var table_elements = table.get_elements_by_tag_name("tr").to_array();
            
            if (table_elements.length == 0)
                return null;
            
            Time[] schedule = {};
            
            foreach (var element in table_elements) {
                var minute_element = element.get_elements_by_tag_name("td").get_element(1);
                if (minute_element.text_content.strip() == "")
                    continue;
                
                var hour_element = element.get_elements_by_tag_name("span").get_element(0);
                
                foreach (var minute in minute_element.text_content.strip().split(" "))
                    schedule += new Time() {
                        hour = int.parse(hour_element.text_content),
                        minute = int.parse(minute)
                    };
            }
            
            return schedule;
        }
        
        public class Time {
            public int hour;
            public int minute;
            
            public Time() {}
            
            public Time.from_json(Json.Object object) {
                hour = (int) object.get_int_member("hour");
                minute = (int) object.get_int_member("minute");
            }
            
            public void to_builder(ref Json.Builder builder) {
                builder.begin_object();
                
                builder.set_member_name("hour");
                builder.add_int_value(hour);
                
                builder.set_member_name("minute");
                builder.add_int_value(minute);
                
                builder.end_object();
            }
        }
    }
}
