NULL =

fontsdir=$(pkgdatadir)/fonts
dist_fonts_DATA = \
	deluxefontregular.ttf \
	emulator.ttf \
	$(NULL)

$(dist_fonts_DATA):
	$(NULL)

install-data-hook:
	rm -f $(DESTDIR)$(fontsdir)/system
	ln -s /usr/share/fonts/truetype \
		$(DESTDIR)$(fontsdir)/system
