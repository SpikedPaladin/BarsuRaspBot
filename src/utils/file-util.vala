public class FileUtil {
    
    public static void save_json(Json.Node json, string path) throws Error {
        var generator = new Json.Generator();
        var file = File.new_for_path(path);
        
        if (!file.get_parent().query_exists())
            file.get_parent().make_directory_with_parents();
        
        generator.set_root(json);
        generator.to_file(file.get_path());
    }
}
