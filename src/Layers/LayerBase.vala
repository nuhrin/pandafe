/* LayerBase.vala
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
using SDL;

namespace Layers
{
	public abstract class LayerBase : Object
	{	
		static uint next_unique_id;
		static LayerDependencies dependencies;
		static Gee.HashMap<uint,string> id_hash;
		static Gee.HashMap<uint,string> type_hash;
		static void register_creation(LayerBase layer) {
			if (id_hash == null) {
				id_hash = new Gee.HashMap<uint,string>();
				type_hash = new Gee.HashMap<uint,string>();
			}
			id_hash[next_unique_id] = layer.id;
			type_hash[next_unique_id] = layer.get_type().name();
			layer.unique_id = next_unique_id;
			next_unique_id++;			
		}
		static void register_destruction(LayerBase layer) {
			id_hash.unset(layer.unique_id);
			type_hash.unset(layer.unique_id);
		}
		public static void print_all_registered_layers() {
			if (id_hash == null || id_hash.size == 0)
				return;
			print("all LayerBase instances not destroyed:\n");			
			foreach(var uid in id_hash.keys) {
				print("- %u: %s (%s)\n", uid, id_hash[uid], type_hash[uid]);
			}
		}
		string _id;
		uint unique_id;
		ArrayList<Layer> children;
		ArrayList<Layer> additional_layer_stack;
		bool needs_update;
				
		protected LayerBase(string id) {
			_id = id;
			if (RuntimeEnvironment.dev_mode) {
				register_creation(this);
			} else {
				unique_id = next_unique_id;			
				next_unique_id++;
			}
			if (dependencies == null)
				dependencies = new LayerDependencies();
			needs_update = true;
		}
		protected LayerBase.uniqueid(string id) {
			base("%s_%u".printf(id, next_unique_id));
		}
		~LayerBase() {
			if (RuntimeEnvironment.dev_mode)
				register_destruction(this);
		}
		public unowned string id { get { return _id; } }	

		//
		// drawing
		public void update(bool flip_screen=true) {
//~ 			print("updating '%s' (%d) [flip_screen=%s]\n", id, (int)unique_id, flip_screen.to_string());
//~ 			GLib.Thread.usleep(100000);
			clear();
			draw();
			if (children != null) {
				foreach(var child in children)
					child.update(false);									
			}
			if (stack_empty == false) {
				var stack_bottom = additional_layer_stack[0];
				stack_bottom.update(false);				
			}
			var layers = dependencies.get_dependent_layers(this);
			if (layers != null) {
				foreach(var layer in layers) {
					layer.update(false);
				}
			}
			blit();			
			changed();
			
			if (flip_screen == true) {
				var screen = get_owning_screen();
				if (screen != null) {
					if (@interface.peek_screen_layer().unique_id == screen.unique_id)
						screen.flip();
				}
			}
			needs_update = false;
		}
		public signal void changed();
		protected virtual void blit() { }		
		protected abstract void clear();
		protected abstract void draw();		
		protected abstract void blit_surface(Surface surface, Rect? source_rect, Rect dest_rect);
		protected abstract void draw_rectangle_outline(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255);
		protected abstract void draw_rectangle_fill(int16 x, int16 y, int16 width, int16 height, SDL.Color color, uchar alpha=255);
		protected abstract void draw_horizontal_line(int16 x1, int16 x2, int16 y, SDL.Color color, uchar alpha=255);
		protected abstract void draw_vertical_line(int16 x, int16 y1, int16 y2, SDL.Color color, uchar alpha=255);
		//
		// layer children and stack
		public Layer push_layer(Layer layer) {
			if (contains_layer(layer, additional_layer_stack) == true)
				GLib.error("Layer stack for '%s' already contains layer '%s'.", this.id, layer.id);
				
			if (additional_layer_stack == null)
				additional_layer_stack = new ArrayList<Layer>();
						
			var last = peek_layer();
			if (last != null)
				dependencies.add_dependency(last, layer);
			
			adopt_layer(layer);			
			additional_layer_stack.add(layer);
									
			return layer;
		}
		public Layer? peek_layer() {
			if (stack_empty == false)
				return additional_layer_stack.last();
			return null;
		}
		public Layer? pop_layer() {
			var popped = peek_layer();
			if (popped == null)
				return null;
				
			additional_layer_stack.remove_at(additional_layer_stack.size - 1);
			orphan_layer(popped);
			dependencies.clear_dependent_layers(popped);
			
			var last = peek_layer();
			if (last != null)
				dependencies.remove_dependency(last, popped);
						
			return popped;
		}
		public Layer add_layer(Layer layer) {
			if (contains_layer(layer, children) == true)
				GLib.error("Layer '%s' already contains child '%s'.", this.id, layer.id);
			if (children == null)
				children = new ArrayList<Layer>();
			adopt_layer(layer);
			children.add(layer);
			return layer;
		}
		public Layer? remove_layer(string existing_id) {
			Layer? layer = null;
			int index = index_of_layer(existing_id, children);
			if (index > -1) {
				layer = children.remove_at(index);				
			} else {
				index = index_of_layer(existing_id, additional_layer_stack);
				if (index > -1)
					layer = additional_layer_stack.remove_at(index);				
			}
			if (layer != null) {
				orphan_layer(layer);
				dependencies.clear_dependent_layers(layer);
			}
			return layer;
		}
		public Layer? replace_layer(string existing_id, Layer new_layer) {
			Layer? layer = null;
			int index = index_of_layer(existing_id, children);
			if (index > -1) {
				layer = children[index];
				children[index] = new_layer;				
			} else {
				index = index_of_layer(existing_id, additional_layer_stack);
				if (index > -1) {
					layer = additional_layer_stack[index];
					additional_layer_stack[index] = new_layer;
				}
			}
			if (layer != null) {
				orphan_layer(layer);
				adopt_layer(new_layer);
				dependencies.remap_dependent_layers(layer, new_layer);
			}
			return layer;
		}
		
		// 
		// layer dependencies
		public void register_dependent_layer(Layer layer) {
			dependencies.add_dependency(this, layer);
		}
		public void unregister_dependent_layer(string existing_id) {
			Layer layer = null;
			int index = index_of_layer(existing_id, children);
			if (index > -1) {
				layer = children[index];
			}
			else {
				index = index_of_layer(existing_id, additional_layer_stack);
				layer = additional_layer_stack[index];
			}
			if (layer != null)
				dependencies.remove_dependency(this, layer);
		}		
				
		protected bool has_children { get { return (children != null && children.size > 0); } }
		protected bool stack_empty { get { return (additional_layer_stack == null || additional_layer_stack.size == 0); } }
		
		protected ScreenLayer? get_owning_screen() { 
			if (_screen != null)
				return _screen;
			if (_parent != null)
				return _parent.screen;
			return this as ScreenLayer;			
		}
		protected Layer? get_parent_layer() { return _parent; }
		
		int index_of_layer(string id, Gee.List<Layer> list) {
			for(int index=0; index<list.size; index++) {
				if (list[index].id == id)
					return index;
			}
			return -1;
		}
		bool contains_layer(Layer layer, Gee.List<Layer>? list) {
			if (list != null) {
				foreach(var child in list) {
					if (layer.unique_id == child.unique_id)
						return true;
				}
			}
			return false;
		}
		void adopt_layer(Layer layer) {
			var lb = layer as LayerBase;
			LayerBase parent = lb._parent;
			if (parent == null)
				parent = lb._screen;
			if (parent != null)
				parent.remove_layer(lb.id);
			lb._parent = this as Layer;
			if (lb._parent == null)
				lb._screen = this as ScreenLayer;
		}
		void orphan_layer(Layer layer) {
			var lb = layer as LayerBase;
			lb._screen = null;
			lb._parent = null;
		}		
		weak ScreenLayer? _screen;
		weak Layer? _parent;
	
		class LayerDependencies 
		{
			HashMap<uint, ArrayList<Layer>> dependent_layers_hash;
			HashMap<uint, HashSet<uint>> dependent_layer_ids_hash;
			
			public LayerDependencies() {
				dependent_layers_hash = new HashMap<uint, ArrayList<Layer>>();
				dependent_layer_ids_hash = new HashMap<uint, HashSet<uint>>();
			}
			
			public Gee.List<Layer>? get_dependent_layers(LayerBase layer) {
				if (dependent_layers_hash.has_key(layer.unique_id) == true)
					return dependent_layers_hash[layer.unique_id];
				return null;
			}
			
			public void add_dependency(LayerBase layer, Layer dependent_layer) {
				if (dependent_layers_hash.has_key(layer.unique_id) == false) {
					dependent_layers_hash[layer.unique_id] = new ArrayList<Layer>();
					dependent_layer_ids_hash[layer.unique_id] = new HashSet<int>();
				} else {
					if (dependency_tree_has_layer(layer.unique_id, dependent_layer.unique_id) == true)
						return; // dependency also present, directly or indirectly
				}
				dependent_layers_hash[layer.unique_id].add(dependent_layer);
				dependent_layer_ids_hash[layer.unique_id].add(dependent_layer.unique_id);
			}
			public void remove_dependency(LayerBase layer, Layer dependent_layer) {
				int index = index_of_dependent_layer(layer.unique_id, dependent_layer.unique_id);
				if (index == -1)
					return;
				dependent_layers_hash[layer.unique_id].remove_at(index);
				dependent_layer_ids_hash[layer.unique_id].remove(dependent_layer.unique_id);
			}
			public void clear_dependent_layers(LayerBase layer) {
				if (dependent_layers_hash.has_key(layer.unique_id) == false)
					return;
				dependent_layers_hash.unset(layer.unique_id);
				dependent_layer_ids_hash.unset(layer.unique_id);
			}
			public void remap_dependent_layers(Layer layer, Layer new_layer) {
				if (dependent_layers_hash.has_key(layer.unique_id) == false)
					return;
				var layers = dependent_layers_hash[layer.unique_id];
				dependent_layers_hash.unset(layer.unique_id);
				dependent_layer_ids_hash.unset(layer.unique_id);
				foreach(var dependent_layer in layers) {
					add_dependency(new_layer, dependent_layer);
				}
			}
			
			bool dependency_tree_has_layer(uint source_id, uint dependency_id) {
				if (dependent_layer_ids_hash.has_key(source_id) == false)
					return false;
				var @set = dependent_layer_ids_hash[source_id];
				if (@set.contains(dependency_id) == true)
					return true;
				foreach(var key in @set) {
					if (dependency_tree_has_layer(key, dependency_id) == true)
						return true;
				}
				return false;
			}
			int index_of_dependent_layer(uint source_id, uint dependency_id) {
				if (dependent_layers_hash.has_key(source_id) == false)
					return -1;
				var list = dependent_layers_hash[source_id];
				for(int index=0;index<list.size;index++) {
					if (list[index].unique_id == dependency_id)
						return index;
				}
				return -1;
			}
		}
	}
}
