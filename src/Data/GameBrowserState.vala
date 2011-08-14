using Gee;
using Catapult;
using Catapult.Gui;
using Catapult.Gui.Fields;
using Catapult.Gui.Fieldsets;

namespace Data
{
	public class GameBrowserState : Entity
	{
		internal const string ENTITY_ID = "browser_state";
		protected override string generate_id() { return ENTITY_ID; }

		public string platform { get; set; }
		public string folder_id { get; set; }
		public int item_index { get; set; }
	}
}
