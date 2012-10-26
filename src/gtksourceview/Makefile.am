NULL =

SUBDIRS = language-specs

EMBEDDED_LANG_H_FILES = \
	embedded_sh_lang.h \
	embedded_def_lang.h \
	embedded_classic_xml.h \
	embedded_cobalt_xml.h \
	embedded_kate_xml.h \
	embedded_oblivion_xml.h \
	embedded_tango_xml.h \
	$(NULL)

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
embedded_sh_lang.h:
	language-specs/create-embedded-language.sh language-specs/sh.lang > $@
embedded_def_lang.h:
	language-specs/create-embedded-language.sh language-specs/def.lang > $@

GENERATED_GTKSOURCEVIEW_FILES = \
	gtksourceview-marshal.c \
	gtksourceview-marshal.h	\
	gtksourceview-typebuiltins.c \
	gtksourceview-typebuiltins.h \
	$(NULL)

BUILT_SOURCES = \
	$(EMBEDDED_LANG_H_FILES) \
	$(GENERATED_GTKSOURCEVIEW_FILES) \
	$(NULL)

MAIN_H_FILES = \
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
	gtksourcecompletioncontext.h \
	$(NULL)

EXTRA_H_FILES = \
    gtksourcecompletionmodel.h  \
    gtksourcecompletion-private.h   \
    gtksourcecompletionutils.h  \
    gtksourcecompletionui.h     \
    gtksourcecontextengine.h    \
    gtksourceengine.h       \
    gtksourcegutter-private.h   \
    gtksourcelanguage-private.h \
    gtksourcestyle-private.h    \
    gtksourceundomanagerdefault.h   \
    gtksourceview-i18n.h        \
    gtksourceview-utils.h       \
    gtktextregion.h


gtksourceview-marshal.h: gtksourceview-marshal.list $(GLIB_GENMARSHAL)
	$(AM_V_GEN) $(GLIB_GENMARSHAL) $< --header --prefix=_gtksourceview_marshal > $@

gtksourceview-marshal.c: gtksourceview-marshal.list $(GLIB_GENMARSHAL)
	$(AM_V_GEN) echo "#include \"gtksourceview-marshal.h\"" > $@ && \
	$(GLIB_GENMARSHAL) $< --body --prefix=_gtksourceview_marshal >> $@

gtksourceview-typebuiltins.c: stamp-gtksourceview-typebuiltins.c
	@true
stamp-gtksourceview-typebuiltins.c: Makefile.am $(GLIB_MKENUMS) $(MAIN_H_FILES)
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
		$(MAIN_H_FILES) ) > xgen-gtbec \
	&& (cmp -s xgen-gtbec gtksourceview-typebuiltins.c || cp xgen-gtbec gtksourceview-typebuiltins.c) \
	&& rm -f xgen-gtbec && echo stamp > $(@F)

gtksourceview-typebuiltins.h: stamp-gtksourceview-typebuiltins.h
	@true
stamp-gtksourceview-typebuiltins.h: Makefile.am $(GLIB_MKENUMS) $(MAIN_H_FILES)
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
		$(MAIN_H_FILES) ) > xgen-gth \
	&& (cmp -s xgen-gth gtksourceview-typebuiltins.h || cp xgen-gth gtksourceview-typebuiltins.h) \
	&& rm -f xgen-gth && echo stamp > $(@F)

EXTRA_DIST = \
	gtksourceview-marshal.list \
	$(GENERATED_GTKSOURCEVIEW_FILES) \
	$(MAIN_H_FILES) \
	$(EXTRA_H_FILES) \
	stamp-gtksourceview-typebuiltins.h \
	stamp-gtksourceview-typebuiltins.c \
	$(NULL)

CLEANFILES = \
	$(BUILT_SOURCES) \
	stamp-gtksourceview-typebuiltins.h \
	stamp-gtksourceview-typebuiltins.c \
	$(NULL)
