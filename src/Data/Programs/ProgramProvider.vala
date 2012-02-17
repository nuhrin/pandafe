using Gee;
using Catapult;
using Data.Pnd;

namespace Data.Programs
{
	public class ProgramProvider : EntityProvider<Program>
	{
		HashMap<string,Program> program_id_hash;
		HashMap<string,Program> program_app_id_hash;
		public ProgramProvider(string root_folder) throws RuntimeError
		{
			base(root_folder);			
		}
		
		public Program? get_program(string id) {
			ensure_programs();
			if (program_id_hash.has_key(id) == true)
				return program_id_hash[id];
			return null;			
		}
		public Program get_program_for_app(string app_id) {
			ensure_programs();
			if (program_app_id_hash.has_key(app_id) == true)
				return program_app_id_hash[app_id];
				
			foreach(var program in program_id_hash.values) {
				foreach(var app in program.get_matching_apps()) {
					if (app.id == app_id)
						return program;
				}
			}
			
			var app = Data.pnd_data().get_app(app_id);
			var program = new Program() {
				app_id = app_id
			};
			if (app != null) {
				program.default_settings.extra_arguments = app.exec_arguments ?? "";
				program.default_settings.clockspeed = app.clockspeed;
			}
			return program;
		}
		
		public bool save_program(Program program, string id, out string? error) {			
			error = null;
			if (id.strip() == "") {
				error = "Bad app_id";
				return false;
			}
			if (program.id != id && program_id_hash.has_key(id) == true) {
				error = "Conflict with existing program (id %s)".printf(id);
				return false;
			}
						
			string? original_id = program.id;
			bool needs_app_id_rebuild = false;
			if (original_id != null && original_id != id) {
				// safe rename: remove existing program
				try {
					remove(program);
					needs_app_id_rebuild = true;
				} catch {
				}				
			}
			
			try {
				save(program, id);
				needs_app_id_rebuild = true;
			} catch(Error e) {
				error = e.message;
				return false;				
			}

			if (needs_app_id_rebuild == true && program_id_hash.has_key(original_id) == true)
				program_id_hash.unset(original_id);
			program_id_hash[id] = program;
			if (needs_app_id_rebuild)
				rebuild_app_id_hash();			
			return true;
		}
		
		protected override Entity? get_entity(string entity_id) {
			var program = get_program(entity_id);
			if (program == null)
				program = get_program_for_app(entity_id);
			
			return program;
		}
		
		void ensure_programs() {
			if (program_id_hash != null)
				return;
			program_id_hash = new HashMap<string,Program>();
			program_app_id_hash = new HashMap<string,Program>();
			Enumerable<Program> programs = null;
			try {
				programs = load_all(false);
			} catch(Error e) {
			}
			foreach(var program in programs) {
				program_id_hash[program.id] = program;
				if (program.app_id != null)
					program_app_id_hash[program.app_id] = program;
				
			}
		}
		void rebuild_app_id_hash() {
			program_app_id_hash = new HashMap<string,Program>();
			foreach(var program in program_id_hash.values) {
				if (program.app_id != null)
					program_app_id_hash[program.app_id] = program;
			}
		}
	}	
}
