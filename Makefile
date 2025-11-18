application = rails-app
version = 0.0.1

build_root_dir = build/$(application)_$(version)-1_arm64
build_dir_prefix = $(build_root_dir)/usr/local/share/$(application)

source_dirs = app bin config db lib public
source_files = $(shell find $(source_dirs) -type f) config.ru Gemfile Gemfile.lock Rakefile

build/rails-app_$(version)-1_arm64.deb: \
		$(build_dir_prefix) \
		$(build_root_dir)/DEBIAN/control \
		$(build_root_dir)/DEBIAN/postinst \
		$(build_root_dir)/var/local/$(application)/data \
		$(build_root_dir)/var/local/$(application)/log \
		$(build_root_dir)/var/local/$(application)/tmp \
		$(build_dir_prefix)/vendor/cache \
		$(addprefix $(build_dir_prefix)/,$(source_files))
	cd build && dpkg-deb --build --root-owner-group $(application)_$(version)-1_arm64

$(build_root_dir)/DEBIAN/control: DEBIAN/control
	cp -a --parents DEBIAN/control $(build_root_dir)

$(build_root_dir)/DEBIAN/postinst: DEBIAN/postinst
	cp -a --parents DEBIAN/postinst $(build_root_dir)

$(build_root_dir)/var/local/$(application)/data: $(build_dir_prefix)
	mkdir -p $@ && chmod 0775 $@

$(build_root_dir)/var/local/$(application)/log: $(build_dir_prefix)
	mkdir -p $@ && chmod 0775 $@

$(build_root_dir)/var/local/$(application)/tmp: $(build_dir_prefix)
	mkdir -p $@ && chmod 0775 $@

$(addprefix $(build_dir_prefix)/,$(source_files)): $(source_files)
	cp -a --parents $? $(build_dir_prefix)

$(build_dir_prefix)/vendor/cache: $(build_dir_prefix) Gemfile.lock
	bundle install --path=$@

$(build_dir_prefix):
	mkdir -p $@

.PHONY: install
install:
	dpkg -i build/rails-app_$(version)-1_arm64.deb

.PHONY: clean
clean:
	rm -fr build
