namespace DataStore {
    
    public enum UserPost {
        TEACHER,
        STUDENT;
        
        public static UserPost? parse(string post) {
            switch (post) {
                case "teacher":
                    return TEACHER;
                default:
                    return STUDENT;
            }
        }
        
        public string to_string() {
            switch (this) {
                case TEACHER:
                    return "teacher";
                default:
                    return "student";
            }
        }
    }
}
