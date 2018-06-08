.PHONY: _help
_help: ## Print out the help for this Makefile include.
	@cat $(makefile_dir)README.txt
	@printf '\n%s\n' '-----------------------'
	@$(MAKE) _targets

# To add a target to the help, add a double comment (##) on the target line.
.PHONY: _targets
_targets: ## Print out the available targets in this include.
# 	# The code below was adapted to allow for targets with % in them and to
#	# continue to work even as an include. The original concept was taken from
# 	# https://github.com/nodejs/node/blob/f05eaa4a537ed7ef57814d951d64c25ef2844720/Makefile#L73-L78.
	@printf "Available targets:\n\n"
	@grep -h -E '^[a-zA-Z0-9%._-]+:.*?## .*$$' $(makefile_dir){Makefile,*.mk} 2>/dev/null | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@printf "\nFor more targets and info see the comments in the Makefile.\n"

# We need bash to use =~ regex tests in if statements.
SHELL := /bin/bash
# Turn off interactive mode in Composer for all subshells.
export COMPOSER_NO_INTERACTION := 1

#######
# Local variables below. Keep local variables lowercase to differentiate.
#
# The command to run to install a package or packages.
minimal-package-install := apt-get install --no-install-recommends -y
# Determine the path to this file.
makefile_dir := $(dir $(lastword $(MAKEFILE_LIST)))
# A macro to retrieve the composer signature. This uses a recursively expanded
# assignment so that it's only evaluated if needed.
composer_expected_signature = $(shell wget -q -O - https://composer.github.io/installer.sig)
# Determine the current PHP version in MAJOR.MINOR format. We use a recursively
# expanded variable so that it's only evaluated if we want the value.
current_php_version = $(shell php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;" 2>/dev/null)

# To keep build times faster, we can run apt-get update just once by having this
# as a dependency to install-package-%.
.PHONY: packages-update
packages-update: ## Gets information on the newest versions of packages and their dependencies.
	apt-get update

# Install an apt package by passing the value. For example, to install wget, use
# install-package-wget as the target.
.PHONY: install-package-%
install-package-%: packages-update ## Install a specific package on this distro by replacing %, e.g. install-package-wget.
	$(minimal-package-install) $(*)

# Installs the latest version of Composer. Note, you should use install-php-%
# first to ensure your desired version of PHP is installed.
.PHONY: install-composer
install-composer: install-package-wget ## Installs the latest version of Composer.
	$(info Installing Composer...)
#	# The following code is adapted from https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
	wget -O composer-setup.php https://getcomposer.org/installer
	@if ! sha384sum composer-setup.php | grep ${composer_expected_signature}; then \
		>&2 echo 'ERROR: Invalid installer signature'; \
		rm composer-setup.php; \
		exit 1; \
	fi

	php composer-setup.php --install-dir=/tmp
	mv -f /tmp/composer.phar /usr/local/bin/composer
	rm composer-setup.php
#	# Install hirak/prestissimo to speed up composer operations.
	composer --no-ansi global require hirak/prestissimo
	@echo "Composer installed."

# Installs the latest version of drush.
.PHONY: install-drush
install-drush: install-composer install-package-rsync ## Installs the latest version of drush.
	$(info Installing Drush...)
	composer --no-ansi global require drush/drush
	ln -sf /root/.composer/vendor/bin/drush /usr/bin/drush
	@echo "Drush installed."

# Installs the drush-launcher instead of drush.
.PHONY: install-drush-launcher
install-drush-launcher: install-package-wget ## Installs the drush-launcher instead of drush.
	$(info Installing Drush Launcher...)
	wget -O /tmp/drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar
	mv -f /tmp/drush.phar /usr/bin/drush
	chmod +x /usr/bin/drush
	@echo "Drush Launcher installed."

# Install terminus for Pantheon sites.
.PHONY: install-terminus
install-terminus: install-composer install-package-rsync ## Install terminus for Pantheon sites.
	$(info Installing Terminus...)
	curl -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar
	php installer.phar install
	@echo "Terminus installed."

# Install a specific version of PHP by passing the version to this target. Use
# major and minor versions separated by a dot. For example, install-php-7.2.
.PHONY: install-php-%
install-php-%: ## Install a specific version of PHP by replacing the %, e.g. install-php-7.2.
	$(info Installing PHP $*...)
#	# Ensure PHP version is correctly formatted.
	@if [[ ! "$*" =~ ^[0-9]\.[0-9]$$ ]]; then\
		echo "PHP version $* is an invalid format.";\
		exit 1;\
	fi
#	# Ensure installed PHP version isn't the current version to be installed.
	@if [ "$*" = "${current_php_version}" ]; then\
		echo "Current PHP Version is already ${current_php_version}.";\
	else \
		$(minimal-package-install) python-software-properties software-properties-common;\
		LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php;\
		$(MAKE) packages-update;\
		$(minimal-package-install) \
			php$(*) \
			php$(*)-bcmath \
			php$(*)-bz2 \
			php$(*)-cli \
			php$(*)-common \
			php$(*)-curl \
			php$(*)-dev \
			php$(*)-gd \
			php$(*)-intl \
			php$(*)-json \
			php$(*)-mbstring \
			php$(*)-mysql \
			php$(*)-opcache \
			php$(*)-phpdbg \
			php$(*)-pspell \
			php$(*)-readline \
			php$(*)-recode \
			php$(*)-soap \
			php$(*)-sqlite3 \
			php$(*)-tidy \
			php$(*)-xml \
			php$(*)-xsl \
			php$(*)-zip;\
		if [[ "$$TUGBOAT_SERVICE" == apache* ]]; then\
			$(MAKE) install-package-libapache2-mod-php$(*);\
			a2enmod php$(*);\
			a2dismod php$(current_php_version) || /bin/true;\
		elif [[ "$$TUGBOAT_SERVICE" == nginx* ]]; then\
			$(MAKE) install-package-php$(*)-fpm;\
		fi;\
		echo "PHP $(*) installed.";\
	fi

# Install a specific version of nodejs by passing the version to this target.
# Use the major version only. For example, install-nodejs-9.
.PHONY: install-nodejs-%
install-nodejs-%: install-package-curl ## Install a specific version of nodejs by replacing the %, e.g. install-nodejs-8.
	$(info Installing nodejs $*...)
#	# Ensure nodejs version is correctly formatted.
	@if [[ ! $* =~ ^[0-9]$$ ]]; then\
		echo "Version number $* is an invalid format. Specify the major version only.";\
		exit 1;\
	fi
	curl -sL https://deb.nodesource.com/setup_$(*).x | bash -
	$(MAKE) install-package-nodejs
	@echo "Installed nodejs $(*).x."

# Include any *.mk files in /usr/share/tugboat. This allows other images to
# add to or modify what's in here without having to overwrite this file.
-include $(makefile_dir)*.mk