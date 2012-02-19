using SDL;

namespace Menus
{
	public interface SubMenuItem : MenuItem
	{	
		public abstract Menu menu { get; }
		
		public signal void cancelled();
		public signal void saved();
		public signal void finished();		
	}
}
