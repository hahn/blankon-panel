
namespace Raipad.Frontend {

    public class AppItem : Gtk.EventBox {
    
        public Gtk.Alignment wrapper;
        public Gtk.Image icon;
        public Gtk.Label label;

        public AppItem () {
        
            // EventBox Properties
            this.set_visible_window(false);
            this.can_focus = true;
        
            // VBox wrapper for children
            var wrapper = new Gtk.VBox (false, 10); // 10 is spacing between icon and label, in this case
            this.add (wrapper);
            
            // Icon
            this.icon = new Gtk.Image ();
            this.icon.set_pixel_size (64);
            
            wrapper.pack_start(this.icon, false, false, 0);
            
            // Label
            this.label = new Gtk.Label("");
            var font = new Pango.FontDescription ();
            font.set_size (10000);
            this.label.modify_font (font);
            Gdk.Color white;
            Gdk.Color.parse("#FFFFFF", out white);
            this.label.modify_fg(Gtk.StateType.NORMAL, white);
            wrapper.pack_start(this.label, false, false, 0);
            
            // Give it some padding
            this.wrapper = new Gtk.Alignment(0.5f, 0.5f, 1.0f, 1.0f);
            this.wrapper.add(this);
        
        }
    }
}
