/*
# Sassy Backup
#
# Copyright (c) 2010 by Sassy Developers
#    
# License:
# This file is part of sassy.
#
# Sassy is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Sassy is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Sassy.  If not, see <http://www.gnu.org/licenses/>.
*/
using GLib;
using Gtk;

namespace Raipad.Frontend.Utilities {
		
	public Gtk.Alignment wrap_alignment(Gtk.Widget widget, int top, int right, int bottom, int left) {
		var alignment = new Gtk.Alignment(0.0f, 0.0f, 1.0f, 1.0f);
		alignment.top_padding = top;
		alignment.right_padding = right;
		alignment.bottom_padding = bottom;
		alignment.left_padding = left;
		
		alignment.add(widget);
		return alignment;
	}
		
	public void draw_rounded_rectangle(Cairo.Context context, double radius, double offset, Gtk.Allocation size) {
		context.move_to (size.x + radius, size.y + offset);
		context.arc (size.x + size.width - radius - offset, size.y + radius + offset, radius, Math.PI * 1.5, Math.PI * 2);
		context.arc (size.x + size.width - radius - offset, size.y + size.height - radius - offset, radius, 0, Math.PI * 0.5);
		context.arc (size.x + radius + offset, size.y + size.height - radius - offset, radius, Math.PI * 0.5, Math.PI);
		context.arc (size.x + radius + offset, size.y + radius + offset, radius, Math.PI, Math.PI * 1.5);
		
	}
		
}
