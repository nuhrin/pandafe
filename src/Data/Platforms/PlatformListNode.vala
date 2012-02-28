namespace Data.Platforms
{
	public interface PlatformListNode : Object
	{
		public abstract string name { get; set; }
		public abstract PlatformFolder? parent { get; }
		
		public string path() { 
			if (parent == null)
				return name;
			return Path.build_path("/", parent.path(), name);
		}
	}
}
