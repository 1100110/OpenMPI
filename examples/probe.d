/* Shows how to use probe & get_count to find the size of an */
/* incomming message                                         */
///Found on http://geco.mines.edu/workshop/class2/examples/mpi/index.html



import std.c.stdio;
import std.string;
import std.algorithm;
import std.array;
import mpi;
import core.memory;


int main(string[] args)
{
    int argc = args.length;
    const char** argv = array(map!toStringz(args)).ptr;

    int myid, numprocs;
    MPI_Status status;
    int mytag, ierr, icount, j;
    int* i;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myid);

    printf("Hello from D process: %d | Number of Processors is %d\n", myid, numprocs);

    mytag=123;
    if(myid == 0)
    {
        j=200;
        icount=1;
        ierr=MPI_Send(&j, icount, MPI_INT, 1, mytag, MPI_COMM_WORLD);
    }
    if(myid == 1)
    {
        ierr=MPI_Probe(0, mytag, MPI_COMM_WORLD, &status);
        ierr=MPI_Get_count(&status, MPI_INT, &icount);

        i = cast(int*)GC.malloc(icount*int.sizeof, GC.BlkAttr.NO_SCAN);

        printf("getting %d\n", icount);

        ierr = MPI_Recv(i, icount, MPI_INT, 0, mytag, MPI_COMM_WORLD, &status);

        printf("i= ");

        for(j=0;j<icount;j++)
            printf("%d ",i[j]);
        printf("\n");
    }
    return MPI_Finalize();
}
