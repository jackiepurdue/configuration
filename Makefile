.PHONY: all

BUILD_N = build
BUILD_D= $(PWD)/$(BUILD_N)
CONFIG_D = $(HOME)/.config

I3_N = i3
I3_CONFIG_D = $(CONFIG_D)/$(I3_N)
I3_STARTUP_CONFIG_F = $(I3_CONFIG_D)/startup.sh
I3_BUILD_D = $(BUILD_D)/$(I3_N)
I3_D = $(PWD)/$(I3_N)
I3_HEAD_F = $(I3_D)/i3-head.conf
I3_DISPLAY_F = $(I3_D)/i3-display.conf
I3_THEME_F = $(I3_D)/i3-theme.conf
I3_BINDING_F = $(I3_D)/i3-binding.conf
I3_BAR_F = $(I3_D)/i3-bar.conf
I3_STARTUP_F = $(I3_D)/startup.sh
I3_BUILD_F = $(I3_BUILD_D)/i3.conf

NUM_MONITORS := $(shell xrandr --listmonitors | grep Monitors: | cut -d ' ' -f 2)
MONITOR_0 := $(shell xrandr --listmonitors | grep 0: | cut -d ' ' -f 6)
MONITOR_1 := $(shell xrandr --listmonitors | grep 1: | cut -d ' ' -f 6)

ifeq ($(NUM_MONITORS),1)
	I3_DEPS = $(I3_HEAD_F) $(I3_THEME_F) $(I3_BINDING_F) $(I3_BAR_F)
else
	I3_DEPS = $(I3_HEAD_F) $(I3_DISPLAY_F) $(I3_THEME_F) $(I3_BINDING_F) $(I3_BAR_F)
	EXTRA_TARGETS = handle_dual
endif

I3_STATUS_CONFIG_D = $(CONFIG_D)/i3status
I3_STATUS_THEME_F = $(I3_D)/i3-status-theme.conf
I3_STATUS_ELEMENTS_DESKTOP_F = $(I3_D)/i3-status-elements-desktop.conf
I3_STATUS_ELEMENTS_LAPTOP_F = $(I3_D)/i3-status-elements-laptop.conf
I3_STATUS_CONFIG_F = $(I3_STATUS_CONFIG_D)/config
I3_STATUS_BUILD_F = $(I3_BUILD_D)/i3-status.conf

LAPTOP_OR_DESKTOP := $(shell if [ "$(find  /sys/class/power_supply -mindepth 1 -print -quit 2>/dev/null)" ]; then echo "Desktop"; else echo "Laptop"; fi)

ifeq ($(LAPTOP_OR_DESKTOP),Laptop)
	I3_STATUS = $(I3_STATUS_THEME_F) $(I3_STATUS_ELEMENTS_LAPTOP_F)
	I3_STATUS_DEPS := $(I3_STATUS)
else
        I3_STATUS := $(I3_STATUS_THEME_F) $(I3_STATUS_ELEMENTS_DESKTOP_F)
	I3_STATUS_DEPS := $(I3_STATUS)
endif

BROWSER_N = browser
BROWSER_CONFIG_D = $(CONFIG_D)/browser-start
BROWSER_D = $(PWD)/$(BROWSER_N)
BROWSER_BUILD_D= $(BUILD_D)/$(BROWSER_N)

BROWSER_INDEX_CONFIG_F = $(BROWSER_CONFIG_D)/index.html
BROWSER_STYLES_CONFIG_F = $(BROWSER_CONFIG_D)/styles.css
BROWSER_STYLES_CONFIG_F = $(BROWSER_CONFIG_D)/styles.css
BROWSER_BUILD_TMP_F = $(BROWSER_BUILD_D)/tmp
BROWSER_BUILD_F = $(BROWSER_BUILD_D)/index.html $(BROWSER_BUILD_D)/styles.css
BROWSER_BASE_F = $(BROWSER_D)/base.html
BROWSER_STYLES_F = $(BROWSER_D)/styles.css 
BROWSER_BODY_F =  $(BROWSER_D)/body.html
BROWSER_HEAD_F = $(BROWSER_D)/head.html
BROWSER_SCRIPTS_F = $(BROWSER_D)/scripts.js
BROWSER_BUILD_INDEX_F = $(BROWSER_BUILD_D)/index.html
BROWSER_BUILD_STYLES_F = $(BROWSER_BUILD_D)/styles.css
BROWSER := $(BROWSER_BASE_F) $(BROWSER_STYLES_F) $(BROWSER_BODY_F) $(BROWSER_HEAD_F) $(BROWSER_SCRIPTS_F)

