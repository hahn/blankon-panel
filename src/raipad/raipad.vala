/*

Based on slingshot
https://code.launchpad.net/~slingshot-devs/slingshot/new-slingshot

Copyright (C) 2011 by Slingshot Developers
Written by Slingshot Developers:
 * Giulio Collura <random.cpp@gmail.com>
 * Maxwell Barvian

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.

*/

public class RaipadWindow : RaipadWidgets.CompositedWindow {

    public GLib.List<Raipad.Frontend.AppItem> children;
    public Gtk.VBox container;
    public RaipadWidgets.RaipadSearchEntry searchbar;
    public Gtk.Table grid;
    
    public Gee.ArrayList<Gee.HashMap<string, string>> apps = new Gee.ArrayList<Gee.HashMap<string, string>> ();
    public Gee.ArrayList<Gee.HashMap<string, string>> filtered = new Gee.ArrayList<Gee.HashMap<string, string>> ();
    public Gtk.HBox pages;
    public int current_page = 0;
    public int total_pages;

    public RaipadWindow () {
        
        // Window properties       
        this.title = "Raipad";
        this.maximize();
        this.set_keep_above (true);
        
        // Get all apps
        this.enumerate_apps();
        
        // Add container
        this.container = new Gtk.VBox(false, 15);
        this.add(this.container);
        
        // Add searchbar
        var searchbar_wrapper = new Gtk.HBox(false, 0);
        this.searchbar = new RaipadWidgets.RaipadSearchEntry ("Type to search...");
        this.searchbar.grab_focus(); // hackishly enough, this will update the grid as well, so we don't need to do that
        this.searchbar.changed.connect(this.search);
        searchbar_wrapper.pack_end(this.searchbar, false, true, 15);
        this.container.pack_start(searchbar_wrapper, false, true, 15); 
        
        // Make icon grid and populate
        this.grid = new Gtk.Table (5, 8, false);
        this.container.pack_start (this.grid, true, true, 0);    
        
        this.populate_grid ();
        
        // Add pages
        this.pages = new Gtk.HBox(false, 15);
        
        var pages_wrapper = new Gtk.HBox(false, 0);
        pages_wrapper.pack_start(new Gtk.HBox(false, 0), true, true, 0); //left padding
        pages_wrapper.pack_end(new Gtk.HBox(false, 0), true, true, 0); //left padding
        
        this.container.pack_end(pages_wrapper, false, true, 30);
        
        // Find number of pages and populate
        this.enumerate_pages();
        
        if (this.total_pages >  1) {
            pages_wrapper.pack_start(this.pages, false, true, 0);
            for (int p = 1; p <= this.total_pages; p++) {
                this.add_page(p);
            } 
        }
        
        // Signals and callbacks
        this.expose_event.connect(this.draw_background);    
        //this.destroy.connect (this.destroy_event);
    }
    
    private void enumerate_apps () {
       
        foreach (var app in GLib.AppInfo.get_all ()) {
            if (app.should_show() == true && app.get_icon != null) {
                var app_to_add = new Gee.HashMap<string, string> ();
                app_to_add["description"] = app.get_description ();
                app_to_add["name"] = app.get_display_name ();
                app_to_add["command"] = app.get_executable ();
                app_to_add["icon"] = app.get_icon ().to_string ();
                this.apps.add(app_to_add);
                this.filtered.add(app_to_add);
            }
        }
    }
    
    private void populate_grid() {        
    
        for (int r = 0; r < this.grid.n_rows; r++) {
            
            for (int c = 0; c < this.grid.n_columns; c++) {
                            
                var item = new Raipad.Frontend.AppItem();
                this.children.append(item);
                
                item.button_press_event.connect( () => {
                    
                    try {
                        GLib.Process.spawn_command_line_async(this.filtered.get((int)(this.children.index(item) + (this.current_page * this.grid.n_columns * this.grid.n_rows)))["command"]);
                        this.destroy();
                    } catch (GLib.SpawnError e) {
                        stdout.printf("Error! Load application: " + e.message);
                    }
                    
                    return true;
                    
                });
                
                this.grid.attach_defaults(item.wrapper, c, c + 1, r, r + 1);
                
            } 
        }        
    }
    
    private void update_grid(Gee.ArrayList<Gee.HashMap<string, string>> apps) {    
        
        int item_iter = (int)(this.current_page * this.grid.n_columns * this.grid.n_rows);
        for (int r = 0; r < this.grid.n_rows; r++) {
            
            for (int c = 0; c < this.grid.n_columns; c++) {
                
                int table_pos = c + (r * (int)this.grid.n_columns); // position in table right now
                
                var item = this.children.nth_data(table_pos);
                if (item_iter < apps.size) {
                    var current_item = apps.get(item_iter);
                    
                    // Update icon
                    try {
                        item.icon.set_from_gicon(GLib.Icon.new_for_string(current_item["icon"]), Gtk.IconSize.DIALOG);
                    } catch (GLib.Error e) {
                        stdout.printf("Error! Could not update icon: " + e.message);
                    }
                    
                    // Update label
                    item.label.label = current_item["name"];
                    
                    // Update tooltip
                    item.set_tooltip_text(current_item["description"]);
                    item.visible = true;

                } else { // fill with a blank one
                    item.visible = false;
                }
                
                item_iter++;
                
            }
        }
        
        // Update pages
        this.pages.queue_draw();
    }
    
