# -- This is used only for building the software itself.
#    It only requires two externally visible targets, "build"
#    and "install", which will be called from the "Makefile"
#    by the RPM build process.
# -- For a listing of paths (and their usual values), see the bottom
#    of this template (and feel free to remove the boilerplate).
#
# -- The following path variables are available at both build
#    and installation time.  The resulting package will
#    need to know these things at installation time, too.
#    (They will be in our environment, but may as well not
#    rely on that.)
#
ATELERIX_MK := atelerix.mk /usr/lib/atelerix/atelerix.mk
ATX         := $(shell ls 2>/dev/null $(ATELERIX_MK))
ifeq ($(ATX),)
  $(error Could not find atelerix in $(ATELERIX_MK))
else
  include $(firstword $(ATX))
endif

DESTDIR := /

default: build

# -- Add any files which need to be passed through a transformation
#    (for build-time variable intepolation) in the BUILT_FILES list.
#
BUILT_FILES := atelerix-script
BUILT_FILES += main.conf

CLEAN_FILES :=
MANPAGES    := 
POD2MANS    :=

# -- Used by the tests target--any package-specific TESTARGS should go
#    in here, but default, empty.
#
TESTARGS :=

# -- Do you need custom variables of your own in your package to be
#    replaced inline in the code?  See how MY_VARIABLE is added to the
#    substitution script data in $(SUBDATA)-hook below.  The variable
#    can be used just like @PACKAGE_ETC@ in your .in files.
#
# MY_VARIABLE  := contents_of_variable

$(BUILT_FILES): %: %.in $(SUBDATA)
	python $(SUBSCRIPT) $(SUBDATA) < $< > $@

$(MANPAGES): %.1: %
	pod2man --section 1 > $@ $<

$(POD2MANS): %.1: %.pod
	pod2man --section 1 > $@ $<

.PHONY: build-clean
build-clean:
	rm -rf $(BUILT_FILES) $(MANPAGES) $(POD2MANS) $(CLEAN_FILES)

.PHONY: build 
build: $(SUBSCRIPT) $(SUBDATA) $(BUILT_FILES) $(MANPAGES) $(POD2MANS)

.PHONY: tests
tests: build
	./test.sh $(TESTARGS)

.PHONY: install
install: build
	# -- put things into /usr/lib/$(PACKAGE)
	#
	mkdir -p                         $(DESTDIR)$(PACKAGE_ROOT)
	install -m 0755 atelerix-script  $(DESTDIR)$(PACKAGE_ROOT)
	install -m 0644 atelerix.mk      $(DESTDIR)$(PACKAGE_ROOT)
	#
	# -- install config files into /etc/atelerix/$(PACKAGE)
	#
	mkdir -p                  $(DESTDIR)$(PACKAGE_ETC)
	install -m 0644 main.conf $(DESTDIR)$(PACKAGE_ETC)
	#
	# -- install any data files into /usr/share/$(PACKAGE)
	#
	# mkdir -p                  $(DESTDIR)$(PACKAGE_SHARE)
	# install -m 0644 something $(DESTDIR)$(PACKAGE_SHARE)
	#
	# -- install systemd unit file into /usr/lib/systemd/system
	#
	#  mkdir -p                          $(DESTDIR)$(SYSTEMD)
	#  install -m 0644 frobnitz.service  $(DESTDIR)$(SYSTEMD)
	#
	# -- install sysconfig unit file into /etc/sysconfig
	#
	#  mkdir -p                   $(DESTDIR)$(SYSCONFIG)
	#  install -m 0644 frobnitz   $(DESTDIR)$(SYSCONFIG)
	#
	# -- This packaging system CAN work with Python, if you like...
	#
	# -- Have Python drop its bits (modules, etc.) into the $(DESTDIR) and
	#    keep track of what it put in there... then use %files -f INSTALLED_FILES
	#    in your specfile.in
	#
	#python setup.py install -O1 --root=$(DESTDIR) --record=INSTALLED_FILES
	#

# MY_VARIABLE := something_silly
# ANOTHER_VAR := /path/to/somewhere/else
# and for the target fragment
#      @printf >> $(SUBDATA) "%s\t%s\n" \
#        MY_VARIABLE         "$(MY_VARIABLE)" \
#        ANOTHER_VAR         "$(ANOTHER_VAR)"
.PHONY: $(SUBDATA)-hook
$(SUBDATA)-hook:

# -- Would you like to skip certain files or directories from $PWD during
#    'make testrpm'?  Just put filenames into the $(EXPORT_EXCL) file
$(EXPORT_EXCL)::
	touch $(EXPORT_EXCL)

# -- The following Makefile variables are available to you here for
#    controlling the destination directory of your installation.  The
#    conventional defaults are shown!
#
#    PACKAGE        := frobnitz
#    VERSION        := 0.1.3
#    PACKAGE_ROOT   := /usr/lib/frobnitz
#    PACKAGE_ETC    := /etc/atelerix/frobnitz
#    PACKAGE_SHARE  := /usr/share/frobnitz
#    PACKAGE_SPOOL  := /var/spool/frobnitz
#    PACKAGE_CACHE  := /var/cache/frobnitz
#    PACKAGE_TMP    := /var/tmp/frobnitz
#    NAGIOS_PLUGINS := /usr/lib/nagios/plugins
#    APACHE_ROOT    := /etc/httpd              # -- on RedHat boxen
#    VAR            := /var
#    ETC            := /etc
#    BINDIR         := /usr/bin
#    SBINDIR        := /usr/sbin
#    SHARE          := /usr/share
#    LIBEXEC        := /usr/libexec
#    MANDIR         := /usr/share/man
#
# -- end of Makefile.build