FIREFOX_CONFIG_D = $(HOME)/.mozilla/firefox
FIREFOX_PROFILE_N = $(shell ls $(FIREFOX_CONFIG_D) | grep '[a-z0-9]*.default' | head -n 1)
FIREFOX_USER_CONFIG_D = $(FIREFOX_CONFIG_D)/$(FIREFOX_PROFILE_N)/chrome
FIREFOX_USER_CONFIG_F = $(FIREFOX_USER_CONFIG_D)/userChrome.css 
FIREFOX_F = $(BROWSER_D)/browser-theme.css
FIREFOX_BUILD_D = $(BROWSER_BUILD_D)
FIREFOX_BUILD_F = $(FIREFOX_BUILD_D)/firefox.css
FIREFOX_T = $(FIREFOX_BUILD_F) $(FIREFOX_USER_CONFIG_F)
FIREFOX_DEPS = $(FIREFOX_F)

EMACS_D = $(PWD)/emacs
EMACS_F = $(EMACS_D)/emacs.el
EMACS_ADDONS_D = $(EMACS_D)/addons
EMACS_CONFIG_F = $(HOME)/.emacs
EMACS_ADDONS_CONFIG_D = $(HOME)/.emacs.d
EMACS_BUILD_D = $(BUILD_D)/emacs
EMACS_BUILD_F = $(EMACS_BUILD_D)/emacs.el
EMACS_ADDONS_BUILD_D = $(EMACS_BUILD_D)/addons
EMACS_DEPS = $(EMACS_F)
EMACS_T = $(EMACS_BUILD_F) $(EMACS_CONFIG_F) $(EMACS_ADDONS_BUILD_D) $(EMACS_ADDONS_CONFIG_D)

BASH_D = $(PWD)/bash
BASH_F = $(BASH_D)/bash.sh
BASH_CONFIG_F = $(HOME)/.bashrc
TERMINAL_F = $(BASH_D)/terminal.conf
TERMINAL_CONFIG_F = $(HOME)/.Xdefaults
BASH_BUILD_D = $(BUILD_D)/bash
BASH_BUILD_F =  $(BASH_BUILD_D)/bash.sh
TERMINAL_BUILD_F = $(BASH_BUILD_D)/terminal.conf
BASH_DEPS = $(BASH_F) $(TERMINAL_F)
BASH_T = $(BASH_BUILD_F) $(BASH_CONFIG_F) $(TERMINAL_BUILD_F) $(TERMINAL_CONFIG_F)

all: $(EXTRA_TARGETS) $(I3_BUILD_F) $(I3_STATUS_BUILD_F) $(BROWSER_BUILD_F) $(EMACS_T) $(BASH_T) $(FIREFOX_T)

$(EXTRA_TARGETS): $(I3_DEPS)

$(I3_BUILD_F): $(I3_DEPS) 
	@echo -e "\nPreparing i3-wm config files..."
	echo -e $(NUM_MONITORS) "monitor(s) with display(s):" $(MONITOR_0) ", " $(MONITOR_1)
	mkdir -p $(I3_BUILD_D)
	cat $(I3_DEPS) > $(I3_BUILD_F)
	mkdir -p $(I3_CONFIG_D)
	ln -sf $(I3_BUILD_F) $(I3_CONFIG_D)/config

handle_dual:
	echo "#!/bin/bash" > $(I3_STARTUP_F)
	echo "exec xrandr --output $(MONITOR_0) --auto --output $(MONITOR_1) --left-of $(MONITOR_0)" > $(I3_STARTUP_F)
	chmod +x $(I3_STARTUP_F)
	cp -f $(I3_STARTUP_F) $(I3_STARTUP_CONFIG_F)
	echo "exec --no-startup-id $(I3_STARTUP_CONFIG_F)" > $(I3_DISPLAY_F)
	echo "workspace 6 output $(MONITOR_0)" >> $(I3_DISPLAY_F)
	echo "workspace 1 output $(MONITOR_1)" >> $(I3_DISPLAY_F)