    private void enumerate_pages () {
        // Find current number of pages and add
        var num_pages = (int)(this.filtered.size / (this.grid.n_columns * this.grid.n_rows));
        if ((double)this.filtered.size % (double)(this.grid.n_columns * this.grid.n_rows) > 0) {
            this.total_pages = num_pages + 1;
        } else {
            this.total_pages = num_pages;
        }
    }
    
    private void add_page (int number) {
    
        var page = new Raipad.Frontend.PageIndicator(number);
        page.set_visible_window(false);
        
        this.pages.pack_start(page);
        
        page.expose_event.connect(this.draw_page);
        page.button_press_event.connect( () => {
            this.current_page = page.label.label.to_int() - 1;            
            this.update_grid(this.filtered);
            
            return true;
        });
    
    }
    
    private void search() {
        
        var current_text = this.searchbar.get_text().down();
        this.current_page = 0; // jump to first page first
        
        this.filtered.clear();
        
        for (int i = 0; i < this.apps.size; i++) {
            var app = this.apps.get(i);
            if (current_text in app["name"].down() || current_text in app["description"].down() || current_text in app["command"].down()) {
                this.filtered.add(app);
            }
        }
        this.update_grid(this.filtered);
        this.enumerate_pages();
        
        // Update pages
        var current_pages = this.pages.get_children();
        for (int p = 1; p <= current_pages.length(); p++) {
            
            if (p > this.total_pages) {
                current_pages.nth_data(p - 1).visible = false;
            } else {
                current_pages.nth_data(p - 1).visible = true;
            }
            
        }
    }
    
    private void page_left() {
        
        if (this.current_page >= 1) {
            this.current_page -= 1;
        }
        
        this.update_grid (this.filtered);
        
    }
    
    private void page_right() {
        
        if ((this.current_page + 1) < this.total_pages) {
            this.current_page += 1;
        }
        
        this.update_grid (this.filtered);
        
    }

    private bool draw_background (Gtk.Widget widget, Gdk.EventExpose event) {
        var context = Gdk.cairo_create (widget.window); // directly onto the gdk.window
        Gtk.Allocation size;
		widget.get_allocation(out size);
        
        // Semi-dark background
        var linear_fill = new Cairo.Pattern.linear(size.x, size.y, size.x, size.y + size.height - 1);
	    linear_fill.add_color_stop_rgba(0.0,  0.0, 0.0, 0.0, 0.5);
	    linear_fill.add_color_stop_rgba(0.85,  0.0, 0.0, 0.0, 0.5);
	    linear_fill.add_color_stop_rgba(1.0,  0.0, 0.0, 0.0, 0.0);
        context.set_source (linear_fill);
        context.rectangle(size.x, size.y, size.width, size.height);
        context.fill();
        
        return false;
    }
    
    private bool draw_page (Gtk.Widget widget, Gdk.EventExpose event) {
        var context = Gdk.cairo_create (widget.window);
        Gtk.Allocation size;
		widget.get_allocation(out size);

        // Draw rounded rectangle background
        if (((Raipad.Frontend.PageIndicator)widget).label.label.to_int() == (this.current_page + 1)) { // check if the widget's label is the current page number
            context.set_source_rgba (1.0, 1.0, 1.0, 0.85);
        } else{
            context.set_source_rgba (1.0, 1.0, 1.0, 0.6);
        }
        Raipad.Frontend.Utilities.draw_rounded_rectangle(context, 5, 0, size);
        context.fill();

        return false;
    }
    
    // Keyboard shortcuts
    public override bool key_press_event(Gdk.EventKey event) {
        //print("\n\n" +Gdk.keyval_name(event.keyval) + "\n\n");
        switch (Gdk.keyval_name(event.keyval)) {
        
            case "Escape":
                this.destroy();
                return true;
            case "ISO_Left_Tab":
                this.page_left();
                return true;
            case "Tab":
                this.page_right();
                return true;

        }
        
        base.key_press_event (event);
        return false;
        
    }
    
    // Scrolling left/right for pages
    public override bool scroll_event (Gdk.EventScroll event) {
        switch (event.direction.to_string()) {
        
            case "GDK_SCROLL_LEFT":
                this.page_left();
                break;
            case "GDK_SCROLL_RIGHT":
                this.page_right();
                break;
        
        }
                
        return true;
    }
    
    // Override destroy for fade out and showing windows again
    public new void destroy() {
        // restore windows
        Wnck.Screen.get_default().toggle_showing_desktop (false);
        
        base.destroy();
        Gtk.main_quit();
    }
    
}
