# ML rules
.PHONY: clean_ml
.SUFFIXES: .ml .cmi .cmo .cmx
MLC = ocamlc
MLTOP = ocaml
MLOPT = ocamlopt
MLDEP = ocamldep
STDLIBDIR != ${MLC} -where
LIBDIR = ${STDLIBDIR}/..
CFLAGS += -I ${STDLIBDIR}
LDFLAGS += -L ${STDLIBDIR} -lcamlrun -lm -ldl -lunix -lcamlstr
PPXD = ${LIBDIR}/ppx_deriving
MLFLAGS += -annot #-dsource
MLFLAGS += -I ${LIBDIR}/findlib
MLFLAGS += -ppx "${PPXD}/ppx_deriving ${PPXD}/ppx_deriving_show.cma ${PPXD}/ppx_deriving_ord.cma ${PPXD}/ppx_deriving_eq.cma" \
 -I ${PPXD} -I ${LIBDIR}/result
MLMODS += unix.cma str.cma dynlink.cma findlib.cma result.cma ppx_deriving_runtime.cma
MLXMODS = ${MLMODS:.cma=.cmxa}
MLOBJS += ${MLSRCS:.ml=.cmo}
MLXOBJS = ${MLOBJS:.cmo=.cmx}
MLXOBJS := ${MLXOBJS:.cma=.cmxa}
OBJS += ${MLCLIB}

${PROG}: ${MLCLIB}
${LIB}: ${MLCLIB}

_all: ${MLLIB} ${MLLIB:.cma=.cmxa} ${MLPROG} ${MLPROG:.byte=.native}

${MLPROG}: ${MLOBJS}
	@${TOPDIR}/make/scripts/out.sh MLLD "${MLOBJS}" "$@"
	${Q}${MLC} ${MLFLAGS} -g -o $@ ${MLMODS} ${MLOBJS}

${MLPROG:.byte=.native}: ${MLXOBJS}
	@${TOPDIR}/make/scripts/out.sh OPTLD "${MLXOBJS}" "$@"
	${Q}${MLOPT} ${MLFLAGS} -g -o $@ ${MLXMODS} ${MLXOBJS}

${MLLIB}: ${MLOBJS}
	@${TOPDIR}/make/scripts/out.sh MLAR "${MLOBJS}" "$@"
	${Q}${MLC} -a ${MLFLAGS} -g -o $@ ${MLOBJS}

${MLLIB:.cma=.cmxa}: ${MLXOBJS}
	@${TOPDIR}/make/scripts/out.sh OPTAR "${MLXOBJS}" "$@"
	${Q}${MLOPT} -a ${MLFLAGS} -g -o $@ ${MLXOBJS}

${MLCLIB}: ${MLOBJS}
	@${TOPDIR}/make/scripts/out.sh MLCC "${MLOBJS}" "$@"
	${Q}${MLC} ${MLFLAGS} -output-obj -g -o $@ ${MLMODS} ${MLOBJS}

.ml.cmo:
	@${TOPDIR}/make/scripts/out.sh ML "$<" "$@"
	${Q}${MLC} ${MLFLAGS} -g -c $< -o $@

.ml.cmx:
	@${TOPDIR}/make/scripts/out.sh OPT "$<" "$@"
	${Q}${MLOPT} ${MLFLAGS} -g -c $< -o $@

.depends_ml.${SELF}: ${MLSRCS}
	@${TOPDIR}/make/scripts/out.sh DEP "$^$>" "$@"
	${Q}${MLDEP} $^$> > $@

clean_ml:
	${Q}rm -f ${MLOBJS} ${MLXOBJS} ${MLSRCS:.ml=.cmi} ${MLSRCS:.ml=.o} ${MLSRCS:.ml=.annot} ${MLPROG} ${MLPROG:.byte=.native} ${MLLIB} ${MLLIB:.cma=.cmxa} ${MLLIB:.cma=.a} ${MLCLIB} ${MLCLIB:.o=.cds} .depends_ml.${SELF}
clean: clean_ml

dep: .depends_ml.${SELF}
-include .depends_ml.${SELF}
