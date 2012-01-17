using Gee;
using SDL;
using SDLTTF;
using Layers;
using Layers.Controls.Chooser;
using Layers.MenuBrowser;

namespace Layers.Controls
{
	public class FileChooser : ChooserBase
	{		
		const RegexCompileFlags REGEX_COMPILE_FLAGS = RegexCompileFlags.OPTIMIZE | RegexCompileFlags.CASELESS |
													  RegexCompileFlags.MULTILINE | RegexCompileFlags.NEWLINE_LF;
		const RegexMatchFlags REGEX_MATCH_FLAGS = RegexMatchFlags.NEWLINE_LF;
		const string SELECTOR_ID = "file_selector";
				
		string root_path;
		string? selected_path;
		Regex? regex_file_filter;

		public FileChooser(string id, string title, string? file_extensions=null, string? root_path=null) {			
			base(id, title);
			if (root_path != null && FileUtils.test(root_path, FileTest.IS_DIR) == true)
				this.root_path = root_path;
			else
				this.root_path = "/";
									
			if (file_extensions != null)
				regex_file_filter = get_file_extensions_regex(file_extensions);			
		}

		protected override string get_first_run_key(string starting_key) { 
			if (starting_key.has_prefix(root_path) == true) {
				if (FileUtils.test(starting_key, FileTest.IS_DIR))
					return Path.get_dirname(starting_key);
				return starting_key;
			}
			return root_path;
		}
		protected override uint get_first_run_selection_index(string starting_key) {
			if (FileUtils.test(starting_key, FileTest.IS_DIR))
				return 0;
			return get_index_of_item_named(Path.get_basename(starting_key));
		}
		protected override string? get_run_result() { return selected_path; }
		
		protected override ChooserSelector create_selector(string key, int16 xpos, int16 ypos) {
			return new FileSelector(SELECTOR_ID, xpos, ypos, key, regex_file_filter, (key == root_path));
		}
				
		protected override void update_header(ChooserHeader header, ChooserSelector selector) {
			header.path = ((FileSelector)selector).path;
		}
		protected override bool process_activation(ChooserSelector selector) {
			var file_selector = (FileSelector)selector;
			if (file_selector.is_folder_selected == false) {
				// choose this this
				selected_path = file_selector.selected_path();				
				return true;
			}
			return false;
		}
		protected override string get_selected_key(ChooserSelector selector) { return ((FileSelector)selector).selected_path(); }
		protected override string get_parent_key(ChooserSelector selector) { return Path.get_dirname(((FileSelector)selector).path); }
		protected override string get_parent_child_name(ChooserSelector selector) { 
			return Path.get_basename(((FileSelector)selector).path) + Path.DIR_SEPARATOR_S; 
		}

		
		Regex? get_file_extensions_regex(string file_extensions) {
			var parts = file_extensions.split_set(" .;,");
			var exts = new ArrayList<string>();
			foreach(var part in parts) {
				part = part.strip();
				if (part != "")
					exts.add(part);
			}
			if (exts.size == 0)
				return null;

			try {
				if (exts.size == 1)
					return new Regex("\\.%s$".printf(exts[0]), REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);

				var sb = new StringBuilder("\\.(");
				bool have_first = false;
				foreach(var ext in exts) {
					if (have_first == true) {
						sb.append("|");
						sb.append(ext);
					} else {
						sb.append(ext);
						have_first = true;
					}
				}
				sb.append(")$");
				return new Regex(sb.str, REGEX_COMPILE_FLAGS, REGEX_MATCH_FLAGS);
			} catch(RegexError e) {
				debug("Error creating file extension regex: %s", e.message);
			}
			return null;
		}

	}
}
