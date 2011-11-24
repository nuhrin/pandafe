using Gee;
using SDL;
using SDLTTF;
using Data.GameList;

public class EverythingSelector : Selector {

	public EverythingSelector(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
	}

	Gee.List<GameItem> items {
		get {
			if (_items == null) {
				_items = new ArrayList<GameItem>();
				var platforms = Data.platforms();
				foreach(var platform in platforms) {
					var platform_games = platform.get_root_folder().all_games().to_list();
					_items.add_all(platform_games);
				}
				_items.sort();
			}
			return _items;
		}
	}
	Gee.List<GameItem> _items;

	public GameItem? selected_game() {
		if (selected_index < 0)
			return null;
		return items[selected_index];
	}

	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) {
		return items[index].name;
	}
	protected override string get_item_full_name(int index) {
		return items[index].full_name;
	}
}
