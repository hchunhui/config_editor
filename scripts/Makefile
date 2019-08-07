TOPDIR = ..

all: nk.so driver

nk.so:
	ln -sf ${TOPDIR}/lua-nk/nk.so .
driver:
	ln -sf ${TOPDIR}/driver/driver .

dep:

clean:
	@rm -f nk.so driver
