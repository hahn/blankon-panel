
namespace Raipad.Frontend {

    public class PageIndicator : Gtk.EventBox {

        public Gtk.Label label;

        public PageIndicator (int number) {
        
            // EventBox Properties
            this.set_visible_window(false);
        
            this.label = new Gtk.Label(number.to_string());
            var font = new Pango.FontDescription ();
            font.set_size (11000);
            this.label.modify_font (font);
            Gdk.Color gray;
            Gdk.Color.parse("#333333", out gray);
            this.label.modify_fg(Gtk.StateType.NORMAL, gray);
            
            this.add(Raipad.Frontend.Utilities.wrap_alignment(this.label, 5, 15, 5, 15));
        
        }
        
    }
}
