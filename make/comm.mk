Q ?= @
TOPDIR ?= .
SELF ?= Makefile
PLAT ?=

# Toplevel rules
.PHONY: all clean topdir sub_all _all dep
.SUFFIXES:

all: dep
	${Q}${MAKE} -f ${SELF} PLAT=${PLAT} sub_all
	${Q}${MAKE} -f ${SELF} PLAT=${PLAT} _all

clean:
	${Q}rm -rf ${EXTRA_CLEAN}

topdir:
	${Q}${MAKE} -C ${TOPDIR} PLAT=${PLAT}


# Sub rules
.PHONY: ${SUBDIRS:=.all} ${SUBDIRS:=.clean} ${SUBDIRS:=.dep}

sub_all: ${SUBDIRS:=.all}

clean: ${SUBDIRS:=.clean}

dep: ${SUBDIRS:=.dep}

${SUBDIRS:=.all}:
	${Q}${MAKE} -C ${@:.all=} PLAT=${PLAT}
${SUBDIRS:=.clean}:
	${Q}${MAKE} -C ${@:.clean=} PLAT=${PLAT} clean
${SUBDIRS:=.dep}:
	${Q}${MAKE} -C ${@:.dep=} PLAT=${PLAT} dep


.PHONY: ${SUBMAKES:=.all} ${SUBMAKES:=.clean} ${SUBMAKES:=.dep}

sub_all: ${SUBMAKES:=.all}

clean: ${SUBMAKES:=.clean}

dep: ${SUBMAKES:=.dep}

${SUBMAKES:=.all}:
	${Q}${MAKE} -f ${@:.all=} SELF=${@:.all=} PLAT=${PLAT}
${SUBMAKES:=.clean}:
	${Q}${MAKE} -f ${@:.clean=} SELF=${@:.clean=} PLAT=${PLAT} clean
${SUBMAKES:=.dep}:
	${Q}${MAKE} -f ${@:.dep=} SELF=${@:.dep=} PLAT=${PLAT} dep


# Link rules
.PHONY: clean_ld
.SUFFIXES: .o
LD = CCLD="${CCLD}" ${TOPDIR}/make/scripts/gcc-ld
CCLD ?= ${CC}
AR = ar

_all: ${LIB} ${PROG}

${LIB}: ${OBJS}
	@${TOPDIR}/make/scripts/out.sh AR "${OBJS}" "$@"
	${Q}${AR} rcs ${LIB} ${OBJS}

${PROG}: ${OBJS}
	@${TOPDIR}/make/scripts/out.sh LD "${OBJS}" "$@"
	${Q}${LD} --start-group ${OBJS} --end-group -o ${PROG} ${LDFLAGS}

clean_ld:
	${Q}rm -f ${LIB} ${PROG}
clean: clean_ld
