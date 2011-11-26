//Thanks to drey_


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

    string idstr;
    char[1024] buff;
    buff[] = 0;  // strings are inited with UTF invalid value by default
    size_t lastBuffPos;  // track last position

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
        writefln("Master Processor %d Reporting!", rank);
        writefln("We have %d processors", numprocs);
        // Send each process a "Hello ... " string
        for(i = 1; i < numprocs; i++)
        {
            auto str = format("Hello %s", i);
            buff[lastBuffPos .. lastBuffPos + str.length] = str[];
            lastBuffPos += str.length;
            MPI_Send(buff.ptr, buff.length, MPI_CHAR, i, 0, MPI_COMM_WORLD);
        }
        // Go into a blocking-receive for each servant process
        for(i = 1; i < numprocs; i++)
        {
            MPI_Recv(buff.ptr, buff.length, MPI_CHAR, i, 0, MPI_COMM_WORLD, &stat);
            writefln("%s: %s\n", rank, buff);
        }
    }
    else
    {
        // Go into a blocking-receive waiting
        MPI_Recv(buff.ptr, buff.length, MPI_CHAR, 0, 0, MPI_COMM_WORLD, &stat);
        // Append our identity onto the received string
        auto str = format("Processor %d reporting for duty\n", rank);
        buff[lastBuffPos .. lastBuffPos + str.length] = str[];
        lastBuffPos += str.length;

        // Send the string back to the rank-0 process
        MPI_Send(buff.ptr, buff.length, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
   }

   return MPI_Finalize();
}
