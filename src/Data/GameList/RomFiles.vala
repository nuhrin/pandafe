/* RomFiles.vala
 * 
 * Copyright (C) 2013 nuhrin
 * 
 * This file is part of Pandafe.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Author:
 *      nuhrin <nuhrin@oceanic.to>
 */

using Gee;
using Data.Platforms;

namespace Data.GameList
{
	public class RomFiles 
	{
		public static bool build_for_game(GameItem game, out RomFiles files, out string? error=null) {
			if (game.platform.platform_type != PlatformType.ROM)
				GLib.error("RomFiles is only applicable to games from Rom Based Platforms");
			
			files = null;
			Gee.ArrayList<string> filenames;
			if (get_game_filenames(game, out filenames, out error) == false) {
				return false;
			}
			if (filenames.size == 0) {
				error = "File does not exist";
				return false;
			}
			
			files = new RomFiles(game, filenames);			
			return true;
		}
		
		public unowned string rom_fullname { get { return _rom_fullname; } }
		public string unique_id() { return Path.build_filename(_folder_path, "%s.%s".printf(_rom_fullname, _primary_file_extension)); }
		
		public bool rename(string new_fullname, out string? error=null) {
			if (_processed == true)
				GLib.error("Invalid attempt to reuse RomFiles instance for '%s'.", game.id);
			_processed = true;			

			var move_set = new RomFileMoveSet.for_rename(_folder_path, rom_fullname, new_fullname, filenames);
			if (move_set.move(out error) == false) {
				move_set.revert();
				return false;
			}
			
			// update cue files, if necessary
			foreach(string new_filename in move_set.new_filenames()) {
				if (new_filename.down().has_suffix(".cue") == true)
					rewrite_cue_file(Path.build_filename(_folder_path, new_filename), rom_fullname, new_fullname);				
			}
			
			_rom_fullname = new_fullname;
			return true;
		}
		public bool move(string new_folder_path, out string? error=null) {
			if (_processed == true)
				GLib.error("Invalid attempt to reuse RomFiles instance for '%s'.", game.id);
			_processed = true;			
			
			var move_set = new RomFileMoveSet.for_move(_folder_path, new_folder_path, filenames);
			if (move_set.move(out error) == false) {
				move_set.revert();
				return false;
			}
			_folder_path = new_folder_path;
			return true;
		}
		public bool remove(out string? error=null) {
			if (_processed == true)
				GLib.error("Invalid attempt to reuse RomFiles instance for '%s'.", game.id);
			_processed = true;			
			
			error = null;		
			foreach(var filename in filenames) {
				var file = File.new_for_path(Path.build_filename(_folder_path, filename));					
				try {
					if (file.delete() == false) {
						error = filename + ": unable to delete file";
						return false;
					}					
				} catch (GLib.Error e) {
					error = "%s: %s".printf(filename, e.message);
					return false;
				}
			}
			return true;
		}
				
		RomFiles(GameItem game, ArrayList<string> filenames) {
			this.game = game;
			platform = game.platform as RomPlatform;
			this.filenames = filenames;
			
			_rom_fullname = game.id;
			_primary_file_extension = null;
			_folder_path = game.parent.unique_id();
			int extension_index = game.id.last_index_of(".");
			if (extension_index != -1) {
				_rom_fullname = game.id.substring(0, extension_index);
				_primary_file_extension = game.id.substring(extension_index+1);
			}
		}
		GameItem game;
		RomPlatform platform;
		ArrayList<string> filenames;
		string _rom_fullname;
		string _primary_file_extension;
		string _folder_path;
		bool _processed;
		
		class RomFileMoveSet
		{
			ArrayList<RomFileMove> files;
			public RomFileMoveSet.for_rename(string folder_path, string original_name, string new_name, Iterable<string> filenames) {
				files = new ArrayList<RomFileMove>();
				foreach(string filename in filenames) {
					files.add(new RomFileMove(Path.build_filename(folder_path, filename), 
					                          Path.build_filename(folder_path, filename.replace(original_name, new_name))));
				}
			}
			public RomFileMoveSet.for_move(string original_folder_path, string new_folder_path, Iterable<string> filenames) {
				files = new ArrayList<RomFileMove>();
				foreach(string filename in filenames) {
					files.add(new RomFileMove(Path.build_filename(original_folder_path, filename), Path.build_filename(new_folder_path, filename)));
				}
			}
			
