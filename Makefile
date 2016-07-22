include /usr/share/templar/make/Makefile

##############
# parameters #
##############

# where are the sources ?
SOURCE_DIR:=src
# where is the output folder ?
OUT_DIR:=out
# do you want dependency on the makefile itself ?
DO_ALL_DEPS:=1
# do you want to show the commands executed ?
DO_MKDBG:=0
# the prime file
PRIME:=riddling
# the primary pdf file name
PRIME_PDF:=$(OUT_DIR)/$(PRIME).pdf
# the primary swf file name
PRIME_SWF:=$(OUT_DIR)/$(PRIME).swf
# the primary html file name
PRIME_HTM:=$(OUT_DIR)/$(PRIME)/index.php
# the primary output folder
PRIME_HTM_FOLDER:=$(OUT_DIR)/$(PRIME)
# do you want to do PDF ?
DO_PDF:=1
# do you want to do HTML ?
DO_HTML:=0
# do you want to do SWF ?
DO_SWF:=0
# do you want to generate dependencies ?
DO_DEP:=0
# do you want to actually include the deps ? (must enable DO_DEP)
DO_INCLUDE:=1
# what to export out (to grive and dropbox)?
OUTPUTS_TO_EXPORT:=$(PRIME_PDF)
# what is the name of the project?
PROJECT:=$(notdir $(CURDIR))
# do you want to validate html?
DO_CHECKHTML:=1
# what is the web folder?
WEB_DIR:=../riddling-gh-pages
# what folder to copy on web install?
COPY_FOLDERS:=out web static
# what is the stamp file for the tools?
TOOLS:=tools.stamp

ALL_DEP+=$(TOOLS)

########
# code #
########

# tools
TOOL_LATEX2HTML:=latex2html
TOOL_LACHECK:=lacheck
TOOL_SKETCH:=sketch
TOOL_PDFLATEX:=pdflatex
#USE_LATEX2PDF:=scripts/latex2pdf.pl
USE_LATEX2PDF:=scripts/wrapper_pdflatex.pl

# the tag name of the project ?
TAG:=$(shell git tag | tail -1)
# web stuff...
WEB_PDF:=$(WEB_DIR)/$(PRIME).pdf
WEB_ZIP:=$(WEB_DIR)/$(PRIME).zip
WEB_FOLDER:=web
# dependency on the makefile itself
ifeq ($(DO_ALL_DEPS),1)
ALL_DEPS:=Makefile
else
ALL_DEPS:=
endif

# silent stuff
ifeq ($(DO_MKDBG),1)
Q:=
# we are not silent in this branch
else # DO_MKDBG
Q:=@
#.SILENT:
endif # DO_MKDBG

SOURCES_TEX:=$(shell find src -name "*.tex")

SOURCES_SK:=$(shell find src -name "*.sk")
OBJECTS_SK:=$(addsuffix .tex,$(addprefix $(OUT_DIR)/,$(basename $(SOURCES_SK))))

OBJECTS_PDF:=$(addsuffix .pdf,$(addprefix $(OUT_DIR)/,$(notdir $(basename $(SOURCES_TEX)))))
OBJECTS_SWF:=$(addsuffix .swf,$(addprefix $(OUT_DIR)/,$(notdir $(basename $(SOURCES_TEX)))))
OBJECTS_HTM:=$(addsuffix /index.html,$(addprefix $(OUT_DIR)/,$(notdir $(basename $(SOURCES_TEX)))))
OBJECTS_DEP:=$(addsuffix .dep,$(addprefix $(OUT_DIR)/,$(notdir $(basename $(SOURCES_TEX)))))

ifeq ($(DO_PDF),1)
ALL+=$(OBJECTS_PDF)
endif # DO_PDF
ifeq ($(DO_HTML),1)
ALL+=$(OBJECTS_HTM)
endif # DO_HTML
ifeq ($(DO_SWF),1)
ALL+=$(OBJECTS_SWF)
endif # DO_SWF
ifeq ($(DO_DEP),1)
ALL+=$(OBJECTS_DEP)
endif # DO_DEP

# do not include deps if the target is 'clean'...
ifeq ($(MAKECMDGOALS),clean)
DO_INCLUDE:=0
endif # clean

SOURCES_HTML:=web/index.html
HTMLCHECK:=html.stamp
ifeq ($(DO_CHECKHTML),1)
ALL+=$(HTMLCHECK)
all: $(ALL)
endif # DO_CHECKHTML

.PHONY: check_veltzer_https
check_veltzer_https:
	$(info doing [$@])
	$(Q)wrapper_ok git grep "http:\/\/veltzer.net"
.PHONY: check_all
check_all: check_veltzer_https

.PHONY: deps
deps: $(OBJECTS_DEP)

.PHONY: debug_me
debug_me:
	$(info SOURCES_TEX is $(SOURCES_TEX))
	$(info SOURCES_SK is $(SOURCES_SK))
	$(info OBJECTS_SK is $(OBJECTS_SK))
	$(info OBJECTS_PDF is $(OBJECTS_PDF))
	$(info OBJECTS_SWF is $(OBJECTS_SWF))
	$(info OBJECTS_HTM is $(OBJECTS_HTM))
	$(info OBJECTS_DEP is $(OBJECTS_DEP))
	$(info SOURCES_HTML is $(SOURCES_HTML))
	$(info PRIME is $(PRIME))
	$(info PRIME_PDF is $(PRIME_PDF))
	$(info PRIME_HTM is $(PRIME_HTM))
	$(info PRIME_HTM_FOLDER is $(PRIME_HTM_FOLDER))
	$(info TAG is $(TAG))
	$(info ALL is $(ALL))
	$(info WEB_FOLDER is $(WEB_FOLDER))
	$(info OUTPUTS_TO_EXPORT is $(OUTPUTS_TO_EXPORT))
	$(info PROJECT is $(PROJECT))

