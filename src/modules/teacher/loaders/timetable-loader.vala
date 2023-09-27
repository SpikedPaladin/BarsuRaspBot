namespace Teacher {
    
    public class TimetableLoader {
        
        public async Timetable? load(string name, string week) {
            try {
                var payload = create_teacher_payload(name, week);
                var msg = new Soup.Message.from_multipart("https://rasp.barsu.by/teach.php", payload);
                var rasp_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
                
                var doc = new GXml.XHtmlDocument.from_string((string) rasp_page.get_data());
                
                var table = doc.get_elements_by_class_name("table-bordered").get_element(0).get_elements_by_tag_name("tbody").get_element(0);
                var table_rows = table.get_elements_by_tag_name("tr").to_array();
                
                if (table_rows.length == 0)
                    return null;
                
                DaySchedule[] schedules = {};
                var schedule = new DaySchedule();
                Lesson[] lessons = {};
                foreach (var row in table_rows) {
                    if (!row.has_child_nodes())
                        continue;
                    
                    var lesson_info = row.get_elements_by_tag_name("td").to_array();
                    int offset = 0;
                    if (lesson_info.length > 4) {
                        schedule = new DaySchedule();
                        lessons = {};
                        schedule.day = lesson_info[offset++].text_content.strip();
                        schedule.date = lesson_info[offset++].text_content.strip();
                    }
                    
                    var lesson = new Lesson();
                    if (lesson_info[offset + 1].text_content.strip() == "") {
                        lesson.time = lesson_info[offset++].text_content.strip();
                    } else {
                        lesson.time = lesson_info[offset++].text_content.strip();
                        
                        var raw_name = lesson_info[offset++].text_content.strip();
                        lesson.name = raw_name.substring(0, raw_name.last_index_of("-")).strip();
                        lesson.type = raw_name.substring(raw_name.last_index_of("-") + 1).strip();
                        lesson.groups = lesson_info[offset++].text_content.strip();
                        lesson.place = lesson_info[offset++].text_content.strip();
                        lesson.replaced = row.get_attribute("bgcolor") == "#ffb2b9";
                    }
                    lessons += lesson;
                    
                    if (lesson_info[0].text_content.strip() == "19.35-21.00") {
                        schedule.lessons = lessons;
                        schedules += schedule;
                    }
                }
                
                return new Timetable() {
                    last_fetch = new DateTime.now(),
                    days = schedules,
                    name = name,
                    date = week
                };
            } catch (Error error) {
                warning("Error while loading teacher timetable: %s\n", error.message);
            }
            
            return null;
        }
        
        private Soup.Multipart create_teacher_payload(string name, string week) {
            var multipart = new Soup.Multipart("multipart/form-data");
            multipart.append_form_string("kafedra", "selectcard");
            multipart.append_form_string("teacher", name);
            multipart.append_form_string("weekbegindate", week);
            
            return multipart;
        }
    }
}
