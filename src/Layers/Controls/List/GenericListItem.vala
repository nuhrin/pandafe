using Gee;

namespace Layers.Controls.List
{
	public class GenericListItem<G> : ListItem<G>
	{	
		MapFunc<string?, G> get_name_string;
		
		public GenericListItem(G value, owned MapFunc<string?, G> get_name_string) {
			base(value);
			this.get_name_string = (owned)get_name_string;
		}				
		
		public override unowned string name {
			get {
				if (_name == null)
					_name = get_name_string(get_unowned_value()) ?? "";
				return _name;
			}
		}
		string _name;
		protected override void on_value_set() {
			_name = null;
		}
	}
}
