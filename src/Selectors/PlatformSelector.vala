using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class PlatformSelector : Selector
{
	Gee.List<Platform> items;

	public PlatformSelector(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		rebuild();
	}

	public Platform? selected_platform()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items() {
		items = Data.platforms().get_all_platforms().to_list();
	}

	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) { return items[index].name + "/"; }
	protected override string get_item_full_name(int index) { return get_item_name(index); }
}
