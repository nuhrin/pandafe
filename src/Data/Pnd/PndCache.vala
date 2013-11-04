/* PndCache.vala
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
using Pandora.Apps;

namespace Data.Pnd
{
	public class PndCache : Entity
	{
		public PndCache() {
			pnd_list = Enumerable.empty<PndItem>();
		}
		public PndCache.from_pnds(Gee.List<Pandora.Apps.Pnd> pnds) {
			var items = new ArrayList<PndItem>();
			foreach(var pnd in pnds) {
				var item = new PndItem.from_pnd(pnd);
				items.add(item);
			}
			items.sort();
			pnd_list = new Enumerable<PndItem>(items);
		}
		public PndCache.from_data(Iterable<PndItem> pnds) {
			pnd_list = new Enumerable<PndItem>(pnds);
		}

		protected override string generate_id() { return PndData.CACHED_DATA_ID; }

		public Enumerable<PndItem> pnd_list { get; private set; }

		protected override Yaml.Node build_yaml_node(Yaml.NodeBuilder builder) {
			var sequence = new Yaml.SequenceNode();
			foreach(var pnd in pnd_list) {
				var pnd_node = builder.build_yaml_object(pnd);
				sequence.add(pnd_node);
			}
			return sequence;
		}
		protected override void apply_yaml_node(Yaml.Node node, Yaml.NodeParser parser) {
			var sequence = node as Yaml.SequenceNode;
			var list = new ArrayList<PndItem>();
			foreach(var childNode in sequence.items()) {
				var item = (PndItem)parser.parse_value_of_type(childNode, typeof(PndItem), null);
				if (item != null)
					list.add(item);
			}
			pnd_list = new Enumerable<PndItem>(list);
		}
	}
}
