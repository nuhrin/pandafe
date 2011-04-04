using YamlDB;
using Gtk;

namespace yayafe.Gui.Fields
{
//	public class EntityReferenceField<TEntity> : LabeledField
//	{
//		DataInterface data_interface;
//		public EntityReferenceField(DataInterface data_interface, string name, string? label=null, TEntity value=null) {
//			base(name, label);
//			this.data_interface = data_interface;
//			this.value = value;
//		}
//		public new string value
//		{
//			get { return entry.text; }
//			set { entry.text = value; }
//		}
//		protected override Value get_field_value() { return entry.text; }
//		protected override void set_field_value(Value value) { entry.text = (string)value; }
//
//		protected override Widget target_widget { get { return entry; } }
//
//		ComboBox combo {
//			get {
//				if (_combo == null) {
//					_combo = new ComboBox.text();
//					_combo.changed.connect(() => this.changed());
//				}
//				return _entry;
//			}
//		}
//		ComboBox _combo;
//	}
}