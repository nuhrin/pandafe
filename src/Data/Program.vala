using Catapult;

public class Program : NamedEntity
{
	public string pnd_id { get; set; }
	public string pnd_app_id { get; set; }
	public string exe_path { get; set; }

	public string options { get; set; }
	public uint clockspeed { get; set; }
}
