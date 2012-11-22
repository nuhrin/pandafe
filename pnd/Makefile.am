NULL =

SUBDIRS = previews

DATA_FILES = \
	README \
	icon.png \
	$(NULL)

EXTRA_DIST = \
	$(DATA_FILES) \
	$(NULL)

install-data-local:
	if test "x$(prefix)" = "x$(PND_MOUNT_DIR)"; then \
		$(install_sh_DATA) PXML.xml $(DESTDIR)$(PND_MOUNT_DIR); \
		$(install_sh_DATA) $(DATA_FILES) $(DESTDIR)$(PND_MOUNT_DIR); \
	fi
