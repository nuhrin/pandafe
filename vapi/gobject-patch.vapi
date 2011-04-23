[CCode (cprefix = "G", lower_case_cprefix = "g_", cheader_filename = "glib.h", gir_namespace = "GObject", gir_version = "2.0")]
namespace GLibPatch {
	[CCode (lower_case_csuffix = "flags")]
  	public class FlagsClass : GLib.TypeClass {
    	public unowned FlagsValue? get_first_value (uint value);
    	public unowned FlagsValue? get_value_by_name (string name);
    	public unowned FlagsValue? get_value_by_nick (string name);
    	public uint mask;
    	public uint n_values;
    	[CCode (array_length_cname = "n_values")]
    	public FlagsValue[] values;
	}

	[CCode (has_type_id = false)]
	public struct FlagsValue {
    	public int value;
    	public unowned string value_name;
    	public unowned string value_nick;
  	}
}