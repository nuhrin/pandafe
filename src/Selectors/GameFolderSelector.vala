using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class GameFolderSelector : Selector
{
	GameFolder _folder;
	Gee.List<IGameListNode> items;

	public GameFolderSelector(GameFolder folder, string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		_folder = folder;
		rebuild_items();
	}

	public GameFolder folder { 
		get { return _folder; } 
		set {
			_folder = value;
			rebuild();
		}
	}

	public IGameListNode? selected_item()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items() {
		items = _folder.children().to_list();
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
