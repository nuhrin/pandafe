[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "build-info.h")]
namespace Build {
	public const string PACKAGE_DATADIR;
	public const string LOCAL_CONFIG_DIR;
	[CCode (cheader_filename = "config.h")]
	public const string PND_APP_ID;
	[CCode (cheader_filename = "version.h")]
	public const string BUILD_VERSION;
}
