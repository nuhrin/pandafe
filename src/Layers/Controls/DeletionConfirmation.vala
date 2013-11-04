/* DeletionConfirmation.vala
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

namespace Layers.Controls
{
	public class DeleteConfirmation : StringSelector
	{
		const string CANCEL_TEXT = ".. cancel";
		const string CONFIRM_TEXT = "!! Confirm";
		public DeleteConfirmation(string id, int16 xpos, int16 ypos)
		{
			base(id, xpos, ypos, 200);
			for(int index=0;index<7;index++)
				add_item(CANCEL_TEXT);
			add_item(CONFIRM_TEXT);
			add_item(CANCEL_TEXT);
			add_item(CANCEL_TEXT);
		}
		public new bool run(uchar screen_alpha=128, uint32 rgb_color=0) {
			base.run(screen_alpha, rgb_color);
			return (selected_item() == CONFIRM_TEXT);
		}
	}
}
