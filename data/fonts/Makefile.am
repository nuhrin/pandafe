NULL =

fontsdir=$(pkgdatadir)/fonts
dist_fonts_DATA = \
	ArchitectsDaughter-license.txt \
	ArchitectsDaughter.ttf \
	bitwise-license.txt \
	bitwise.ttf \
	monof55-license.txt \
	monof55.ttf \
	repet___-license.txt \
	repet___.ttf \
	SeattleAvenue-license.txt \
	SeattleAvenue.ttf \
	$(NULL)

$(dist_fonts_DATA):
	$(NULL)

install-data-hook:
	rm -f $(DESTDIR)$(fontsdir)/system
	ln -s /usr/share/fonts/truetype \
		$(DESTDIR)$(fontsdir)/system
	rm -f $(DESTDIR)$(fontsdir)/user
	ln -s $(PND_MOUNT_DIR)/fonts \
		$(DESTDIR)$(fontsdir)/user
