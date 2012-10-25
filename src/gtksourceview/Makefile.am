BUILT_SOURCES = 			\
	embedded_language2_rng.h \
	embedded_styles_rng.h \
	embedded_sh_lang.h \
	embedded_def_lang.h \
	embedded_classic_xml.h \
	embedded_cobalt_xml.h \
	embedded_kate_xml.h \
	embedded_oblivion_xml.h \
	embedded_tango_xml.h \
	gtksourceview-marshal.c \
	gtksourceview-marshal.h	\
	gtksourceview-typebuiltins.c \
	gtksourceview-typebuiltins.h

libgtksourceview_headers = \
	gtksourcebuffer.h \
	gtksourceiter.h	\
	gtksourceview.h	\
	gtksourcelanguage.h \
	gtksourcelanguagemanager.h \
	gtksourcestyle.h \
	gtksourcestyleschememanager.h \
	gtksourcestylescheme.h \
	gtksourcemark.h	\
	gtksourceprintcompositor.h \
	gtksourcegutter.h \
	gtksourceundomanager.h \
	gtksourcecompletion.h \
	gtksourcecompletioninfo.h \
	gtksourcecompletionitem.h \
	gtksourcecompletionproposal.h \
	gtksourcecompletionprovider.h \
	gtksourcecompletioncontext.h

embedded_classic_xml.h:
	language-specs/create-embedded-language.sh language-specs/classic.xml > $@
embedded_cobalt_xml.h:
	language-specs/create-embedded-language.sh language-specs/cobalt.xml > $@
embedded_kate_xml.h:
	language-specs/create-embedded-language.sh language-specs/kate.xml > $@
embedded_oblivion_xml.h:
	language-specs/create-embedded-language.sh language-specs/oblivion.xml > $@
embedded_tango_xml.h:
	language-specs/create-embedded-language.sh language-specs/tango.xml > $@
embedded_language2_rng.h:
	language-specs/create-embedded-language.sh language-specs/language2.rng > $@
embedded_styles_rng.h:
	language-specs/create-embedded-language.sh language-specs/styles.rng > $@
embedded_sh_lang.h:
	language-specs/create-embedded-language.sh language-specs/sh.lang > $@
embedded_def_lang.h:
	language-specs/create-embedded-language.sh language-specs/def.lang > $@

gtksourceview-marshal.h: gtksourceview-marshal.list $(GLIB_GENMARSHAL)
	$(AM_V_GEN) $(GLIB_GENMARSHAL) $< --header --prefix=_gtksourceview_marshal > $@

gtksourceview-marshal.c: gtksourceview-marshal.list $(GLIB_GENMARSHAL)
	$(AM_V_GEN) echo "#include \"gtksourceview-marshal.h\"" > $@ && \
	$(GLIB_GENMARSHAL) $< --body --prefix=_gtksourceview_marshal >> $@

gtksourceview-typebuiltins.c: stamp-gtksourceview-typebuiltins.c
	@true
stamp-gtksourceview-typebuiltins.c: Makefile.am $(libgtksourceview_headers)
	$(AM_V_GEN) (cd $(srcdir) \
	 && $(GLIB_MKENUMS) \
			--fhead "#include <glib-object.h>\n" \
			--fhead "#include \"gtksourceview-typebuiltins.h\"\n\n" \
			--fprod "\n/* enumerations from \"@filename@\" */" \
			--vhead "static const G@Type@Value _@enum_name@_values[] = {" \
			--vprod "  { @VALUENAME@, \"@VALUENAME@\", \"@valuenick@\" }," \
			--vtail "  { 0, NULL, NULL }\n};\n\n" \
			--vtail "GType\n@enum_name@_get_type (void)\n{\n" \
			--vtail "  static GType type = 0;\n\n" \
			--vtail "  if (!type)\n" \
			--vtail "    type = g_@type@_register_static (\"@EnumName@\", _@enum_name@_values);\n\n" \
			--vtail "  return type;\n}\n\n" \
		$(libgtksourceview_headers) ) > xgen-gtbec \
	&& (cmp -s xgen-gtbec gtksourceview-typebuiltins.c || cp xgen-gtbec gtksourceview-typebuiltins.c) \
	&& rm -f xgen-gtbec && echo stamp > $(@F)

gtksourceview-typebuiltins.h: stamp-gtksourceview-typebuiltins.h
	@true
stamp-gtksourceview-typebuiltins.h: Makefile.am $(libgtksourceview_headers)
	$(AM_V_GEN) (cd $(srcdir) \
	 && $(GLIB_MKENUMS) \
			--fhead "#ifndef __GTKSOURCEVIEW_TYPEBUILTINS_H__\n" \
			--fhead "#define __GTKSOURCEVIEW_TYPEBUILTINS_H__ 1\n\n" \
			--ftail "#endif /* __GTKSOURCEVIEW_TYPEBUILTINS_H__ */\n" \
			--fprod "#include <gtksourceview/@filename@>\n" \
			--eprod "G_BEGIN_DECLS\n" \
			--eprod "#define GTK_TYPE_@ENUMSHORT@ @enum_name@_get_type()\n" \
			--eprod "GType @enum_name@_get_type (void);\n" \
			--eprod "G_END_DECLS\n\n" \
		$(libgtksourceview_headers) ) > xgen-gth \
	&& (cmp -s xgen-gth gtksourceview-typebuiltins.h || cp xgen-gth gtksourceview-typebuiltins.h) \
	&& rm -f xgen-gth && echo stamp > $(@F)

EXTRA_DIST = \
	gtksourceview-marshal.list \
	$(ui_DATA)

CLEANFILES = $(BUILT_SOURCES) stamp-gtksourceview-typebuiltins.h stamp-gtksourceview-typebuiltins.c
