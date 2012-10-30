NULL =

SUBDIRS = previews

DATA_FILES = \
	README \
	icon.png \
	$(NULL)

SCRIPT_FILES = \
	pandafe.sh \
	$(NULL)

EXTRA_DIST = \
	$(DATA_FILES) \
	$(SCRIPT_FILES) \
	$(NULL)

install-data-local:
	if test "x$(prefix)" = "x$(PND_MOUNT_DIR)"; then \
		$(install_sh_DATA) PXML.xml $(DESTDIR)$(PND_MOUNT_DIR); \
		$(install_sh_DATA) $(DATA_FILES) $(DESTDIR)$(PND_MOUNT_DIR); \
	fi

install-exec-local:
	if test "x$(prefix)" = "x$(PND_MOUNT_DIR)"; then \
		$(install_sh_SCRIPT) $(SCRIPT_FILES) $(DESTDIR)$(PND_MOUNT_DIR); \
	fi
