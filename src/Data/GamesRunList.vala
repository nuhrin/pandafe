using Gee;
using Catapult;
using Data.GameList;

namespace Data
{
	public class GamesRunList : Entity
	{
		internal const string ENTITY_ID = "games_runlist";
		protected override string generate_id() { return ENTITY_ID; }

		construct {
			games_list = new LinkedList<Entry>();
			games_run = games_list;
		}
		
		LinkedList<Entry> games_list;
		public Gee.Queue<Entry> games_run { get; set; }
		
		public void increment_run_count(GameItem game) {
			string game_id = game.unique_id();
			int index = index_of_game(game_id);
			Entry entry;
			if (index == -1) {
				entry = new Entry() { 
					id = game_id, 
					run_count = 1
				};
			} else {
				entry = games_list.remove_at(index);
				entry.run_count++;
				
			}
			games_list.insert(0, entry);
		}
		
		public Enumerable<GameItem> get_most_recently_played(Iterable<GameItem> games) {
			var id_map = create_game_id_hash(games);
			return new Enumerable<Entry>(games_list)
				.where(e=>id_map.has_key(e.id))
				.select<GameItem>(e=>id_map[e.id]);
		}
		public Enumerable<GameItem> get_most_frequently_played(Iterable<GameItem> games) {
			var id_map = create_game_id_hash(games);
			return new Enumerable<Entry>(games_list)
				.where(e=>id_map.has_key(e.id))
				.sort((a,b) => (int)b.run_count - (int)a.run_count)
				.select<GameItem>(e=>id_map[e.id]);
		}
		
		int index_of_game(string game_id) {
			int index = 0;
			foreach(var entry in games_list) {
				if (entry.id == game_id)
					return index;
				index++;
			}
			return -1;
		}
		
		Map<string, GameItem> create_game_id_hash(Iterable<GameItem> games) {
			var map = new HashMap<string, GameItem>();
			foreach(var game in games)
				map[game.unique_id()] = game;
			return map;
		}
		
		public class Entry : Object {
			public string id { get; set; }
			public uint run_count { get; set; }
		}
	}
}