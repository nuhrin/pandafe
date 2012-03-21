using Catapult;
using Menus;
using Menus.Fields;

namespace Data.Options
{
	public abstract class Option : Object, MenuObject
	{
		const string NAME_CHARACTER_REGEX = "[[:alnum:] ]";
		weak OptionSet _parent;
		public Option(OptionSet parent) {
			_parent = parent;
		}
		
		public weak OptionSet parent { get { return _parent; } }
		
		public string name { get; set; }
		public string? help { get; set; }		
		public bool locked { get; set; }
		public string option { get; set; }
		
		public abstract OptionType option_type { get; }
		
		public unowned string setting_name { 
			get  {
				if (_setting_name != null)
					return _setting_name;
				return name;
			}
		}
		public virtual void set_setting_prefix(string prefix) { _setting_name = prefix + name; }
		string? _setting_name;		
		
		// menu
		protected virtual void build_menu(MenuBuilder builder) {
			add_name_field(name, builder);
			builder.add_string("option", "Option", "-o, --option, etc", option ?? "");
			build_edit_fields(builder);			
			builder.add_bool("locked", "Locked", "If true, games cannot change this setting.", locked);
			builder.add_string("help", "Help", "Help text to display during option selection", help ?? "");
		}
		protected abstract void build_edit_fields(MenuBuilder builder);
		protected static void add_name_field(string? name, MenuBuilder builder) {
			var name_field = builder.add_string("name", "Name", null, name ?? "", NAME_CHARACTER_REGEX);
			name_field.required = true;
		}
		protected virtual bool apply_changed_field(Menus.Menu menu, MenuItemField field) { return false; }

		// field
		public abstract MenuItemField get_setting_field(string? setting);
		public abstract string get_setting_value_from_field(MenuItemField field);
		
		// 
		public abstract string get_option_from_setting_value(string? setting);
		
		// yaml
		internal virtual void populate_yaml_mapping(Yaml.NodeBuilder builder, Yaml.MappingNode mapping) {
			builder.populate_object_mapping(mapping, this);
		}
		internal virtual void post_yaml_load() { }
	}
}
