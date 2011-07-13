using Catapult;
using Gee;

namespace yayafe.Data.ProgramDefinition
{
	public class OptionPath : Object
	{
		static int nextID = 0;
		construct {
			ID = OptionPath.nextID;
			OptionPath.nextID++;
			Depth = 0;
			Parent = null;
			Options = new ArrayList<Option>();
			ChildPaths = new ArrayList<OptionPath>((EqualFunc)same_optionpath);
		}
		public int ID { get; private set; }
		public string Name { get; set; }
		public string Description { get; set; }

		public int Depth { get; private set; }
		public OptionPath? Parent { get; private set; }

		// ChildPath related
		public int ChildCount { get { return ChildPaths.size; } }
		public OptionPath get_child_at(int index) { return ChildPaths[index]; }
		public int index_of_child(OptionPath path) { return ChildPaths.index_of(path); }
		public bool add_child(OptionPath child) {
			bool retVal = ChildPaths.add(child);
			if (retVal == true)
				set_depth(child, this.Depth+1);
			return retVal;
		}
		public bool remove_child(OptionPath child) { return ChildPaths.remove(child); }
		public void reparent(OptionPath newParent) {
			if (ID == newParent.ID)
				return;
			set_depth(this, newParent.Depth+1);
			newParent.add_child(this);
			if (this.Parent != null)
				this.Parent.remove_child(this);
			this.Parent = newParent;
		}
		public bool is_descendant(OptionPath path) {
			if (ID == path.ID)
				return false;
			foreach(var child in ChildPaths) {
				if (child.ID == path.ID)
					return true;
				if (child.is_descendant(path))
					return true;
			}
			return false;
		}
		static void set_depth(OptionPath path, int depth) {
			path.Depth = depth;
			foreach(var child in path.ChildPaths)
				set_depth(child, depth+1);
		}
		static bool same_optionpath(OptionPath a, OptionPath b) { return (a.ID == b.ID); }
		internal Gee.List<OptionPath> ChildPaths { get; set; }

		// Options related
		public Gee.List<Option> Options { get; private set; }

	}
}
