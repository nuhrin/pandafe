/* Provider.vala
 * 
 * Copyright (C) 2012 nuhrin
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
using Catapult;
using Data.Pnd;
using Data.Platforms;
using Data.GameList;

namespace Data
{
	public DataInterface data_interface() { return Provider.instance().data_interface; }

	public Data.Platforms.PlatformProvider platforms() { return Provider.instance().platform_provider; }
	public Data.Programs.ProgramProvider programs() { return Provider.instance().program_provider; }
	public Data.Appearances.AppearanceProvider appearances() { return Provider.instance().appearance_provider; }

	public Preferences preferences() { return Provider.instance().get_preferences(); }
	public bool save_preferences() { return Provider.instance().save_preferences(); }

	public GameBrowserState browser_state() { return Provider.instance().get_browser_state(); }
	public bool save_browser_state() { return Provider.instance().save_browser_state(); }

	public PndData pnd_data() { return Provider.instance().get_pnd_data(); }
	public PndData rescan_pnd_data() { return Provider.instance().rescan_pnd_data(); }

	public MountSet pnd_mountset() { return Provider.instance().get_mountset(); }

	public GameSettings? get_game_settings(GameItem game) { return Provider.instance().get_game_settings(game); }
	public bool save_game_settings(GameSettings settings, GameItem game) { return Provider.instance().save_game_settings(settings, game.id); }

	public AllGames all_games() { return Provider.instance().get_all_games_interface(); }
	
	public Favorites favorites() { return Provider.instance().get_favorites(); }
	public bool save_favorites() { return Provider.instance().save_favorites(); }

	public void increment_game_run_count(GameItem game) {
		Provider.instance().get_games_run_list().increment_run_count(game);
		Provider.instance().save_games_run_list();		
	}	
	public Enumerable<GameItem> get_most_recently_played_games(Iterable<GameItem> games) {
		return Provider.instance().get_games_run_list().get_most_recently_played(games);
	}
	public Enumerable<GameItem> get_most_frequently_played_games(Iterable<GameItem> games) {
		return Provider.instance().get_games_run_list().get_most_frequently_played(games);
	}
	public bool games_run_list_is_empty() {
		return (Provider.instance().get_games_run_list().games_run.size == 0);
	}

	public class Provider
	{
		static Provider _instance;
		public static Provider instance() {
			if (_instance == null)
				_instance = new Provider();
			return _instance;
		}

		public DataInterface data_interface { get; private set; }
		public Data.Platforms.PlatformProvider platform_provider { get; private set; }
		public Data.Programs.ProgramProvider program_provider { get; private set; }
		public Data.Appearances.AppearanceProvider appearance_provider { get; private set; }
		public Provider() {
			try {
				data_interface = new DataInterface(RuntimeEnvironment.user_config_dir());
			} catch (Error e) {
				error("Unable to create DataInterface instance: %s", e.message);
				//assert_not_reached();
			}
			try {				
				program_provider = new Data.Programs.ProgramProvider(data_interface.root_folder);
				platform_provider = new Data.Platforms.PlatformProvider(data_interface.root_folder, program_provider);				
				appearance_provider = new Data.Appearances.AppearanceProvider(data_interface.root_folder);
				data_interface.register_entity_provider<Platform>(platform_provider);
				data_interface.register_entity_provider<Program>(program_provider);
				data_interface.register_entity_provider<Appearance>(appearance_provider);
			} catch(Error e) {
				error("Unable to create ProgramProvider instance: %s", e.message);
			}
		}

		public Preferences get_preferences() {
			if (_preferences == null) {
				try {
					_preferences = data_interface.load<Preferences>(Preferences.ENTITY_ID, "");
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving preferences: %s", e.message);
					_preferences = new Preferences();
				}				
			}
			return _preferences;
		}
		Preferences _preferences;
		public bool save_preferences() {
			var prefs = get_preferences();
			try {
				data_interface.save(prefs, Preferences.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				warning("Error while saving preferences: %s", e.message);
			}
			return false;
		}

		public GameBrowserState get_browser_state() {
			if (_browser_state == null) {
				try {
					_browser_state = data_interface.load<GameBrowserState>(GameBrowserState.ENTITY_ID, "");
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving game browser state: %s", e.message);
					_browser_state = new GameBrowserState();
				}
			}
			return _browser_state;
		}
		GameBrowserState _browser_state;
		public bool save_browser_state() {
			var state = get_browser_state();
			try {
				data_interface.save(state, GameBrowserState.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				warning("Error while saving game browser state: %s", e.message);
			}
			return false;
		}

		public PndData get_pnd_data() {
			if (_pnd_data == null) {
				try {
					var cache = data_interface.load<PndCache>(PndData.CACHED_DATA_ID, PndData.CACHED_DATA_FOLDER);
					_pnd_data = new PndData(data_interface, cache);
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving pnd data: %s", e.message);
					return rescan_pnd_data();
				}
			}
			return _pnd_data;
		}
		PndData _pnd_data;
		public PndData rescan_pnd_data() {
			_pnd_data = new PndData(data_interface);
			_pnd_data.rescan();
			program_provider.rebuild_program_apps();
			return _pnd_data;
		}

		public MountSet get_mountset() {
			if (_mountset_config == null)
				_mountset_config = new MountSet();
			return _mountset_config;
		}
		MountSet _mountset_config;

		public GameSettings? get_game_settings(GameItem item) {
			try {
				return data_interface.load<GameSettings>(item.id);
			} catch(Error e) {
				if ((e is RuntimeError.FILE) == false)
					warning("Error while retrieving game settings for '%s': %s", item.id, e.message);
			}
			return null;
		}
		public bool save_game_settings(GameSettings settings, string id) {
			try {
				data_interface.save(settings, id);
				return true;
			}
			catch (Error e) {
				warning("Error while saving game settings for '%s': %s", id, e.message);
			}			
			return false;
		}
		
		public AllGames get_all_games_interface() {
			if (_all_games == null)
				_all_games = new AllGames();
			return _all_games;
		}
		AllGames _all_games;
		
		public Favorites get_favorites() {
			if (_favorites == null) {
				try {
					_favorites = data_interface.load<Favorites>(Favorites.ENTITY_ID, "");
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving favorites: %s", e.message);
					_favorites = new Favorites();
				}				
			}
			return _favorites;
		}
		Favorites _favorites;
		public bool save_favorites() {
			var favorties = get_favorites();
			try {
				data_interface.save(favorties, Favorites.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				warning("Error while saving favorites: %s", e.message);
			}
			return false;
		}
		
		public GamesRunList get_games_run_list() {
			if (_games_run_list == null) {
				try {
					_games_run_list = data_interface.load<GamesRunList>(GamesRunList.ENTITY_ID, "");
				}
				catch (Error e) {
					if ((e is RuntimeError.FILE) == false)
						warning("Error while retrieving games run list: %s", e.message);
					_games_run_list = new GamesRunList();
				}				
			}
			return _games_run_list;
		}
		GamesRunList _games_run_list;
		public bool save_games_run_list() {
			var games_run_list = get_games_run_list();
			try {
				data_interface.save(games_run_list, GamesRunList.ENTITY_ID, "");
				return true;
			}
			catch (Error e) {
				warning("Error while saving games run list: %s", e.message);
			}
			return false;
		}
	}
}
