using Gee;
using SDL;
using SDLTTF;
using Catapult;
using Data.Platforms;

public class PlatformFolderSelector : Selector
{
	Gee.List<PlatformListNode> items;
	PlatformFolder? _folder;
	public PlatformFolderSelector(PlatformFolder folder, string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		_folder = folder;
		rebuild();
	}
	public PlatformFolderSelector.root(string id, int16 xpos, int16 ypos) {
		base(id, xpos, ypos);
		rebuild();
	}
	
	public PlatformFolder? folder { get { return _folder; } }

	public PlatformListNode? selected_node()
	{
		if (selected_index == -1)
			return null;
		return items[selected_index];
	}
	
	protected override void rebuild_items() {
		if (folder == null)
			items = Data.platforms().get_platform_folder_data().folders;
		else
			items = new Enumerable<PlatformListNode>(folder.folders)
				.concat(new Enumerable<PlatformListNode>(folder.platforms))
				.to_list();
	}

	protected override int get_itemcount() { return items.size; }
	protected override string get_item_name(int index) { 
		var item = items[index];
		return (item is PlatformFolder) ? item.name + "/" : item.name + " >";
	}
	protected override string get_item_full_name(int index) { return get_item_name(index); }
}