# RULES

$(TOOLS): scripts/tools.py
	$(Q)./scripts/tools.py
	$(Q)make_helper touch-mkdir $@

$(OBJECTS_PDF): $(OUT_DIR)/%.pdf: $(SOURCE_DIR)/%.tex $(ALL_DEPS) $(OBJECTS_SK) $(USE_LATEX2PDF)
	$(info doing [$@])
	$(Q)$(TOOL_LACHECK) $< 2> /dev/null > /dev/null
	$(Q)$(USE_LATEX2PDF) $< $@

$(OBJECTS_HTM): $(OUT_DIR)/%/index.html: $(SOURCE_DIR)/%.tex $(ALL_DEPS) $(OBJECTS_SK)
	$(info doing [$@])
	$(Q)-rm -rf $(dir $@)
	$(Q)mkdir $(dir $@) 2> /dev/null || exit 0
	$(Q)$(TOOL_LATEX2HTML) $< --dir=$(dir $@) > /dev/null 2> /dev/null

$(OBJECTS_DEP): $(OUT_DIR)/%.dep: $(SOURCE_DIR)/%.tex $(ALL_DEPS) scripts/latex2dep.pl
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)scripts/latex2dep.pl $< $@

$(OBJECTS_SK): $(OUT_DIR)/%.tex: %.sk $(ALL_DEPS) scripts/wrapper_sketch.pl
	$(info doing [$@])
	$(Q)mkdir -p $(dir $@)
	$(Q)scripts/wrapper_sketch.pl $< $@

$(OBJECTS_SWF): $(OUT_DIR)/%.swf: $(OUT_DIR)/%.pdf $(ALL_DEPS)
	$(info doing [$@])
	$(Q)-rm -f $@
	$(Q)mkdir -p $(dir $@)
	$(Q)pdf2swf -T 9 -f $< $@ 2> /dev/null > /dev/null
	$(Q)chmod 444 $@

# short cut to see meta data about the produced pdf
.PHONY: pdfinfo
pdfinfo: $(PRIME_PDF)
	pdfinfo $(PRIME_PDF)
# short cut to show the riddling pdf output fast...
.PHONY: view_pdf
view_pdf: $(PRIME_PDF)
	gnome-open $(PRIME_PDF) > /dev/null 2> /dev/null &
# short cut to show the html output fast...
.PHONY: view_htm
view_htm: $(PRIME_HTM)
	gnome-open $(PRIME_HTM) > /dev/null 2> /dev/null &
# short cut to show the swf using flex paper fast...
.PHONY: view_swf
view_swf: $(PRIME_SWF)
	gnome-open http://www.veltzer.net/riddling/flexpaper/index.html > /dev/null 2> /dev/null &

.PHONY: install
install: $(ALL) $(ALL_DEP)
	$(info doing [$@])
	$(Q)rm -rf $(WEB_DIR)/*
	$(Q)for folder in $(COPY_FOLDERS); do cp -r $$folder $(WEB_DIR); done
	$(Q)cp support/redirector.html $(WEB_DIR)/index.html
	cd $(WEB_DIR); git commit -a -m "new version"; git push

.PHONY: view_sketch_doc_htm
view_sketch_doc_htm:
	$(Q)gnome-open /usr/share/doc/sketch-doc/sketch/index.html > /dev/null 2> /dev/null &
.PHONY: view_sketch_doc_pdf
view_sketch_doc_pdf:
	$(Q)gnome-open /usr/share/doc/sketch-doc/sketch.pdf.gz > /dev/null 2> /dev/null &
.PHONY: view_pdftex_doc_pdf
view_pdftex_doc_pdf:
	$(Q)gnome-open /usr/share/doc/texlive-doc/pdftex/manual/pdftex-s.pdf > /dev/null 2> /dev/null &
.PHONY: view_luatex_doc_pdf
view_luatex_doc_pdf:
	$(Q)gnome-open /usr/share/doc/texmf/luatex/base/luatexref-t.pdf
.PHONY: view_pgf_doc_pdf
view_pgf_doc_pdf:
	$(Q)gnome-open /usr/share/doc/texmf/pgf/pgfmanual.pdf.gz

.PHONY: grive
grive: $(OUTPUTS_TO_EXPORT) $(ALL_DEP)
	$(info doing [$@])
	$(Q)-rm -rf ~/grive/outputs/$(PROJECT)
	$(Q)-mkdir ~/grive/outputs/$(PROJECT)
	$(Q)cp $(OUTPUTS_TO_EXPORT) ~/grive/outputs/$(PROJECT)
	$(Q)cd ~/grive; grive

.PHONY: dropbox
dropbox: $(OUTPUTS_TO_EXPORT) $(ALL_DEP)
	$(info doing [$@])
	$(Q)-rm -rf ~/Dropbox/outputs/$(PROJECT)
	$(Q)-mkdir ~/Dropbox/outputs/$(PROJECT)
	$(Q)cp $(OUTPUTS_TO_EXPORT) ~/Dropbox/outputs/$(PROJECT)

ifeq ($(DO_INCLUDE),1)
# include the deps files (no warnings)
-include $(OBJECTS_DEP)
endif # DO_INCLUDE

$(HTMLCHECK): $(SOURCES_HTML) $(ALL_DEP)
	$(info doing [$@])
	$(Q)tidy -errors -q -utf8 $(SOURCES_HTML)
	$(Q)./node_modules/htmlhint/bin/htmlhint $(SOURCES_HTML) > /dev/null
	$(Q)mkdir -p $(dir $@)
	$(Q)touch $(HTMLCHECK)
