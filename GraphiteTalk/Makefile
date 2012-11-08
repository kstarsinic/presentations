SHOWNAME 	= graphite
PDFVIEW		= xpdf -fullscreen

default: show

# Fetch http://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Graphite-layers-side-3D-balls.png/320px-Graphite-layers-side-3D-balls.png
#   as Graphite.png
# Fetch http://graphite.wikidot.com/local--files/high-level-diagram/Graphite\%20High\%20Level.png
#   as GHL.png
# Fetch http://graphite.wdfiles.com/local--files/screen-shots/graphite_fullscreen_800.png
#   as Screenshot.png

show:  $(SHOWNAME).pdf
	$(PDFVIEW) $(SHOWNAME).pdf

$(SHOWNAME).pdf: $(SHOWNAME).tex
	# This is not a typo; it's a fact of life that pdflatex takes two passes
	# to produce an up-to-date table of contents for this file:
	pdflatex $<
	pdflatex $<

clobber: clean
	-rm -f $(SHOWNAME).pdf

clean:
	-rm -f $(SHOWNAME).aux $(SHOWNAME).log $(SHOWNAME).nav $(SHOWNAME).out
	-rm -f $(SHOWNAME).snm $(SHOWNAME).toc $(SHOWNAME).vrb

