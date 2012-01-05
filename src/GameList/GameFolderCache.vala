using Gee;
using Catapult;

namespace Data.GameList
{
	public class GameFolderCache : Entity
	{
		public const string YAML_ID = "children";

		construct {
			subfolders = new ArrayList<string>();
			games = new ArrayList<GameItem>();
		}

		public ArrayList<string> subfolders { get; set; }
		public ArrayList<GameItem> games { get; set; }

		protected override string generate_id() { return YAML_ID; }


	}
}
