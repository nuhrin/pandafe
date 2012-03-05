using Gee;
using SDL;
using Catapult;
using Menus;
using Menus.Fields;
using Layers.Controls;
using Layers.Controls.List;

namespace Data.Options
{
	public class MultipleChoiceOption : Option
	{
		construct {
			choices = new ArrayList<Choice>();
			default_choice_index = -1;
		}
		public override OptionType option_type { get { return OptionType.MULTIPLE_CHOICE; } }
		public Gee.List<Choice> choices { get; set; }
		public int default_choice_index { get; set; }
		
		// menu
		protected override void build_edit_fields(MenuBuilder builder) {			
			choices_field = new ChoiceListField("choices", "Choices", null, choices);
			choices_field.add_validator(value => ((Gee.List<Choice>)value).size > 1, "Choices must have at least two items.");
			builder.add_field(choices_field);			
			default_choice_field = new DefaultChoiceField("default_choice_index", "Default Choice", null, choices, default_choice_index);
			builder.add_field(default_choice_field);
			
			choices_field.changed.connect(() => {
				default_choice_field.set_choices(choices_field.value);
			});
		}
		protected void release_fields() {
			choices_field = null;
			default_choice_field = null;
		}
		ChoiceListField choices_field;
		DefaultChoiceField default_choice_field;
		
		// setting field
		public override MenuItemField get_setting_field(string? setting) {
			var names = new Enumerable<Choice>(choices).select<string>(c=>c.name);
			var choice = get_setting_choice(setting);						
			if (choice == null && default_choice_index >= 0 && default_choice_index < choices.size)
				choice = choices[default_choice_index];
			return new StringSelectionField(name, name, help, names, (choice != null) ? choice.name : null);			
		}
		public override string get_setting_value_from_field(MenuItemField field) {
			string name = (field as StringSelectionField).value;
			foreach(var choice in choices) {
				if (choice.name == name)
					return choice.get_setting_value();
			}
			return "";
		}
		public override string get_option_from_setting_value(string? setting) {
			string choice_option = get_choice_option_from_setting_value(setting);
			if (choice_option != "")
				return option + choice_option;
			return "";
		}
		string get_choice_option_from_setting_value(string? setting) {
			if (setting == null) {
				if (choices.size > 0 && default_choice_index >= 0 && default_choice_index < choices.size)
					return choices[default_choice_index].option;
				return "";
			}
			var choice = get_setting_choice(setting);
			if (choice != null)
				return choice.option;
			return "";
		}
		
		Choice? get_setting_choice(string? setting) {
			if (setting == null)
				return null;
			foreach(var choice in choices) {
				if (choice.get_setting_value() == setting)
					return choice;
			}
			
			return null;
		}
		
		public class Choice : Object, MenuObject
		{
			public string name { get; set; }
			public string option { get; set; }
			public string value { get; set; }
			
			public unowned string get_setting_value() { 
				if (value != null && value != "")
					return value;
				return name;
			}
			
			// menu
			protected virtual void build_menu(MenuBuilder builder) {
				Option.add_name_field(name, builder);
				builder.add_string("option", "Option", "-o, --option, etc (or option value for parent option)", option ?? "");
				builder.add_string("value", "Value", "Value to use in settings dictionary (optional)", value ?? "");				
			}
		}
		class ChoiceListField : ListField<Choice>
		{
			public ChoiceListField(string id, string name, string? help=null, Gee.List<Choice> value) {
				base(id, name, help, value);
				
			}

			protected override ListEditor<Choice> get_list_editor(string? title) {
				return new ChoiceListEditor(id, name, null, value, p=>p.name);
			}
			
			class ChoiceListEditor : ListEditor<Choice>
			{
				public ChoiceListEditor(string id, string name, string? help=null, Gee.List<Choice> list, owned MapFunc<string?, Choice> get_name_string) {
					base(id, name, help, list, (owned)get_name_string);
					save_on_return = true;
				}
				protected override bool create_item(Rect selected_item_rect, out Choice item) {
					item = new Choice() {
						name = ""
					};				
					return true;
				}
				protected override bool edit_list_item(ListItem<Choice> item, uint index) {
					return ObjectMenu.edit("Edit Choice", item.value);
				}
			}
		}
		class DefaultChoiceField : StringSelectionField 
		{
			public DefaultChoiceField(string id, string name, string? help=null, Gee.List<Choice> choices, int default_choice_index) {
				string? selected_name = null;
				if (choices.size > 0 && default_choice_index >= 0 && default_choice_index < choices.size)
					selected_name = choices[default_choice_index].name;
					
				var names = get_names(choices);
				base(id, name, help, names, selected_name);
			}
			
			public new int value {
				get { return (_selected_index < 1) ? -1 : _selected_index - 1; }
			}
			
			public void set_choices(Gee.List<Choice> choices) {
				base.set_items(get_names(choices));
			}
			
			static Iterable<string> get_names(Gee.List<Choice> choices) {
				var list = new ArrayList<string>();
				list.add("(None)");
				foreach(var choice in choices)
					list.add(choice.name);
				return list;
			}
			
			protected override Value get_field_value() { return this.value; }
			protected override void set_field_value(Value value) { 
				int v = (int)value;
				string? strv = null;
				if (v >= 0 && v < items.size)
					strv = items[v];
					
				base.set_field_value(strv);
			}		
		}
	}
}
