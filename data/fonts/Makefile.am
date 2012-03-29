NULL =

fontsdir=$(pkgdatadir)/fonts
dist_fonts_DATA = \
	bitwise-license.txt \
	bitwise.ttf \
	monof55.ttf \
	$(NULL)

$(dist_fonts_DATA):
	$(NULL)

install-data-hook:
	rm -f $(DESTDIR)$(fontsdir)/system
	ln -s /usr/share/fonts/truetype \
		$(DESTDIR)$(fontsdir)/system
	ln -s /mnt/utmp/$(PND_APP_ID)/fonts \
		$(DESTDIR)$(fontsdir)/user
