DC:=dmd
DFLAGS=-g -debug
IMPORTS=-I../
LIBS=-L-lpthread -L-lmpi -L-lopen-rte -L-lopen-pal -L-ldl -L-E -L-lnsl -L-lutil -L-lm -L-ldl
SOURCES=hello_d ring_d connectivity_d master_slave master_slave2 \
master_slave_Dstrings


################################################################################
#	'all' assumes that flags conform to dmd. (dmd -inline -O...)
#	It also assumes that you have DC and DFLAGS predefined.
################################################################################

all: $(SOURCES)

%: %.o
	$(DC) $< $(LIBS) -of$@

%.o: %.d
	$(DC) $(DFLAGS) $(IMPORTS) -c $<

run: $(SOURCES)
	echo "running hello_d with 5 threads" && \
	mpirun -np 5 hello_d && \
	echo "running ring_d with 5 threads" && \
	mpirun -np 5 ring_d  && \
	echo "running connectivity_d with 25 threads" && \
	mpirun -np 25 connectivity_d
################################################################################
#	Compile with gdmd and/or gdc if you have them.
################################################################################
gdmd:
	export DC=gdmd && $(MAKE) -e
###		For some reason gdmd works on my system, but gdc doesn't...
gdc:
	export DC=gdc && $(MAKE) -e

################################################################################
#	Clean up all of the files [g]dmd could have possibly written.
################################################################################
clean:
	rm -rf *.o *.gcov *.gcda *.gcno $(SOURCES)

