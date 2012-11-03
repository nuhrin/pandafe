using Gee;
using Catapult;
using Data.GameList;

namespace Data
{
	public class Favorites : Entity
	{		
		internal const string ENTITY_ID = "favorites";		

		HashSet<string> _favorite_game_ids;
		
		public signal void changed();
		
		public void add(GameItem game) {
			ensure_hashset();
			_favorite_game_ids.add(game.id);
			changed();
		}
		public void remove(GameItem game) {
			if (_favorite_game_ids == null || _favorite_game_ids.contains(game.id) == false)
				return;
			_favorite_game_ids.remove(game.id);
			changed();
		}
		public bool contains(GameItem game) {
			if (_favorite_game_ids == null)
				return false;
			return _favorite_game_ids.contains(game.id);
		}
		
		void ensure_hashset() {
			if (_favorite_game_ids == null)
				_favorite_game_ids = new HashSet<string>();			
		}
		
		// yaml
		protected override string generate_id() { return ENTITY_ID; }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			if (_favorite_game_ids != null) {
				foreach(var id in _favorite_game_ids)
					sequence.add(builder.build_value(id));				
			}
			return sequence;
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var sequence = node as Yaml.SequenceNode;
			if (sequence == null)
				return;
				
			if (sequence.item_count() > 0) {
				ensure_hashset();
				foreach(var id_node in sequence.scalars())
					_favorite_game_ids.add(id_node.value);
			}
		}
	}
}
