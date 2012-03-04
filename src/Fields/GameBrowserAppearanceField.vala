using Data;
using Menus;
using Menus.Concrete;
using Menus.Fields;
using Layers.Controls;

namespace Fields
{
	public class GameBrowserAppearanceField : MenuItemField
	{
		string? title;
		GameBrowserAppearance? appearance;
		GameBrowserAppearance? default_appearance;
		public GameBrowserAppearanceField(string id, string name, string? help=null, string? menu_title, GameBrowserAppearance? appearance, GameBrowserAppearance? default_appearance=null) {
			base(id, name, help);
			this.title = menu_title;
			this.appearance = appearance;
			this.default_appearance = default_appearance;
		}

		public new GameBrowserAppearance? value {
			get { return appearance; }
			set { change_value(value); }
		}

		public override string get_value_text() { return ""; }
		public override int get_minimum_menu_value_text_length() { return 0; }

		protected override Value get_field_value() { return appearance; }
		protected override void set_field_value(Value value) { change_value((GameBrowserAppearance?)value); }
		protected override bool has_value() { return (appearance != null && appearance.has_data()); }
		protected override bool is_menu_item() { return true; }

		protected override void activate(MenuSelector selector) {
			var new_appearance = appearance ?? new GameBrowserAppearance();
			var menu = new GameBrowserAppearanceMenu(title ?? "Appearance", new_appearance, default_appearance);
			menu.saved.connect(() => {
				change_value(new_appearance);
			});
			new MenuBrowser(menu).run();
		}
		
		bool change_value(GameBrowserAppearance? new_value) {
			appearance = new_value;
			changed();
			return true;
		}
	}
}
