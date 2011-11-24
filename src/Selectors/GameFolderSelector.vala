using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class GameFolderSelector : Selector
{
	GameFolder folder;
	Gee.List<IGameListNode> items;

	public GameFolderSelector(GameFolder folder, string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		this.folder = folder;
		items = folder.children().to_list();
	}

	public IGameListNode? selected_item()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}

	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) {
		var item = items[index];
		return (item is GameFolder) ? item.name + "/" : item.name;
	}
	protected override string get_item_full_name(int index) {
		var item = items[index];
		return (item is GameFolder) ? item.name + "/" : item.full_name;
	}
}
