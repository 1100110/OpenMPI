///Found on http://geco.mines.edu/workshop/class2/examples/mpi/index.html

import std.c.stdio;
import std.c.stdlib;
import std.algorithm;
import std.array;
import std.string;
import core.memory;
import mpi;
/*
! This program shows how to use MPI_Gatherv.  Each processor sends a
! different amount of data to the root processor.  We use MPI_Gather
! first to tell the root how much data is going to be sent.
*/
/* globals */
int numnodes, myid, mpi_err;
immutable mpi_root = 0;
/* end of globals */

void init_it(int  *argc, in char ***argv) {
    mpi_err = MPI_Init(argc, argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
}

int main(string[] args)
{
    int argc = args.length;
    const char** argv = array(map!toStringz(args)).ptr;

/* poe a.out -procs 3 -rmpool 1 */
    int* sray, displacements, counts, allray;
    int size, mysize, i;

    init_it(&argc, &argv);
    mysize = myid+1;
/* counts and displacement arrays are only required on the root */
    if(myid == mpi_root)
    {
        counts= cast(int*)GC.malloc(numnodes*int.sizeof, GC.BlkAttr.NO_SCAN);
        displacements= cast(int*)GC.malloc(numnodes*int.sizeof, GC.BlkAttr.NO_SCAN);
    }
/* we gather the counts to the root */
    mpi_err = MPI_Gather(cast(void*)mysize, 1, MPI_INT,
                         cast(void*)counts,  1, MPI_INT,
                         mpi_root, MPI_COMM_WORLD);
/* calculate displacements and the size of the recv array */
    if(myid == mpi_root)
    {
        //TODO here, displacements is pointer, not array.
        displacements[0]=0;
        for( i=1; i<numnodes; i++)
        {
            displacements[i]=counts[i-1]+displacements[i-1];
        }
        size=0;
        for(i=0; i< numnodes; i++)
            size=size+counts[i];
        sray=cast(int*)GC.malloc(size*int.sizeof, GC.BlkAttr.NO_SCAN);
        for(i=0; i<size; i++)
            sray[i]=i+1;
    }
/* different amounts of data for each processor  */
/* is scattered from the root */
    allray=cast(int*)GC.malloc(int.sizeof*mysize, GC.BlkAttr.NO_SCAN);
    mpi_err = MPI_Scatterv(sray, counts, displacements, MPI_INT,
                           allray, mysize,           MPI_INT,
                     mpi_root,
                     MPI_COMM_WORLD);

    for(i=0; i<mysize; i++)
        printf("%d ", allray[i]);
    printf("\n");

    return MPI_Finalize();
}
