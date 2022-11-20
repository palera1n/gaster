.PHONY: macos libusb ios payload clean

CC ?= clang

macos: gen
	xcrun -sdk macosx clang -mmacosx-version-min=10.9 -Weverything gaster.c lzfse.c -o gaster -framework CoreFoundation -framework IOKit -Os -DVERSION=\"$(VERSION)\"
	$(RM) payload_A9.h payload_notA9.h payload_notA9_armv7.h payload_handle_checkm8_request.h payload_handle_checkm8_request_armv7.h

gen:
	xxd -iC payload_A9.bin payload_A9.h
	xxd -iC payload_notA9.bin payload_notA9.h
	xxd -iC payload_notA9_armv7.bin payload_notA9_armv7.h
	xxd -iC payload_handle_checkm8_request.bin payload_handle_checkm8_request.h
	xxd -iC payload_handle_checkm8_request_armv7.bin payload_handle_checkm8_request_armv7.h

libusb: gen
	$(CC) -Wall -Wextra -Wpedantic -DHAVE_LIBUSB gaster.c lzfse.c -o gaster -lusb-1.0 -lcrypto -pthread -ldl -Os -DVERSION=\"$(VERSION)\"
	$(RM) payload_A9.h payload_notA9.h payload_notA9_armv7.h payload_handle_checkm8_request.h payload_handle_checkm8_request_armv7.h

libusb-static: gen
	$(CC) $(CFLAGS) $(LIBS) $(LDFLAGS) -Wall -Wextra -Wpedantic -DHAVE_LIBUSB gaster.c lzfse.c -o gaster -Os -static -DVERSION=\"$(VERSION)\"
	$(RM) payload_A9.h payload_notA9.h payload_notA9_armv7.h payload_handle_checkm8_request.h payload_handle_checkm8_request_armv7.h

payload:
	as -arch arm64 payload_A9.S -o payload_A9.o
	gobjcopy -O binary -j .text payload_A9.o payload_A9.bin
	$(RM) payload_A9.o
	as -arch arm64 payload_notA9.S -o payload_notA9.o
	gobjcopy -O binary -j .text payload_notA9.o payload_notA9.bin
	$(RM) payload_notA9.o
	as -arch armv7 payload_notA9_armv7.S -o payload_notA9_armv7.o
	gobjcopy -O binary -j .text payload_notA9_armv7.o payload_notA9_armv7.bin
	$(RM) payload_notA9_armv7.o
	as -arch arm64 payload_handle_checkm8_request.S -o payload_handle_checkm8_request.o
	gobjcopy -O binary -j .text payload_handle_checkm8_request.o payload_handle_checkm8_request.bin
	$(RM) payload_handle_checkm8_request.o
	as -arch armv7 payload_handle_checkm8_request_armv7.S -o payload_handle_checkm8_request_armv7.o
	gobjcopy -O binary -j .text payload_handle_checkm8_request_armv7.o payload_handle_checkm8_request_armv7.bin
	$(RM) payload_handle_checkm8_request_armv7.o

clean:
	$(RM) gaster
