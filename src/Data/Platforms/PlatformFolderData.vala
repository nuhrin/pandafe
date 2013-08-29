/* PlatformFolderData.vala
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
using Fields;
using Data.Appearances.GameBrowser;
using Menus;
using Menus.Fields;

namespace Data.Platforms
{
	public class PlatformFolderData : Entity
	{
		construct {
			folders = new ArrayList<PlatformFolder>();
		}
		
		public Gee.List<PlatformFolder> folders { get; set; }		
		
		public Enumerable<PlatformFolder> get_all_folders() {
			var all_folders = new ArrayList<PlatformFolder>();
			foreach(var folder in folders)
				get_all_folders_add_folder(folder, all_folders);
			return new Enumerable<PlatformFolder>(all_folders);
		}
			void get_all_folders_add_folder(PlatformFolder folder, Gee.List<PlatformFolder> list) {
				list.add(folder);
				foreach(var child in folder.folders)
					get_all_folders_add_folder(child, list);
			}
		public Enumerable<Platform> get_all_platforms(PlatformFolder? root_folder=null) {
			HashSet<Platform> all_platforms = new HashSet<Platform>();			
			if (root_folder != null) {
				get_all_platforms_add_folder_platforms(root_folder, all_platforms);
			} else {
				foreach(var folder in folders)
					get_all_platforms_add_folder_platforms(folder, all_platforms);
				all_platforms.add(Data.platforms().get_native_platform());
			}			
			return new Enumerable<Platform>(all_platforms).sort((a,b) => a.name.casefold().collate(b.name.casefold()));
		}
			void get_all_platforms_add_folder_platforms(PlatformFolder folder, HashSet<Platform> all_platforms) {
				foreach(var platform_node in folder.platforms)
					all_platforms.add(platform_node.platform);
				foreach(var child in folder.folders)
					get_all_platforms_add_folder_platforms(child, all_platforms);
			}
		
		public PlatformFolder? get_folder(string path) {
			string[] parts = path.split("/");
			if (parts.length == 0)
				return null;
			Gee.List<PlatformFolder> list_pointer = folders;
			PlatformFolder? found_folder = null;
			for(int index=0; index<parts.length; index++) {
				found_folder = null;
				foreach(var folder in list_pointer) {
					if (folder.name == parts[index]) {
						found_folder = folder;
						break;
					}
				}
				if (found_folder == null)
					return null;
				list_pointer = found_folder.folders;
			}
			return found_folder;
		}
		public PlatformFolder? get_folder_with_platform(Platform platform) {
			foreach(var folder in folders) {
				var match = find_folder_with_platform(platform, folder);
				if (match != null)
					return match;
			}
			return null;
		}
		PlatformFolder? find_folder_with_platform(Platform platform, PlatformFolder parent) {
			foreach(var folder_platform in parent.platforms) {
				if (folder_platform.platform == platform)
					return parent;
			}
			foreach(var folder in parent.folders) {
				var match = find_folder_with_platform(platform, folder);
				if (match != null)
					return match;
			}
			return null;
		}
		
		// menus
		protected void build_menu(MenuBuilder builder) {
			var folders_field = new PlatformFolderListField.root("folders", "Folders", null, folders);
			builder.add_field(folders_field);
		}
		
				
		// yaml
		protected override string generate_id() { assert_not_reached(); }				
		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			return build_platform_folder_list_node(folders, builder);			
		}		
		Yaml.MappingNode build_platform_folder_node(PlatformFolder folder, Yaml.NodeBuilder builder) {
			var mapping = new Yaml.MappingNode();
			mapping.set_scalar("name", builder.build_value(folder.name));
			if (folder.appearance != null)
				mapping.set_scalar("appearance", builder.build_value(folder.appearance));
			mapping.set_scalar("folders", build_platform_folder_list_node(folder.folders, builder));
			mapping.set_scalar("platforms", build_platform_list_node(folder.platforms, builder));
			return mapping;
		}
		Yaml.SequenceNode build_platform_folder_list_node(Gee.List<PlatformFolder> folders, Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			foreach(var folder in folders)
				sequence.add(build_platform_folder_node(folder, builder));
			return sequence;
		}
		Yaml.SequenceNode build_platform_list_node(Gee.List<PlatformNode> platforms, Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			foreach(var platform_node in platforms)
				sequence.add(builder.build_value(platform_node.platform.id));
			return sequence;
		}
		
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var sequence = node as Yaml.SequenceNode;
			if (sequence != null)
				apply_platform_folder_list_node(null, sequence, parser);
		}
		PlatformFolder? apply_platform_folder_node(PlatformFolder? parent, Yaml.MappingNode mapping, Yaml.NodeParser parser) {
			var name_node = mapping.get_scalar("name");
			string name = parser.parse<string>(name_node, "");
			if (name == null || name == "")
				return null;
			PlatformFolder folder = (parent != null)
				? new PlatformFolder(name, parent)
				: new PlatformFolder.root(name);
				
			var appearance_mapping = mapping.get_scalar("appearance") as Yaml.MappingNode;
			if (appearance_mapping != null)
				folder.appearance = parser.parse<GameBrowserAppearance?>(appearance_mapping, null);
			
			var folders_sequence = mapping.get_scalar("folders") as Yaml.SequenceNode;
			if (folders_sequence != null)
				apply_platform_folder_list_node(folder, folders_sequence, parser);
			var platforms_sequence = mapping.get_scalar("platforms") as Yaml.SequenceNode;
			if (platforms_sequence != null)
				apply_platform_list_node(folder, platforms_sequence, parser);
			
			return folder;
		}
		void apply_platform_folder_list_node(PlatformFolder? parent, Yaml.SequenceNode sequence, Yaml.NodeParser parser) {
			foreach(var mapping in sequence.mappings()) {
				var folder = apply_platform_folder_node(parent, mapping, parser);
				if (folder == null)
					continue;
				if (parent != null)
					parent.folders.add(folder);
				else
					this.folders.add(folder);
			}
		}
		void apply_platform_list_node(PlatformFolder parent, Yaml.SequenceNode sequence, Yaml.NodeParser parser) {
			foreach(var scalar in sequence.scalars()) {
				var platform = Data.platforms().get_platform(scalar.value);
				if (platform == null)
					continue;				
				parent.platforms.add(new PlatformNode(platform, parent));				
			}
		}
	}
}
