using Gee;
using Catapult;
using Fields;
using Menus;
using Menus.Fields;

namespace Data.Platforms
{
	public class PlatformNode : Object, PlatformListNode
	{
		PlatformFolder _parent;
		public PlatformNode(Platform platform, PlatformFolder? parent) {
			this.platform = platform;
			_parent = parent;
		}
		
		public string name { 
			get { return platform.name; }
			set { assert_not_reached(); }
		}
		
		public Platform platform { get; private set; }		
		public PlatformFolder? parent { get { return _parent; } }
	}
}
