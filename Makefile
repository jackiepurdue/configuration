.PHONY: all reset handle_dual

MAIN_D = $(HOME)/focal/oper
CONFIG_D = $(HOME)/.config

I3_N = i3
I3_STARTUP_N = startup.sh
I3_CONFIG_D = $(CONFIG_D)/$(I3_N)
I3_CONFIG_F = $(I3_CONFIG_D)/config
I3_STARTUP_CONFIG_F = $(I3_CONFIG_D)/$(I3_STARTUP_N)
I3_D = $(PWD)/$(I3_N)
I3_HEAD_F = $(I3_D)/i3-head.conf
I3_DISPLAY_TEMP_F = $(I3_D)/i3-display-temp.conf
I3_THEME_F = $(I3_D)/i3-theme.conf
I3_BINDING_F = $(I3_D)/i3-binding.conf
I3_BAR_F = $(I3_D)/i3-bar.conf

NUM_MONITORS := $(shell xrandr --listmonitors | grep Monitors: | cut -d ' ' -f 2)
MONITOR_0 := $(shell xrandr --listmonitors | grep 0: | cut -d ' ' -f 6)
MONITOR_1 := $(shell xrandr --listmonitors | grep 1: | cut -d ' ' -f 6)

ifeq ($(NUM_MONITORS),1)
	I3_DEPS = $(I3_HEAD_F) $(I3_THEME_F) $(I3_BINDING_F) $(I3_BAR_F)
else
	I3_DEPS = $(I3_HEAD_F) $(I3_THEME_F) $(I3_BINDING_F) $(I3_BAR_F)
	EXTRA_TARGETS = handle_dual
endif

I3_STATUS_CONFIG_D = $(CONFIG_D)/i3status
I3_STATUS_THEME_F = $(I3_D)/i3-status-theme.conf
I3_STATUS_ELEMENTS_DESKTOP_F = $(I3_D)/i3-status-elements-desktop.conf
I3_STATUS_ELEMENTS_LAPTOP_F = $(I3_D)/i3-status-elements-laptop.conf
I3_STATUS_CONFIG_F = $(I3_STATUS_CONFIG_D)/config

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

BROWSER_INDEX_CONFIG_F = $(BROWSER_CONFIG_D)/index.html
BROWSER_STYLES_CONFIG_F = $(BROWSER_CONFIG_D)/styles.css
BROWSER_STYLES_CONFIG_F = $(BROWSER_CONFIG_D)/styles.css
BROWSER_BUILD_TEMP_F = $(PWD)/tmp
BROWSER_BASE_F = $(BROWSER_D)/base.html
BROWSER_STYLES_F = $(BROWSER_D)/styles.css
BROWSER_BODY_F =  $(BROWSER_D)/body.html
BROWSER_HEAD_F = $(BROWSER_D)/head.html
BROWSER_SCRIPTS_F = $(BROWSER_D)/scripts.js
BROWSER_DEPS := $(BROWSER_BASE_F) $(BROWSER_STYLES_F) $(BROWSER_BODY_F) $(BROWSER_HEAD_F) $(BROWSER_SCRIPTS_F)
BROWSER_T = $(BROWSER_INDEX_CONFIG_F) $(BROWSER_STYLES_CONFIG_F)

FIREFOX_CONFIG_D = $(HOME)/.mozilla/firefox
FIREFOX_PROFILE_N = $(shell ls $(FIREFOX_CONFIG_D) | grep '[a-z0-9]*.default' | head -n 1)
FIREFOX_USER_CONFIG_D = $(FIREFOX_CONFIG_D)/$(FIREFOX_PROFILE_N)/chrome
FIREFOX_USER_CONFIG_F = $(FIREFOX_USER_CONFIG_D)/userChrome.css
FIREFOX_F = $(BROWSER_D)/browser-theme.css
FIREFOX_T = $(FIREFOX_USER_CONFIG_F)
FIREFOX_DEPS = $(FIREFOX_F)

EMACS_D = $(PWD)/emacs
EMACS_F = $(EMACS_D)/emacs.el
EMACS_ADDONS_D = $(EMACS_D)/addons
EMACS_CONFIG_F = $(HOME)/.emacs
EMACS_ADDONS_CONFIG_D = $(HOME)/.emacs.d
EMACS_DEPS = $(EMACS_F)
EMACS_T = $(EMACS_CONFIG_F) $(EMACS_ADDONS_CONFIG_D)

BASH_D = $(PWD)/bash
BASH_F = $(BASH_D)/bash.sh
BASH_CONFIG_F = $(HOME)/.bashrc
TERMINAL_F = $(BASH_D)/terminal.conf
TERMINAL_CONFIG_F = $(HOME)/.Xdefaults
BASH_DEPS = $(BASH_F) $(TERMINAL_F)
BASH_T = $(BASH_CONFIG_F) $(TERMINAL_CONFIG_F)

INIT_D = $(PWD)/init
XINIT_F = $(INIT_D)/xinitrc.conf
PROFILE_F = $(INIT_D)/profile.conf
PROFILE_CONFIG_F = $(HOME)/.bash_profile
PROFILE_TEMP_F = $(I3_D)/profile-temp.conf
XINIT_CONFIG_F = $(HOME)/.xinitrc
INIT_T = $(XINIT_CONFIG_F) $(PROFILE_CONFIG_F)
INIT_DEPS = $(XINIT_F) $(PROFILE_F)

