NULL =

EXTRA_DIST = \
	pandafe1.png \
	pandafe2.png \
	pandafe3.png \
	pandafe4.png \
	pandafe5.png \
	$(NULL)

install-data-local:
	if test "x$(prefix)" = "x$(PND_MOUNT_DIR)"; then \
		$(mkinstalldirs) $(DESTDIR)$(PND_MOUNT_DIR)/previews; \
		$(install_sh_DATA) $(EXTRA_DIST) $(DESTDIR)$(PND_MOUNT_DIR)/previews; \
	fi

