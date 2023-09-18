namespace BarsuTimetable {
    
    public class Faculty {
        public string name;
        public Speciality[] specialties;
        
        public Faculty(string name, Speciality[] specialties) {
            this.name = name;
            this.specialties = specialties;
        }
    }
    
    public class Speciality {
        public string name;
        public string[] groups;
        
        public Speciality(string name, string[] groups) {
            this.name = name;
            this.groups = groups;
        }
    }
}
