all: vim-addon-manager.1
clean:
	rm -f vim-addon-manager.1
vim-addon-manager.1: ../bin/vim-addon-manager
	rd2 -r rd/rd2man-lib -o $(basename $@) $<
