
public class Utility
{
	public static CompareFunc<string> strcasecmp { get { return _strcasecmp; } }	
	static int _strcasecmp(string a, string b) {
		return a.casefold().collate(b.casefold());
	}
	
	public static bool remove_directory_recursive(File directory) throws GLib.Error
	{
		var enumerator = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
		FileInfo file_info;
		while ((file_info = enumerator.next_file ()) != null) {
			var type = file_info.get_file_type();
			var name = file_info.get_name();
			if (name.has_prefix(".") == true)
				continue;
			File child = File.new_for_path(Path.build_filename(directory.get_path(), name));
			bool child_delete_result = false;
			if (type == FileType.DIRECTORY) {
				child_delete_result = remove_directory_recursive(child);					
			} else {
				child_delete_result = child.delete();
			}
			if (child_delete_result == false)
				return false;
		}
		return directory.delete();
	}
}
