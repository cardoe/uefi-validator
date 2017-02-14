
ARCH ?= $(shell uname -m)

EFIINC = /usr/include/efi
EFILIB = /usr/lib/
EFI_CRT_OBJS = $(EFILIB)/crt0-efi-$(ARCH).o
EFI_LDS = $(EFILIB)/elf_$(ARCH)_efi.lds

CFLAGS = -std=gnu99 -Wall -Wextra \
		 -fno-stack-protector -fpic -fshort-wchar -mno-red-zone \
		 -DEFI_FUNCTION_WRAPPER -I $(EFIINC) -I $(EFIINC)/$(ARCH) \
		 -I $(EFIINC)/protocol
LDFLAGS = -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic \
		  -L $(EFILIB) $(EFI_CRT_OBJS)

%.o: %.c
	$(CROSS_COMPILE)gcc -c $(CFLAGS) -o $@ $<

%.so: %.o
	$(CROSS_COMPILE)ld $(LDFLAGS) $< -o $@ -lefi -lgnuefi

%.efi: %.so
	$(CROSS_COMPILE)objcopy \
		-j .text \
		-j .sdata \
		-j .data \
		-j .dynamic \
		-j .dynsym \
		-j .rel \
		-j .rela \
		-j .reloc \
		--target=efi-app-$(ARCH) $< $@

.PHONY: clean
clean:
	rm -f *.efi *.so *.o
