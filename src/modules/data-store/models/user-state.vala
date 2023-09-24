namespace DataStore {
    
    public enum UserState {
        // used /start command
        POST,
        // Chosed teacher
        DEPARTMENT,
        // Chosed department
        NAME,
        // Chosed student
        FACULTY,
        // Chosed faculty
        SPECIALITY,
        // Chosed speciality
        GROUP;
        
        public static UserState? parse(string type) {
            switch (type) {
                case "department":
                    return DEPARTMENT;
                case "name":
                    return NAME;
                case "faculty":
                    return FACULTY;
                case "speciality":
                    return SPECIALITY;
                case "group":
                    return GROUP;
                default:
                    return POST;
            }
        }
        
        public string to_string() {
            switch (this) {
                case DEPARTMENT:
                    return "department";
                case NAME:
                    return "name";
                case FACULTY:
                    return "faculty";
                case SPECIALITY:
                    return "speciality";
                case GROUP:
                    return "group";
                default:
                    return "post";
            }
        }
    }
}
