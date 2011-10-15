using Catapult;

namespace Data.GameList
{
	public class GameItem : YamlObject, Gee.Comparable<IGameListNode>, IGameListNode
	{
		string _name;
		GameListProvider _provider;
		GameFolder _parent;
		string? _id;
		string? _full_name;

		public static GameItem create(string name, GameListProvider provider, GameFolder parent, string? id=null, string? full_name=null) {
			GameItem game = new GameItem();
			game._name = name;
			game._provider = provider;
			game._parent = parent;
			game._id = id;
			game._full_name = full_name;
			return game;
		}
		public static void set_provider(GameItem game, GameListProvider provider) { game._provider = provider; }
		public static void set_parent(GameItem game, GameFolder parent) { game._parent = parent; }
		public static void set_full_name(GameItem game, string full_name) { game._full_name = full_name; }

		protected GameListProvider provider { get { return _provider; } }
		public GameFolder? parent { get { return _parent; } }

		public string id { get { return (_id != null) ? _id : _name; } }
		public string name { get { return _name; } }
		public string full_name { get { return (_full_name != null) ? _full_name : _name; } }

		public uint run() { return provider.run_game(this); }

		// yaml
		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			if (_id != null)
				builder.add_mapping(mapping, "id", _id);
			builder.add_mapping(mapping, "name", _name);
			if (_full_name != null)
				builder.add_mapping(mapping, "full-name", _full_name);

			return mapping;
		}
		protected override bool apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var mapping = node as Yaml.MappingNode;
			if (mapping == null)
				return false;

			foreach(var key_node in mapping.Mappings.scalar_keys()) {
				var value_node = mapping.Mappings[key_node] as Yaml.ScalarNode;
				if (value_node != null) {
					switch(key_node.Value) {
						case "id":
							_id = value_node.Value;
							break;
						case "name":
							_name = value_node.Value;
							break;
						case "full-name":
							_full_name = value_node.Value;
							break;
						default:
							break;
					}
				}
			}
			return true;
		}


		public int compare_to(IGameListNode other) {
			return this.name.ascii_casecmp(other.name);
		}
	}
}
