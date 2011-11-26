
import std.stdio;
import std.c.stdio;
import std.array;
import std.algorithm;
import std.string;
import mpi;

int main(string[] args)
{
    int argc = args.length;
    const char** argv = array(map!toStringz(args)).ptr;

    //char idstr[128];
    //char buff[128];
    string idstr;
    string buff;

    int numprocs, rank, namelen, i;
    char processor_name[MPI_MAX_PROCESSOR_NAME];

    MPI_Status stat;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(processor_name.ptr, &namelen);

    // Based on example from https://wiki.inf.ed.ac.uk/pub/ANC/ComputationalResources/slides.pdf
    if (rank == 0)
    {
        // This is the rank-0 copy of the process
        printf("Master Processor %d Reporting!\n", rank);
        printf("We have %d processors\n", numprocs);
        // Send each process a "Hello ... " string
        for(i = 1; i < numprocs; i++)
        {
            //Do we have sprintf??
            //sprintf(buff.ptr, "Hello %d... ", i);
            buff = "Hello " ~ i.stringof ~ "...\0";
            writeln(buff);
            MPI_Send(cast(char*)buff.dup.ptr, buff.length, MPI_CHAR, i, 0, MPI_COMM_WORLD);
        }
        // Go into a blocking-receive for each servant process
        for(i = 1; i < numprocs; i++)
        {
            MPI_Recv(cast(char*)buff.dup.ptr, buff.length, MPI_CHAR, i, 0, MPI_COMM_WORLD, &stat);
            writeln(buff);
        }
    }
    else
    {
        // Go into a blocking-receive waiting
        MPI_Recv(cast(char*)buff.ptr, buff.length, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &stat);
        // Append our identity onto the received string
        idstr ~= "  Processor " ~ rank.stringof ~ " Reporting!\0";
        buff = buff[0..$-1];
        buff ~= idstr;

        // Send the string back to the rank-0 process
        MPI_Send(cast(char*)buff.dup.ptr, buff.length, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
   }

   return MPI_Finalize();
}
