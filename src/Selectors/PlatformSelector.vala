using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class PlatformSelector : Selector
{
	Gee.List<Platform> items;

	public PlatformSelector(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		rebuild_items(-1);
	}
	protected PlatformSelector.base(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
	}

	public Platform? selected_platform()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	public virtual bool select_platform(Platform? platform) {
		int index = 0;		
		foreach(var item in items) {
			if (item == platform)
				return select_item(index);
		}
		return false;			
	}
	
	protected override void rebuild_items(int selection_index) {
		items = Data.platforms().get_all_platforms().to_list();
	}

	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) { return items[index].name + "/"; }
	protected override string get_item_full_name(int index) { return get_item_name(index); }
}
