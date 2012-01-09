using Gee;

namespace Layers.Controls.List
{
	public abstract class ListItem<G> : Object
	{			
		G _value;
		public ListItem(G value) {
			_value = value;			
		}				
		
		public G value {
			get { return _value; }
			set {
				_value = value;
				on_value_set();
			}
		}
		
		public abstract unowned string name { get; }
		
		protected virtual void on_value_set() { }
		protected unowned G get_unowned_value() { return _value; }				
	}
}
