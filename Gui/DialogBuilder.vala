using YamlDB;
using yayafe.Gui.Fields;

namespace yayafe.Gui
{
	public class DialogBuilder
	{
		DataInterface data_interface;
		Fieldset labeledFields;
		
		public DialogBuilder(DataInterface data_interface) {
			this.data_interface = data_interface;
			labeledFields = new Fieldset();
		}

		// labeled field methods
		//public Enumerable<LabeledField> labeled_fields() { return labeledFields.enumerable().of_type<LabeledField>(); }
		public Fieldset labeled_fields() { return labeledFields; }

		public void add_labeled(LabeledField field) {
			labeledFields.add(field);
		}
		public BooleanField add_bool(string name, string? label=null, bool checked=false) {
			var field = new BooleanField(name, label, checked);
			labeledFields.add(field);
			return field;
		}
		public IntegerField add_int(string name, string? label=null, int value=0, int min=int.MIN, int max=int.MAX) {
			var field = new IntegerField(name, label, value, min, max);
			labeledFields.add(field);
			return field;
		}
		public DoubleField add_double(string name, string? label=null, double value=0, double min=double.MIN, double max=double.MAX, uint digits=2) {
			var field = new DoubleField(name, label, value, min, max, digits);
			labeledFields.add(field);
			return field;
		}
		public StringField add_string(string name, string? label=null, string value="") {
			var field = new StringField(name, label, value);
			labeledFields.add(field);
			return field;
		}
		public EnumField add_enum(string name, string? label=null, Value enum_value)
			requires(enum_value.type().is_enum())
		{
			var field = new EnumField(name, label, enum_value);
			labeledFields.add(field);
			return field;
		}
		public FlagsField add_flags(string name, string? label=null, Value flags_value)
			requires(flags_value.type().is_flags())
		{
			var field = new FlagsField(name, label, flags_value);
			labeledFields.add(field);
			return field;
		}

		public void add_object_properties(Object obj) {
			unowned ObjectClass klass = obj.get_class();
	    	var properties = klass.list_properties();
	    	foreach(var prop in properties)
				add_object_property(obj, prop);
		}
		public LabeledField? add_object_property_by_name(Object obj, string property_name) {
			ParamSpec property = ((ObjectClass)obj.get_type().class_peek()).find_property(property_name);
			if (property != null)
				return add_object_property(obj, property);
			return null;
		}
		string GetPropertyLabel(ParamSpec property) {
			string label = property.get_nick().chug();
			if (label == "")
				label = property.name;
			if (label.index_of_char('_') < 0)
				label = "_" + label;
			return label;
		}
		public LabeledField? add_object_property(Object obj, ParamSpec property) {
			if (((property.flags & ParamFlags.READWRITE) == ParamFlags.READWRITE) == false)
				return null;
			Type type = property.value_type;
			Value value = Value(type);
			obj.get_property(property.name, ref value);
			if (value.holds(type) == false)
				return null;
			if (type.is_a(typeof(GuiEntity))) {
				GuiEntity entity = (GuiEntity)value;
				return entity.i_get_reference_selection_field(data_interface);
			}
			if (type.is_a(typeof(string)))
				return add_string(property.name, GetPropertyLabel(property), ((string)value) ?? "");
			if (type.is_a(typeof(bool)))
				return add_bool(property.name, GetPropertyLabel(property), (bool)value);
			if (type.is_enum())
				return add_enum(property.name, GetPropertyLabel(property), value);
			if (type.is_flags())
				return add_flags(property.name, GetPropertyLabel(property), value);
			var intProp = property as ParamSpecInt;
			if (intProp != null)
				return add_int(property.name, GetPropertyLabel(property), (int)value, intProp.minimum, intProp.maximum);
			var doubleProp = property as ParamSpecDouble;
			if (doubleProp != null)
				return add_double(property.name, GetPropertyLabel(property), (double)value, doubleProp.minimum, doubleProp.maximum);

			debug("unsupported property type: %s", property.value_type.name());
			return null;
		}




		
	}
}