all: $(EXTRA_TARGETS) $(I3_CONFIG_F) $(I3_STATUS_CONFIG_F) $(BROWSER_T) $(EMACS_T) $(BASH_T) $(FIREFOX_T) $(INIT_T)

$(EXTRA_TARGETS): $(I3_DEPS)

$(I3_CONFIG_F): $(I3_DEPS)
	@echo -e "\nPreparing i3-wm configuration files..."
	@echo -e $(NUM_MONITORS) "monitor(s) with display(s):" $(MONITOR_0) ", " $(MONITOR_1)
	mkdir -p $(I3_CONFIG_D)
	cat $(I3_DEPS) > $(I3_CONFIG_F)
	rm -f $(I3_DISPLAY_TEMP_F)

handle_dual:
	@echo -e "\nMultiple displays detected, creating scripts..."
	echo "#!/bin/bash" > $(I3_STARTUP_CONFIG_F)
	echo "exec xrandr --output $(MONITOR_0) --auto --output $(MONITOR_1) --left-of $(MONITOR_0)" > $(I3_STARTUP_CONFIG_F)
	mkdir -p $(I3_CONFIG_D)
	chmod +x $(I3_STARTUP_CONFIG_F)
	echo "exec --no-startup-id $(I3_STARTUP_CONFIG_F)" > $(I3_DISPLAY_TEMP_F)
	echo "workspace 6 output $(MONITOR_0)" >> $(I3_DISPLAY_TEMP_F)
	echo "workspace 1 output $(MONITOR_1)" >> $(I3_DISPLAY_TEMP_F)

$(I3_STATUS_CONFIG_F): $(I3_STATUS_DEPS)
	@echo -e "\nPreparing i3status configuration files..."
	mkdir -p $(I3_STATUS_CONFIG_D)
	cat $(I3_STATUS) > $(I3_STATUS_CONFIG_F)

$(BROWSER_INDEX_CONFIG_F) $(BROWSER_STYLES_CONFIG_F): $(BROWSER_DEPS)
	@echo -e "\nCreating a browser home page..."
	mkdir -p $(BROWSER_CONFIG_D)
	sed -e 's/^/    /' $(BROWSER_SCRIPTS_F) > $(BROWSER_BUILD_TEMP_F)
	sed -e "/_SCRIPTS_/{r $(BROWSER_BUILD_TEMP_F)" -e "d}" $(BROWSER_BASE_F) > $(BROWSER_INDEX_CONFIG_F) 
	sed -e 's/^/    /' $(BROWSER_HEAD_F) > $(BROWSER_BUILD_TEMP_F)
	sed -i -e "/_HEAD_/{r $(BROWSER_BUILD_TEMP_F)" -e "d}"  $(BROWSER_INDEX_CONFIG_F)
	sed -e 's/^/    /' $(BROWSER_BODY_F) > $(BROWSER_BUILD_TEMP_F)
	sed -i -e "/_BODY_/{r $(BROWSER_BUILD_TEMP_F)" -e "d}"  $(BROWSER_INDEX_CONFIG_F)
	rm -f $(BROWSER_BUILD_TEMP_F)
	cp -f $(BROWSER_STYLES_F) $(BROWSER_STYLES_CONFIG_F)

$(FIREFOX_T): $(FIREFOX_DEPS)
	@echo -e "\nPreparing minimalist firefox profile..."
	mkdir -p $(FIREFOX_USER_CONFIG_D)
	cp -f $(FIREFOX_F) $(FIREFOX_USER_CONFIG_F)

$(EMACS_T): $(EMACS_DEPS)
	@echo -e "\nPreparing emacs configuration files..."
	mkdir -p $(EMACS_ADDONS_CONFIG_D)
	cp -TR $(EMACS_ADDONS_D) $(EMACS_ADDONS_CONFIG_D)
	cp -f $(EMACS_F) $(EMACS_CONFIG_F)

$(BASH_T): $(BASH_DEPS)
	@echo -e "\nPreparing Bash and Urxvt configuration files..."
	cp -f $(BASH_F) $(BASH_CONFIG_F)
	cp -f $(TERMINAL_F) $(TERMINAL_CONFIG_F)
	echo -e "\ncd $(MAIN_D)" >> $(BASH_CONFIG_F)

$(INIT_T): $(INIT_DEPS)
	@echo -e "\nPreparing initialization configuration files..."	
	cp -f $(XINIT_F) $(XINIT_CONFIG_F)
	cp -f $(PROFILE_F) $(PROFILE_CONFIG_F)

reset:
	@echo -e "\nRemoving build files..."
	rm -rf $(I3_CONFIG_D)
	rm -rf $(I3_STATUS_CONFIG_D)
	rm -rf $(BROWSER_CONFIG_D)
	rm -rf $(EMACS_ADDONS_CONFIG_D)
	rm -rf $(FIREFOX_USER_CONFIG_D)
	rm -rf $(EMACS_CONFIG_F)
	rm -rf $(BASH_CONFIG_F)
	rm -rf $(TERMINAL_CONFIG_F)
	rm -rf $(PROFILE_CONFIG_F)
	rm -rf $(XINIT_CONFIG_F)
