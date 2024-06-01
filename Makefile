.PHONY: clean
clean:
	rm install_flag

.PHONY: install
install: install_flag
install_flag:
	touch $@
	install.sh