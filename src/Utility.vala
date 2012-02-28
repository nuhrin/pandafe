
public class Utility
{
	public static CompareFunc<string> strcasecmp { get { return _strcasecmp; } }	
	static int _strcasecmp(string a, string b) {
		return a.casefold().collate(b.casefold());
	}
}