$(I3_STATUS_BUILD_F): $(I3_STATUS_DEPS) 
	@echo -e "\nPreparing i3status config files..."
	mkdir -p $(I3_BUILD_D)
	cat $(I3_STATUS) > $(I3_STATUS_BUILD_F)
	mkdir -p $(I3_STATUS_CONFIG_D)
	ln -sf $(I3_STATUS_BUILD_F) $(I3_STATUS_CONFIG_F)

$(BROWSER_BUILD_F): $(BROWSER_DEPS)
	@echo -e "\nPreparing browser start page..."
	mkdir -p $(BROWSER_BUILD_D)
	sed -e 's/^/    /' $(BROWSER_SCRIPTS_F) > $(BROWSER_BUILD_TMP_F)
	sed -e "/_SCRIPTS_/{r  $(BROWSER_BUILD_TMP_F)" -e "d}" $(BROWSER_BASE_F) > $(BROWSER_BUILD_INDEX_F)
	sed -e 's/^/    /' $(BROWSER_HEAD_F) > $(BROWSER_BUILD_TMP_F)
	sed -i -e "/_HEAD_/{r $(BROWSER_BUILD_TMP_F)" -e "d}" $(BROWSER_BUILD_INDEX_F)
	sed -e 's/^/    /' $(BROWSER_BODY_F) > $(BROWSER_BUILD_TMP_F)
	sed -i -e "/_BODY_/{r $(BROWSER_BUILD_TMP_F)" -e "d}" $(BROWSER_BUILD_INDEX_F)
	rm $(BROWSER_BUILD_TMP_F)
	mkdir -p $(BROWSER_CONFIG_D)
	cp -rf $(BROWSER_STYLES_F) $(BROWSER_BUILD_STYLES_F)
	ln -sf $(BROWSER_BUILD_STYLES_F) $(BROWSER_STYLES_CONFIG_F)
	ln -sf $(BROWSER_BUILD_INDEX_F) $(BROWSER_INDEX_CONFIG_F)

$(FIREFOX_T): $(FIREFOX_DEPS)
	@echo -e "\nPreparing $(FIREFOX_USER_CONFIG_D) config files..."
	mkdir -p $(FIREFOX_USER_CONFIG_D)
	mkdir -p $(FIREFOX_BUILD_D)
	cp -rf $(FIREFOX_F) $(FIREFOX_BUILD_F)
	ln -sf $(FIREFOX_BUILD_F) $(FIREFOX_USER_CONFIG_F)

$(EMACS_T):$(EMACS_DEPS)
	@echo -e "\nPreparing emacs config files..."
	mkdir -p $(EMACS_BUILD_D)
	cp -TR $(EMACS_ADDONS_D) $(EMACS_ADDONS_BUILD_D)
	cp -TR $(EMACS_F) $(EMACS_BUILD_F)
	ln -sfT $(EMACS_ADDONS_D) $(EMACS_ADDONS_CONFIG_D)
	ln -sfT $(EMACS_BUILD_F) $(EMACS_CONFIG_F)

$(BASH_T): $(BASH_DEPS)
	@echo -e "\nPreparing bashrc and Xdefaults config files..."
	mkdir -p $(BASH_BUILD_D)
	cp -TR $(BASH_F) $(BASH_BUILD_F)
	cp -TR $(TERMINAL_F) $(TERMINAL_BUILD_F)
	ln -sf $(BASH_BUILD_F) $(BASH_CONFIG_F)
	ln -sf $(TERMINAL_BUILD_F) $(TERMINAL_CONFIG_F)

reset:
	@echo 'Deleting stuff...'
	rm -rf $(EMACS_ADDONS_CONFIG_D)/auto-save-list/*
	rm -rf $(BUILD_D)/*
	rm -rf $(FIREFOX_USER_CONFIG_D)
	rm -rf $(EMACS_CONFIG_F)
	rm -rf $(BASH_CONFIG_F)
	rm -rf $(TERMINAL_CONFIG_F)