			public bool move(out string? error=null) {
				error = null;
				bool success = true;
				foreach(var file in files) {
					string? file_error = null;
					if (file.move(out file_error) == false) {
						error = "%s: %s".printf(file.new_filename(), file_error);
						success = false;
						break;
					}
				}
				return success;
			}
			public bool revert(out string? error=null) {
				error = null;
				bool success = true;
				foreach(var file in files) {
					string? revert_error = null;
					if (file.revert(out revert_error) == false) {
						success = false;
						if (error == null)
							error = "%s: %s".printf(file.original_filename(), revert_error);
					}
				}
				return success;
			}
			
			public Catapult.Enumerable<string> new_filenames() {
				return new Catapult.Enumerable<RomFileMove>(files).select<string>(rfm=>rfm.new_filename());
			}
		}
		class RomFileMove 
		{
			string _original_path;
			string _new_path;
			bool moved;
			public RomFileMove(string original_path, string new_path) {
				_original_path = original_path;
				_new_path = new_path;
			}
			public string original_filename() { return Path.get_basename(_original_path); }
			public string new_filename() { return Path.get_basename(_new_path); }
			
			public bool move(out string? error=null) {
				error = null;
				if (moved == true)
					return true;
				if (do_move(false, out error) == false)
					return false;
				moved = true;
				return true;
			}
			public bool revert(out string? error=null) {
				error = null;
				if (moved == false)
					return true;
				if (do_move(true, out error) == false)
					return  false;				
				moved = false;
				return true;
			}
			bool do_move(bool revert, out string? error=null) {
				error = null;
				if (_new_path == _original_path)
					return true;
				try {
					if (revert == false) {
						if (File.new_for_path(_original_path).move(File.new_for_path(_new_path), FileCopyFlags.NOFOLLOW_SYMLINKS) == false) {
							error = "unable to move file";
							return false;
						}
					} else {
						if (File.new_for_path(_new_path).move(File.new_for_path(_original_path), FileCopyFlags.NOFOLLOW_SYMLINKS) == false) {
							error = "unable to revert file move";
							return false;
						}
					}
				} catch(GLib.Error e) {
					error = e.message;
					return false;
				}
				return true;
			}
		}
		
		static bool get_game_filenames(GameItem game, out ArrayList<string> filenames, out string? error=null) {
			error = null;
			string extra_rom_files_regex = ((RomPlatform)game.platform).extra_rom_files_regex ?? "";
			filenames = new ArrayList<string>();
			var result = Spawning.run_temp_script("get_game_filenames.sh", GET_GAME_FILENAMES_SCRIPT_FORMAT.printf(game.unique_id(), extra_rom_files_regex));
			if (result.success == false) {
				error = result.error_message;
				return false;
			}
			if (result.standard_output != null)
			{
				var lines = result.standard_output.split("\n");
				foreach (var line in lines) {
					line = line.strip();
					if (line != "")
						filenames.add(line);
				}
			}
			return true;
		}
		const string GET_GAME_FILENAMES_SCRIPT_FORMAT = """#!/bin/bash
FILEPATH="%s"
EXTRA_REGEX="%s"
DIR="${FILEPATH%%/*}"
FILENAME="${FILEPATH##*/}"
FILEPREFIX="${FILENAME%%.*}"

if [[ ! -d $DIR ]]; then
  exit
fi

cd "$DIR"
(
  ls -1 "$FILEPREFIX".*
  if [[ ${EXTRA_REGEX:-notset} != "notset" ]]; then
    if [[ $EXTRA_REGEX =~ "%%g" ]]; then
      REPLACE_PREFIX_PATTERN="s|%%g|$FILEPREFIX|"
      EXTRA_REGEX=$(echo "$EXTRA_REGEX" | sed "$REPLACE_PREFIX_PATTERN")
      ls -1 | grep -i "$EXTRA_REGEX"
    else
      ls -1 "$FILEPREFIX"* | grep -i "$EXTRA_REGEX" 
    fi
  fi
) | while read -r; do
  FOUND="$REPLY"
  echo "$FOUND"
  FOUNDEXT=$(echo "${FOUND##*.}" | tr '[:upper:]' '[:lower:]')
  if [[ $FOUNDEXT == "cue" ]]; then
   cat "$FOUND" 2>&1 | grep FILE | sed -e 's|.*FILE "\(.*\)".*|\1|' | grep -v FILE
  fi
done | sort | uniq
""";
	static bool rewrite_cue_file(string cue_filepath, string rom_fullname, string new_fullname, out string? error=null) {
		error = null;
		var result = Spawning.run_temp_script("rewrite_cue_file.sh", REWRITE_CUE_FILE_FORMAT.printf(rom_fullname, new_fullname, cue_filepath));
		if (result.success == false) {
			error = result.error_message;
			return false;
		}
		return true;
	}
	const string REWRITE_CUE_FILE_FORMAT = """sed -i 's|FILE "%s|FILE "%s|' "%s"""";
	}	
}
