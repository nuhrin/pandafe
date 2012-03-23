using Gee;
using Data;
using Fields;
using Menus.Fields;
using Layers.Preview;

namespace Menus.Concrete
{
	public class GameBrowserAppearanceMenu : Menu  
	{
		GameBrowserUI ui;
		GameBrowserAppearance appearance;
		GameBrowserAppearance? default_appearance;
		
		public GameBrowserAppearanceMenu(string name, GameBrowserAppearance appearance, GameBrowserAppearance? default_appearance=null) {
			base(name);
			this.appearance = appearance;
			this.default_appearance = default_appearance;
			ui = appearance.create_ui(default_appearance);
			ensure_items();
		}
		
	
		protected override bool do_save() {
			bool has_color_change = false;
			if (item_color.has_changes()) {
				appearance.item_color = item_color.value;
				has_color_change = true;
			}
			if (selected_item_color.has_changes()) {
				appearance.selected_item_color = selected_item_color.value;
				has_color_change = true;
			}
			if (background_color.has_changes()) {
				appearance.background_color = background_color.value;
				has_color_change = true;
			}
			
			bool has_font_change = false;
			if (font.has_changes()) {
				appearance.font = font.value;
				has_font_change = true;
			}
			
			return true;			
		}
		
		protected override Layers.Layer? build_additional_menu_browser_layer() { 
			return new BrowserPreview(235, ui);
		}
		
		protected override void populate_items(Gee.List<MenuItem> items) { 
			font = new FileField("font", "Font", null, "", "ttf", Path.build_filename(Config.PACKAGE_DATADIR, "fonts"));
			item_color = new ColorField("item_color", "Item Color");
			selected_item_color = new ColorField("selected_item_color", "Selected Item Color");
			background_color = new ColorField("background_color", "Background Color");
			items.add(font);
			items.add(item_color);
			items.add(selected_item_color);
			items.add(background_color);
			if (default_appearance != null && default_appearance.has_data()) {
				items.add(new MenuItem.custom("Defaults", "Reset to the default appearance for the current context" , null, () => {
					if (default_appearance.font != null)
						font.value = default_appearance.font;
					if (default_appearance.item_color != null)
						item_color.value = default_appearance.item_color;
					if (default_appearance.selected_item_color != null)
						selected_item_color.value = default_appearance.selected_item_color;
					if (default_appearance.background_color != null)
						background_color.value = default_appearance.background_color;
					refresh(4);
				}));
			}
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
