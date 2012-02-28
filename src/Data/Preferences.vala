using Gee;
using Catapult;
namespace Data
{
	public class Preferences : Entity
	{
		const string DEFAULT_FONT_PATH  = "/usr/share/fonts/truetype/";
		const string DEFAULT_FONT = "/usr/share/fonts/truetype/DejaVuSansMono.ttf";

		internal const string ENTITY_ID = "preferences";
		protected override string generate_id() { return ENTITY_ID; }

		construct {
			font = DEFAULT_FONT;
			platform_order = new ArrayList<string>();
			// default colors
			Data.Color color;
			if (Data.Color.parse("#ffffffffffff", out color) == true)
				item_color = color; // white
			if (Data.Color.parse("#00006464ffff", out color) == true)
				selected_item_color = color; // blue-green
		}

		public string font { get; set; }
		public Data.Color background_color { get; set; }
		public Data.Color item_color { get; set; }
		public Data.Color selected_item_color { get; set; }
		public Gee.List<string> platform_order { get; set; }

		public void update_platform_order(Iterable<Platform> platforms) {
			platform_order.clear();
			foreach(var platform in platforms)
				platform_order.add(platform.id);
		}
	}
}
