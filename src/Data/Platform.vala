using Gee;
using YamlDB;

public enum PlatformType {
	ROM,

}
public class Platform : NamedEntity
{
	public PlatformType platform_type;

	public string rom_folder_root { get; set; }
	public string rom_filespec { get; set; }

	public Gee.List<Program> programs { get; set; }
	public Program default_program { get; set; }
}
