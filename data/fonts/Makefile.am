NULL =

fontsdir=$(pkgdatadir)/fonts
dist_fonts_DATA = \
	bitwise-license.txt \
	bitwise.ttf \
	commodore-64-v621c.ttf \
	deluxefontregular.ttf \
	emulator.ttf \
	pixelcarnagemono.ttf \
	$(NULL)

$(dist_fonts_DATA):
	$(NULL)

install-data-hook:
	rm -f $(DESTDIR)$(fontsdir)/system
	ln -s /usr/share/fonts/truetype \
		$(DESTDIR)$(fontsdir)/system
