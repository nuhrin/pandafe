using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class GameFolderSelector : Selector
{
	GameFolder folder;
	Gee.List<GameListNode> items;

	public GameFolderSelector(GameFolder folder, InterfaceHelper @interface) {
		base(@interface);
		this.folder = folder;
		items = folder.children().to_list();
	}

	public bool is_go_back_selected() {
		return (selected_index == 0);
	}

	public GameListNode? selected_item()
	{
		if (selected_index < 1)
			return null;
		return items[selected_index-1];
	}

	protected override int get_itemcount() { return items.size + 1; }
	protected override string get_item_name(int index) {
		if (index == 0)
			return "../";

		var item = items[index-1];
		return (item is GameFolder) ? item.name + "/" : item.name;
	}
	protected override string get_item_full_name(int index) {
		if (index == 0)
			return "../";

		var item = items[index-1];
		return (item is GameFolder) ? item.name + "/" : item.full_name;
	}
}
