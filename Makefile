OPENSCAD := openscad-nightly
MONTAGE := montage
targets := $(filter-out _%,$(wildcard *.scad))
stls := $(targets:.scad=.stl)
image_dir := images
thumbnails := $(targets:%.scad=${image_dir}/%_thumb.png)
img_models := ${image_dir}/models.png

.PHONY: all clean clean_images images
all: ${stls}
	@echo done

${stls}: %.stl: %.scad
	@echo Building $@ from $<
	${OPENSCAD} -o $@ $<

clean:
	rm -f ${stls}

clean_images:
	rm ${thumbnails} ${img_models}

images: $(thumbnails) ${img_models}
	@echo done

$(thumbnails): ${image_dir}/%_thumb.png: %.scad
	@echo Generating $@ from $<
	${OPENSCAD} -o $@ \
		--imgsize=480,320 --colorscheme=Solarized \
		--projection o --viewall --view axes $<

${img_models}: ${thumbnails}
	@echo Generating $@ from $^
	${MONTAGE} -label '%t' -pointsize 16 -geometry 480x320 $(sort $^) $@
