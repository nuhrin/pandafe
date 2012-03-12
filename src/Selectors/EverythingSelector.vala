using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class EverythingSelector : Selector {

	public EverythingSelector(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		Data.favorites().changed.connect(() => favorites_changed());
	}

	Gee.List<GameItem> items {
		get {
			if (_items == null) {
				_items = new ArrayList<GameItem>();
				var platforms = Data.platforms().get_all_platforms();
				foreach(var platform in platforms) {
					var platform_games = platform.get_root_folder().all_games();
					if (favorites_only == true)
						platform_games = platform_games.where(g=>g.is_favorite == true);					
					_items.add_all(platform_games.to_list());
				}
				_items.sort();
			}
			return _items;
		}
	}
	Gee.List<GameItem> _items;
	public bool favorites_only { get; private set; }
	
	public void show_favorites() {
		if (favorites_only == true)
			return;
		favorites_only = true;
		rebuild();
	}
	public void show_all() {
		if (favorites_only == false)
			return;
		favorites_only = false;
		rebuild();
	}
	void favorites_changed() {
		if (favorites_only == true)
			rebuild();
	}

	public GameItem? selected_game() {
		if (selected_index < 0)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items(int selection_index) {
		var node = (selection_index != -1) ? items[selection_index] : null;
		var previous_selection_id = (node != null) ? node.unique_id() : null;
		_items = null;
		int new_index = -1;
		if (previous_selection_id != null) {
			for(int index=0;index<items.size;index++) {
				var item = items[index];
				if (item.unique_id() == previous_selection_id) {
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
		return items[index].name;
	}
	protected override string get_item_full_name(int index) {
		return items[index].full_name;
	}
}
