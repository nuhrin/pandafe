using Gee;

namespace Layers.Controls.List
{
	public class StringListItem : ListItem<string>
	{	
		public StringListItem(string value) {
			base(value);
		}		
		
		public override unowned string name { get { return get_unowned_value(); } }
	}	
}
