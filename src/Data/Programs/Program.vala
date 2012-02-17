using Catapult;
using Fields;
using Menus;
using Menus.Fields;
using Data.Options;
using Data.Programs;
using Data.Pnd;

public class Program : Entity, MenuObject
{
	construct {
		options = new OptionSet();
		default_settings = new ProgramDefaultSettings();
	}
	
	public AppIdType app_id_type { get; set; }
	public string? app_id { 
		get { return _app_id; }
		set {
			_app_id = value;
			_apps = null;
		}
	}
	string? _app_id;
		
	public string custom_command { get; set; }
	public OptionSet options { get; set; }
	public ProgramDefaultSettings default_settings { get; set; }
	
	public string name { 
		get { 
			if (_name == null) {
				var app = get_app();
				if (app != null)
					_name = app.title;
				else if (app_id != null)
					_name = "(%s)".printf(app_id);
				else 
					_name = "(Unknown)";					
			}
			return _name;
		}
		set { _name = (value != "") ? value : null; }
	}
	string _name;

	public AppItem? get_app() {
		return get_matching_apps().first();
	}
	public Enumerable<AppItem> get_matching_apps() {
		if (_apps == null) {
			if (_app_id == null || _app_id == "")
				_apps = Enumerable.empty<AppItem>();
			else 
				_apps = Data.pnd_data().get_matching_apps(_app_id, app_id_type);
		}
		return _apps;
	}
	Enumerable<AppItem> _apps;
	
	public string get_arguments(ProgramSettings? settings=null) {
		default_settings.print("Default Settings");
		var effective = new ProgramSettings();
		effective.merge_override(default_settings);
		if (settings != null)
			effective.merge_override(settings);
		
		return options.get_option_string_from_settings(effective, default_settings.extra_arguments);
	}
	public uint get_clockspeed(ProgramSettings? settings=null) {
		uint clockspeed = 0;
		if (settings != null)
			clockspeed = settings.clockspeed;
		if (clockspeed == 0)
			clockspeed = default_settings.clockspeed;
		if (clockspeed == 0) {
			var app = get_app();
			if (app != null)
				clockspeed = app.clockspeed;
		}
		return clockspeed;
	}
	
	// yaml
	protected override string generate_id() {		
		return app_id ?? "";
	}
	
	// menu
	protected void build_menu(MenuBuilder builder) {
		name_field = builder.add_string("name", "Name", null, this.name);

		app_id_type_field = builder.add_enum("app_id_type", "App Id Type", null, app_id_type);
		
		app_id_field = new ProgramAppIdField("app_id", "App Id", null, app_id_type, app_id);
		builder.add_field(app_id_field);
		
		custom_command_field = new CustomCommandField("custom_command", "Command", null, this, custom_command);
		builder.add_field(custom_command_field);
						
		options_field = new ProgramOptionsListField("options", "Options", null, options);
		builder.add_field(options_field);
		
		default_setting_field = new ProgramDefaultSettingsField("default_settings", "Default Settings", null, this, default_settings);
		builder.add_field(default_setting_field);
		
		initialize_fields();
	}
	void initialize_fields() {
		app_id_type_field.changed.connect(() => {
			app_id_field.app_id_type = (AppIdType)app_id_type_field.value;
		});
		app_id_field.changed.connect(() => {
			var app = Data.pnd_data().get_app(app_id_field.value, null, app_id_field.app_id_type);
			if (app != null) {
				if (app_id_field.app_id_type == AppIdType.EXACT) {
					name_field.value = app.title;
					default_setting_field.set_clockspeed(app.clockspeed);
					default_setting_field.set_extra_arguments(app.exec_arguments ?? "");
				}
				if (name_field.value == "(Unknown)")
					name_field.value = app.title;
			}
			custom_command_field.app = app;
		});
		name_field.changed.connect(() => {
			custom_command_field.set_program_name(name_field.value);
		});
	}
	protected bool apply_menu(Menu menu) {
		if (name_field.has_changes())
			name = name_field.value.strip();
		if (app_id_type_field.has_changes())
			app_id_type = (AppIdType)app_id_type_field.value;
		if (app_id_field.has_changes())
			app_id = app_id_field.value;
		if (custom_command_field.has_changes())
			custom_command = custom_command_field.value;
		if (options_field.has_changes())
			options = options_field.options();			
		return true;
	}
	protected bool save_object(Menu menu) {
		string? error;
		if (Data.programs().save_program(this, generate_id(), out error) == false) {
			menu.error(error);
			return false;
		}
		return true;
	}
	protected void release_fields() {
		name_field = null;
		app_id_type_field = null;
		app_id_field = null;
		custom_command_field = null;
		options_field = null;
		default_setting_field = null;
	}
	
	StringField name_field;
	EnumField app_id_type_field;
	ProgramAppIdField app_id_field;
	CustomCommandField custom_command_field;
	ProgramOptionsListField options_field;
	ProgramDefaultSettingsField default_setting_field;
}
