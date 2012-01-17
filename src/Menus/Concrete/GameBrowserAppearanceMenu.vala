using Fields;
using Menus.Fields;
using Layers.Preview;

namespace Menus.Concrete
{
	public class GameBrowserAppearanceMenu : Menu  
	{
		GameBrowserUI ui;
		GameBrowserUI original_ui;
		
		public GameBrowserAppearanceMenu(string name, GameBrowserUI ui) {
			base(name);
			original_ui = ui;
			this.ui = ui.clone();
			ensure_items();		
		}
		
		public override bool cancel() {
			ui.set_font(original_ui.font_path);
			ui.set_colors(original_ui.item_color, original_ui.selected_item_color, original_ui.background_color);
			initialize(ui);
			return true;
		}
	
		public override bool save() {
			var prefs = Data.preferences();
			bool has_color_change = false;
			if (item_color.has_changes()) {
				prefs.item_color = item_color.value;
				has_color_change = true;
			}
			if (selected_item_color.has_changes()) {
				prefs.selected_item_color = selected_item_color.value;
				has_color_change = true;
			}
			if (background_color.has_changes()) {
				prefs.background_color = background_color.value;
				has_color_change = true;
			}
			
			bool has_font_change = false;
			if (font.has_changes()) {
				prefs.font = font.value;
				has_font_change = true;
			}
			
			if (has_color_change == false && has_font_change == false)
				return true;
		
			bool success = Data.save_preferences();
			// TODO: display error if there was a problem saving prefs?
			if (success) {
				if (has_color_change == true)
					@interface.game_browser_ui.update_colors_from_preferences();
				if (has_font_change == true)
					@interface.game_browser_ui.update_font_from_preferences();					
			}
			
			return true;
		}
		
		protected override Layers.Layer? build_additional_menu_browser_layer() { 
			return new BrowserPreview(250, ui);
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			font = new FileField("font", "Font", null, "", "ttf", "/usr/share/fonts/truetype");
			item_color = new ColorField("item_color", "Item Color");
			selected_item_color = new ColorField("selected_item_color", "Selected Item Color");
			background_color = new ColorField("background_color", "Background Color");
			items.add(font);
			items.add(item_color);
			items.add(selected_item_color);
			items.add(background_color);
			items.add(new MenuItem.cancel_item());
			items.add(new MenuItem.save_item());
			initialize(ui);
			font.changed.connect(on_font_change);
			item_color.changed.connect(on_color_change);
			selected_item_color.changed.connect(on_color_change);
			background_color.changed.connect(on_color_change);
		}
		
		void initialize(GameBrowserUI ui) {
			font.value = ui.font_path;
			item_color.value = new Data.Color.from_sdl(ui.item_color);
			selected_item_color.value = new Data.Color.from_sdl(ui.selected_item_color);
			background_color.value = new Data.Color.from_sdl(ui.background_color);
		}
		void on_font_change() {
			ui.set_font(font.value);
		}
		void on_color_change() {
			ui.set_colors(item_color.value.get_sdl_color(), 
						  selected_item_color.value.get_sdl_color(),
						  background_color.value.get_sdl_color());
		}
		
		FileField font;
		ColorField item_color;
		ColorField selected_item_color;
		ColorField background_color;
	}

}
