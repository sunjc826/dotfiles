SHELL := /bin/bash
SCRIPT_FILES := .bashrc .lessfilter
FILES := $(SCRIPT_FILES) .gdbinit .inputrc .shellcheckrc .ssh/config .vimrc
# Files on a remote machine; ssh config should be unnecessary 
REMOTE_FILES := $(filter-out .ssh/config,$(FILES))
FILE_FLAGS := $(patsubst %,%_install_flag,$(FILES))

nothing:
	@echo no default make target 

.PHONY: clean_install
# TODO: uninstall scripts
clean_install: 
	-rm install_flag $(FILE_FLAGS)

.PHONY: install_local
install_local: $(FILE_FLAGS)
.PHONY: install_remote
install_remote: $(patsubst %,%_install_flag,$(REMOTE_FILES))
$(FILE_FLAGS): %_install_flag : | %
$(patsubst %,%_install_flag,$(SCRIPT_FILES)):
	. install.sh && append_sh_source_file '$|'
	touch $@
.gdbinit_install_flag:
	. install.sh && gdbinit_install
	touch $@
.inputrc_install_flag:
	. install.sh && append_source_file $$include '$|'
	touch $@
.shellcheckrc_install_flag:
	. install.sh && ln -s '$(realpath $|)' "$$HOME"/'$|'
	touch $@
.ssh/config_install_flag:
	. install.sh && append_source_file Include '$|'
	touch $@
.vimrc_install_flag:
	. install.sh && append_source_file so '$|'
	touch $@
