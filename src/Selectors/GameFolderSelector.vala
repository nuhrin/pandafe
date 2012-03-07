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
		_folder.rescanned.connect(() => rebuild());
		items = _folder.children().to_list();
	}

	public GameFolder folder { 
		get { return _folder; } 
		set {
			_folder = value;
			_folder.rescanned.connect(() => rebuild());
			rebuild();
		}
	}

	public IGameListNode? selected_item()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items(int selection_index) {
		var node = (selection_index != -1) ? items[selection_index] : null;
		var previous_selection_id = (node != null) ? node.id : null;
		items = _folder.children().to_list();
		int new_index = -1;
		if (previous_selection_id != null) {
			for(int index=0;index<items.size;index++) {
				var item = items[index];
				if (item.id == previous_selection_id) {
					new_index = index;
					break;
				}
			}
		}
		if (new_index != -1)
			select_item(new_index, false);
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
