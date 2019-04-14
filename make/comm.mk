Q ?= @

# Toplevel rules
.PHONY: all clean topdir _all dep
.SUFFIXES:

all: dep _all

_all: dep

clean:
	${Q}rm -rf ${EXTRA_CLEAN}

topdir:
	${MAKE} -C ${TOPDIR}


# Sub rules
.PHONY: ${SUBDIRS:=.all} ${SUBDIRS:=.clean} ${SUBDIRS:=.dep}

_all: ${SUBDIRS:=.all}

clean: ${SUBDIRS:=.clean}

dep: ${SUBDIRS:=.dep}

${SUBDIRS:=.all}:
	${MAKE} -C ${@:.all=}
${SUBDIRS:=.clean}:
	${MAKE} -C ${@:.clean=} clean
${SUBDIRS:=.dep}:
	${MAKE} -C ${@:.dep=} dep


# Link rules
.PHONY: clean_ld
.SUFFIXES: .o
LD ?= cc
AR = ar

_all: ${LIB} ${PROG}

${LIB}: ${OBJS}
	@${TOPDIR}/make/scripts/out.sh AR "${OBJS}" "$@"
	${Q}${AR} rcsT ${LIB} ${OBJS}

${PROG}: ${OBJS}
	@${TOPDIR}/make/scripts/out.sh LD "${OBJS}" "$@"
	${Q}${LD} -Wl,--start-group ${OBJS} -Wl,--end-group -o ${PROG} ${LDFLAGS}

clean_ld:
	${Q}rm -f ${LIB} ${PROG}
clean: clean_ld
