using Gee;

namespace BarsuTimetable {
    
    public class TimetableLoader {
        
        public async TeacherTimetable? load_teacher(string name, string week) {
            try {
                var payload = create_teacher_payload(name, week);
                var msg = new Soup.Message.from_multipart("https://rasp.barsu.by/teach.php", payload);
                var rasp_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
                
                var doc = new GXml.XHtmlDocument.from_string((string) rasp_page.get_data());
                
                var table = doc.get_elements_by_class_name("table-bordered").get_element(0).get_elements_by_tag_name("tbody").get_element(0);
                var table_rows = table.get_elements_by_tag_name("tr").to_array();
                
                if (table_rows.length == 0)
                    return null;
                
                TeacherSchedule[] schedules = {};
                var schedule = new TeacherSchedule();
                TeacherLesson[] lessons = {};
                foreach (var row in table_rows) {
                    if (!row.has_child_nodes())
                        continue;
                    
                    var lesson_info = row.get_elements_by_tag_name("td").to_array();
                    int offset = 0;
                    if (lesson_info.length > 4) {
                        schedule = new TeacherSchedule();
                        lessons = {};
                        schedule.day = lesson_info[offset++].text_content.strip();
                        schedule.date = lesson_info[offset++].text_content.strip();
                    }
                    
                    var lesson = new TeacherLesson();
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
                
                return new TeacherTimetable() {
                    days = schedules,
                    name = name,
                    date = week
                };
            } catch (Error error) {
                warning("Error while loading teacher timetable: %s\n", error.message);
            }
            
            return null;
        }
        
        public async Timetable? load_timetable(string group, string week) {
            try {
                var payload = create_payload(group, week);
                var msg = new Soup.Message.from_multipart("https://rasp.barsu.by/stud.php", payload);
                var rasp_page = yield session.send_and_read_async(msg, Soup.MessagePriority.NORMAL, null);
                
                var doc = new GXml.XHtmlDocument.from_string((string) rasp_page.get_data());
                
                var test = doc.get_elements_by_class_name("min-p").get_element(0);
                var table_array = test.get_elements_by_tag_name("td").to_array();
                
                if (table_array.length == 0)
                    return null;
                
                var last_update_container = doc.get_elements_by_class_name("container").get_element(2);
                var last_update = last_update_container.get_elements_by_tag_name("p").to_array()[0].text_content;
                
                DaySchedule[] days = {};
                Lesson[] lessons = {};
                for (int i = 0; i < table_array.length; i++) {
                    if (i % 2 != 0)
                        continue;
                    
                    if (table_array[i].has_attribute("rowspan")) {
                        var day = table_array[i].text_content.replace(" ", "");
                        var date = table_array[i + 1].text_content.replace(" ", "");
                        
                        days += new DaySchedule() {
                            last_fetch = new DateTime.now(),
                            day_of_week = day,
                            date = date
                        };
                        
                        lessons = {};
                        continue;
                    }
                    var time = table_array[i].text_content.replace(" ", "");
                    var raw_lesson = element_to_string(table_array[i + 1]).split("|");
                    if (raw_lesson.length > 1) {
                        var sublessons = new ArrayList<Lesson.Sublesson>();
                        
                        for (int j = 0; j < raw_lesson.length; j += 3) {
                            var chunk = raw_lesson[j:j + 3];
                            
                            string? place = null, subgroup = null;
                            
                            var raw_place = chunk[2].strip();
                            if (raw_place.length > 0) {
                                if (raw_place.contains(":")) {
                                    var parsed_place = raw_place.split("  ");
                                    
                                    place = parsed_place[0];
                                    subgroup = parsed_place[1];
                                } else {
                                    place = chunk[2].strip();
                                }
                            }
                            
                            sublessons.add(new Lesson.Sublesson() {
                                name = chunk[0].substring(0, chunk[0].last_index_of("-") - 1),
                                type = chunk[0].substring(chunk[0].last_index_of("-") + 2).strip(),
                                teacher = chunk[1],
                                place = place,
                                subgroup = subgroup
                            });
                        }
                        
                        sublessons.sort((a, b) => strcmp(a.subgroup, b.subgroup));
                        
                        lessons += new Lesson() {
                            time = time,
                            sublessons = sublessons.to_array(),
                            replaced = table_array[i + 1].get_attribute("bgcolor") == "#ffb2b9"
                        };
                    } else {
                        lessons += new Lesson() { time = time };
                    }
                    
                    if (time.has_prefix("19"))
                        days[days.length - 1].lessons = lessons;
                }
                
                return new Timetable() {
                    last_update = parse_last_update(last_update),
                    last_fetch = new DateTime.now(),
                    days = days,
                    group = group,
                    date = week
                };
            } catch (Error error) {
                warning("Error while loading timetable: %s\n", error.message);
            }
            
            return null;
        }
        
        private Soup.Multipart create_payload(string group, string week) {
            var multipart = new Soup.Multipart("multipart/form-data");
            multipart.append_form_string("faculty", "selectcard");
            multipart.append_form_string("speciality", "selectcard");
            multipart.append_form_string("groups", group);
            multipart.append_form_string("weekbegindate", week);
            
            return multipart;
        }
        
        private Soup.Multipart create_teacher_payload(string name, string week) {
            var multipart = new Soup.Multipart("multipart/form-data");
            multipart.append_form_string("kafedra", "selectcard");
            multipart.append_form_string("teacher", name);
            multipart.append_form_string("weekbegindate", week);
            
            return multipart;
        }
        
        private string element_to_string(GXml.DomElement element) {
            string s = null;
            foreach (var n in element.child_nodes) {
                if (n is GXml.DomText) {
                    if (s == null) s = ((GXml.XNode) n).value;
                    else s += ((GXml.XNode) n).value;
                } else {
                    s += "|";
                }
            }
            
            return s.substring(0, s.length - 2);
        }
        
        /**
         * Inputs 'Последнее обновление 2023-09-06 02:45:49'
         */
        private DateTime parse_last_update(string input) {
            var parts = input.split(" ");
            var date_parts = parts[2].split("-");
            var time_parts = parts[3].split(":");
            
            return new DateTime.local(
                int.parse(date_parts[0]),
                int.parse(date_parts[1]),
                int.parse(date_parts[2]),
                int.parse(time_parts[0]),
                int.parse(time_parts[1]),
                int.parse(time_parts[2])
            );
        }
    }
}
