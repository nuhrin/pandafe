
namespace Layers.Preview
{
	public class PreviewSelector : Selector 
	{
		static string[] items;
		static string[] get_items() { 
			return new string[] {
				"Item 1",
				"Selected Item",
				"Item 3",
				"Item 4"
//~ 				"Item 5",
//~ 					"Item 6",
//~ 					"Item 7",
//~ 					"Item 8",
//~ 					"Item 9",
//~ 					"Item 10"
			};
		}

		public PreviewSelector(int16 xpos, int16 ypos, GameBrowserUI ui) {
			base("preview_selector", xpos, ypos, ui);
			if (items == null)
				items = get_items();
			selected_index = 1;
		}

		protected override void rebuild_items() { }
		protected override int get_itemcount() { return items.length; }
		protected override string get_item_name(int index) { return items[index]; }
		protected override string get_item_full_name(int index) { return get_item_name(index); }
	}
}
