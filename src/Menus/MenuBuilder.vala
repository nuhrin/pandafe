using Gee;
using Catapult;
using Fields;
using Menus.Fields;

namespace Menus
{
	public class MenuBuilder 
	{
		Gee.List<MenuItemField> _fields;
		Gee.List<MenuItem> _actions;
		public MenuBuilder() {
			_fields = new ArrayList<MenuItemField>();			
		}
		public Enumerable<MenuItemField> fields() { return new Enumerable<MenuItemField>(_fields); }
		public Enumerable<MenuItem> actions() { 
			return (_actions == null)
				? Enumerable.empty<MenuItem>()
				: new Enumerable<MenuItem>(_actions);
		}
		public bool has_action { get { return (_actions != null); } }

		public void add_cancel_item(string? name=null, string? help=null) { add_action(new MenuItem.cancel_item(name, help)); }			
		public void add_save_item(string? name=null, string? help=null) { add_action(new MenuItem.save_item(name, help)); }
		public void add_save_and_quit_item(string? name=null, string? help=null) { add_action(new MenuItem.save_and_quit_item(name, help)); }
		public void add_quit_item(string? name=null, string? help=null) { add_action(new MenuItem.quit_item(name, help)); }
		void add_action(MenuItem action) { 
			if (_actions == null)
				_actions = new ArrayList<MenuItem>();
			_actions.add(action); 
		}
		
		public MenuItemField add_field(MenuItemField field) {
			_fields.add(field);
			return field;
		}
		public BooleanField add_bool(string id, string name, string? help=null, bool value=false, string true_value="true", string false_value="false") {
			return (BooleanField)add_field(new BooleanField(id, name, help, value, true_value, false_value));
		}
		public ColorField add_color(string id, string name, string? help=null, Data.Color? color=null) {
			return (ColorField)add_field(new ColorField(id, name, help, color));
		}
		public EnumField add_enum(string id, string name, string? help=null, Value enum_value) {
			return (EnumField)add_field(new EnumField(id, name, help, enum_value));
		}
		public FileField add_file(string id, string name, string? help=null, string? path=null, string? file_extensions=null, string? root_path=null) {
			return (FileField)add_field(new FileField(id, name, help, path, file_extensions, root_path));
		}
		public FolderField add_folder(string id, string name, string? help=null, string? path=null, string? root_path=null) {
			return (FolderField)add_field(new FolderField(id, name, help, path, root_path));
		}
		public IntegerField add_int(string id, string name, string? help=null, int value, int min_value, int max_value, uint step=1) {
			return (IntegerField)add_field(new IntegerField(id, name, help, value, min_value, max_value, step));
		}
		public ObjectField add_object(string id, string name, string? help=null, Object obj) {
			return (ObjectField)add_field(new ObjectField(id, name, help, obj));
		}
		public StringField add_string(string id, string name, string? help=null, string? value=null, string? character_mask_regex=null, string? value_mask_regex=null) {
			return (StringField)add_field(new StringField(id, name, help, value, character_mask_regex, value_mask_regex));
		}
		public StringSelectionField add_string_selection(string id, string name, string? help=null, Iterable<string>? items=null, string? value=null) {
			return (StringSelectionField)add_field(new StringSelectionField(id, name, help, items, value));
		}
		public UIntField add_uint(string id, string name, string? help=null, uint value, uint min_value, uint max_value, uint step=1) {
			return (UIntField)add_field(new UIntField(id, name, help, value, min_value, max_value, step));
		}
		
		public void add_object_properties(Object obj) {			
			unowned ObjectClass klass = obj.get_class();
	    	var properties = klass.list_properties();
	    	foreach(var prop in properties)
				add_object_property(obj, prop);
		}
		public MenuItemField? add_object_property_by_name(Object obj, string property_name) {
			ParamSpec property = ((ObjectClass)obj.get_type().class_peek()).find_property(property_name);
			if (property != null)
				return add_object_property(obj, property);
			return null;
		}
		string GetPropertyLabel(ParamSpec property) {
			string label = property.get_nick().chug();
			if (label == "")
				label = property.name;
			return label;
		}
		public MenuItemField? add_object_property(Object obj, ParamSpec property) {
			if (((property.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE) == false)
				return null;
			Type type = property.value_type;
			Value value = Value(type);
			obj.get_property(property.name, ref value);
			if (value.holds(type) == false)
			   return null;
			if (type.is_a(typeof(bool)))
				return add_bool(property.name, GetPropertyLabel(property), null, (bool)value);
			if (type.is_enum())
				return add_enum(property.name, GetPropertyLabel(property), null, value);
			if (type.is_a(typeof(string)))
				return add_string(property.name, GetPropertyLabel(property), null, ((string)value) ?? "");
//~ 			if (type.is_flags())
//~ 				return add_flags(property.name, GetPropertyLabel(property), value);
			if (type.is_a(typeof(uint)))
				return add_uint(property.name, GetPropertyLabel(property), null, (uint)value, 0, uint.MAX);
			if (type.is_a(typeof(Data.Color)))
				return add_color(property.name, GetPropertyLabel(property), null, (Data.Color)value);
			var intProp = property as ParamSpecInt;
			if (intProp != null)
				return add_int(property.name, GetPropertyLabel(property), null, (int)value, intProp.minimum, intProp.maximum);
//~ 			var doubleProp = property as ParamSpecDouble;
//~ 			if (doubleProp != null)
//~ 				return add_double(property.name, GetPropertyLabel(property), (double)value, doubleProp.minimum, doubleProp.maximum);
			if (type.is_object())
				return add_object(property.name, GetPropertyLabel(property), null, value.get_object());

			debug("unsupported property type: %s", property.value_type.name());
			return null;
		}
	}
}
