using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Data.Platforms;

public class PlatformFolderSelector : PlatformSelector
{
	Gee.List<PlatformListNode> items;
	PlatformFolder? _folder;
	public PlatformFolderSelector(PlatformFolder folder, string id, int16 xpos, int16 ypos) {
		base.base(id, xpos, ypos);
		_folder = folder;
		rebuild_items(-1);
	}
	public PlatformFolderSelector.root(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
	}
	
	public PlatformFolder? folder { get { return _folder; } }

	public PlatformListNode? selected_node()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	public override bool select_platform(Platform? platform) {
		int index = 0;
		foreach(var node in items) {
			var platform_node = node as PlatformNode;
			if (platform_node != null && platform_node.platform == platform)
				return select_item(index);
			index++;
		}
		return false;
	}
	
	protected override void rebuild_items(int selection_index) {
		var node = (selection_index != -1) ? items[selection_index] : null;
		var previous_selection_name = (node != null) ? node.name : null;		
		items = new ArrayList<PlatformListNode>();
		if (folder == null) {
			var data = Data.platforms().get_platform_folder_data();
			items.add_all(data.folders);
			items.add_all(data.platforms);
		}
		else {
			items = new Enumerable<PlatformNode>(folder.folders).concat(new Enumerable<PlatformListNode>(folder.platforms)).to_list();
		}
		int new_index = -1;
		if (previous_selection_name != null) {
			for(int index=0;index<items.size;index++) {
				var item = items[index];
				if (item.name == previous_selection_name) {
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
		return (item is PlatformFolder) ? item.name + "/" : item.name + " >";
	}
	protected override string get_item_full_name(int index) { return get_item_name(index); }
}
