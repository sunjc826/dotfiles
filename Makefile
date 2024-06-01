SHELL := /bin/bash
SCRIPT_FILES := .bashrc .lessfilter
FILES := $(SCRIPT_FILES) .gdbinit .inputrc .shellcheckrc .vimrc
SCRIPT_FILE_FLAGS := $(patsubst %,%_install_flag,$(SCRIPT_FILES))
FILE_FLAGS := $(patsubst %,%_install_flag,$(FILES))

.PHONY: clean_install
# TODO: uninstall scripts
clean_install: 
	-rm install_flag $(FILE_FLAGS)

.PHONY: install
install: $(FILE_FLAGS)
$(FILE_FLAGS): %_install_flag : %
$(SCRIPT_FILE_FLAGS): %_install_flag : %
	. install.sh && append_sh_source_file '$<'
	touch $@
.gdbinit_install_flag:
	. install.sh && gdbinit_install
	touch $@
.inputrc_install_flag:
	. install.sh && append_source_file '$$include' .inputrc
	touch $@
.shellcheckrc_install_flag:
	. install.sh && ln -s '$(realpath .shellcheckrc)' "$$HOME"/.shellcheckrc
	touch $@ 
.vimrc_install_flag:
	. install.sh && append_source_file so .vimrc
	touch $@
