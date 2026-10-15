SHELL := /bin/bash
SCRIPT_FILES := .bashrc .lessfilter
SYMLINK_FILES := .config/Code/User/settings.json .shellcheckrc  bin/bear_cc .clangd
SYMLINK_FILES += .claude/skills/commit .claude/skills/supply-chain

# WSL1 kernel releases end in "-Microsoft"
ifneq ($(shell uname -r | grep Microsoft),)
    $(info WSL1 detected)
    SYMLINK_FILES += bin/node bin/claude bin/install_node_claude
endif

FILES := $(SCRIPT_FILES) $(SYMLINK_FILES) .gdbinit .inputrc .ssh/config .tmux.conf .vimrc .config/pnpm/config.yaml
# Files on a remote machine; ssh config should be unnecessary 
REMOTE_FILES := $(filter-out .config/Code/User/settings.json .ssh/config,$(FILES))
WSL_FILES := $(filter-out .config/Code/User/settings.json,$(FILES))
ZO_FILES := $(REMOTE_FILES)
FILE_FLAGS := $(patsubst %,%_install_flag,$(FILES))

nothing:
	@echo no default make target

.PHONY: clean_install
# TODO: uninstall scripts
clean_install: 
	-rm install_flag $(FILE_FLAGS)

.PHONY: install_local
install_local: $(FILE_FLAGS) run_once_flag

.PHONY: install_wsl
install_wsl: $(patsubst %,%_install_flag,$(WSL_FILES)) run_once_flag

.PHONY: install_remote
install_remote: $(patsubst %,%_install_flag,$(REMOTE_FILES)) run_once_flag

.PHONY: install_zo
install_zo: $(patsubst %,%_install_flag,$(ZO_FILES)) run_once_flag

run_once_flag: | run_once.sh
	./run_once.sh
	touch $@

$(FILE_FLAGS): %_install_flag : | %
$(patsubst %,%_install_flag,$(SCRIPT_FILES)):
	. install.sh && append_sh_source_file '$|'
	touch $@
$(patsubst %,%_install_flag,$(SYMLINK_FILES)):
	. install.sh && symlink_file '$|'
	touch $@
.gdbinit_install_flag:
	. install.sh && gdbinit_install '$|'
	touch $@
.inputrc_install_flag:
	. install.sh && append_source_file '$$include' '$|'
	touch $@
.ssh/config_install_flag:
	. install.sh && append_source_file Include '$|'
	touch $@
.tmux.conf_install_flag:
	. install.sh && append_source_file source '$|'
	touch $@
.vimrc_install_flag:
	. install.sh && append_source_file so '$|'
	touch $@
# pnpm reads its global config from ~/Library/Preferences on macOS
.config/pnpm/config.yaml_install_flag:
	. install.sh && if [[ $$(uname) == Darwin ]]; then symlink_file '$|' Library/Preferences/pnpm/config.yaml; else symlink_file '$|'; fi
	touch $@
