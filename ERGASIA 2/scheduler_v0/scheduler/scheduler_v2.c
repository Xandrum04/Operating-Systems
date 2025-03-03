/* Spiridon Mantadakis, 1100613 */
/* Apostolos Zekyrias, 1100554 */
/* Alexandros Georgios Chalampakis, 1100754 */
/* Panagiwths Papanikolaou, 1104804 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/time.h>
#include <time.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAX_LINE_LENGTH 80

void fcfs();


#define PROC_NEW    0
#define PROC_STOPPED 1
#define PROC_RUNNING 2
#define PROC_EXITED 3

typedef struct proc_desc {
    struct proc_desc *next;
    char name[80];
    int pid;
    int status;
    int processors_required;  // Νέο πεδίο για απαιτούμενους επεξεργαστές
    double t_submission, t_start, t_end;
} proc_t;

struct single_queue {
    proc_t *first;
    proc_t *last;
    long members;
};

struct single_queue global_q;
int total_processors;  // Συνολικοί επεξεργαστές του συστήματος
int available_processors;  // Διαθέσιμοι επεξεργαστές

#define proc_queue_empty(q) ((q)->first==NULL)

void proc_queue_init(register struct single_queue *q)
{
    q->first = q->last = NULL;
    q->members = 0;
}


void proc_to_rq (register proc_t *proc)
{
	if (proc_queue_empty (&global_q))
		global_q.last = proc;
	proc->next = global_q.first;
	global_q.first = proc;
}

void proc_to_rq_end(register proc_t *proc)
{
    if (proc_queue_empty(&global_q))
        global_q.first = global_q.last = proc;
    else {
        global_q.last->next = proc;
        global_q.last = proc;
        proc->next = NULL;
    }
}

proc_t *proc_rq_dequeue()
{
    register proc_t *proc;

    proc = global_q.first;
    if (proc == NULL) return NULL;

    global_q.first = proc->next;
    proc->next = NULL;

    return proc;
}

void print_queue()
{
	proc_t *proc;

	proc = global_q.first;
	while (proc != NULL) {
		printf("proc: [name:%s pid:%d]\n", 
			proc->name, proc->pid);
		proc = proc->next;
	}
}

double proc_gettime()
{
    struct timeval tv;
    gettimeofday(&tv, 0);
    return (double)(tv.tv_sec + tv.tv_usec / 1000000.0);
}



#define FCFS    0


int policy = FCFS;
int quantum = 100; /* ms */
proc_t *running_proc;
double global_t;

void err_exit(char *msg)
{
    printf("Error: %s\n", msg);
    exit(1);
}

int main(int argc, char **argv)
{
    FILE *input;
    char exec[80];
    int processors;
    int c;
    proc_t *proc;

    if (argc == 1) {
		err_exit("invalid usage");
	} else if (argc == 2) {
		input = fopen(argv[1],"r");
		
	} else if (argc > 2) {
		if (!strcmp(argv[1],"FCFS")) {
			policy = FCFS;
			input = fopen(argv[2],"r");

			if (argc == 4) 
			    total_processors = atoi(argv[3]);
			else 
			    total_processors = 1;// Default 

	    } 
        } else {
			err_exit("invalid usage");
		}
	

if (input == NULL) err_exit("invalid input file name");
if (total_processors <= 0) err_exit("invalid number of processors");

available_processors = total_processors;

    /* Read input file */
    while ((c = fscanf(input, "%s %d", exec, &processors)) != EOF) {
        proc = malloc(sizeof(proc_t));
        proc->next = NULL;
        strcpy(proc->name, exec);
        proc->pid = -1;
        proc->status = PROC_NEW;
        proc->processors_required = processors;
        proc->t_submission = proc_gettime();
        proc_to_rq_end(proc);
    }

    global_t = proc_gettime();
    switch (policy) {
        case FCFS:
            fcfs();
            break;

 

        default:
            err_exit("Unimplemented policy");
            break;
    }

    printf("WORKLOAD TIME: %.2lf secs\n", proc_gettime() - global_t);
    printf("scheduler exits\n");
    return 0;
}

void fcfs() {
    proc_t *proc;
    int pid;
    int status;

    // To track running processes
    proc_t *running_procs[MAX_LINE_LENGTH];
    int running_count = 0;

    memset(running_procs, 0, sizeof(running_procs)); // Initialize array

    while (!proc_queue_empty(&global_q) || running_count > 0) {

          // Check for completed processes
        for (int i = 0; i < running_count; i++) {
            proc = running_procs[i];
            if (proc->status == PROC_RUNNING) {
                pid = waitpid(proc->pid, &status, WNOHANG); // Non-blocking wait
                if (pid > 0) {
                    proc->status = PROC_EXITED;
                    proc->t_end = proc_gettime();
                    available_processors += proc->processors_required;

                    printf("PID %d - CMD: %s\n", pid, proc->name);
                    printf("\tElapsed time = %.2lf secs\n", proc->t_end - proc->t_submission);
                    printf("\tExecution time = %.2lf secs\n", proc->t_end - proc->t_start);
                    printf("\tWorkload time = %.2lf secs\n", proc->t_end - global_t);

                    // Remove the completed process from the running list
                    running_procs[i] = running_procs[--running_count];
                    i--; // Adjust index for the shifted array
                }
            }
        }

        // Allow some idle time to avoid busy-waiting
        usleep(1000);
        // Check if new processes can be started
        while (available_processors > 0 && !proc_queue_empty(&global_q)) {
            proc = proc_rq_dequeue();

            if (proc->status == PROC_NEW && proc->processors_required <= available_processors) {
                available_processors -= proc->processors_required;
                proc->t_start = proc_gettime();
                pid = fork();

                if (pid == -1) {
                    err_exit("fork failed!");
                }
                if (pid == 0) {
                    printf("executing %s\n", proc->name);
                    execl(proc->name, proc->name, NULL);
                    exit(0); // Ensure the child process exits after execution
                } else {
                    proc->pid = pid;
                    proc->status = PROC_RUNNING;
                    running_procs[running_count++] = proc;
                }
            } else {
                if (proc->processors_required <= available_processors){
                
                proc_to_rq_end(proc); // Requeue if not enough processors available
                }
                else {
                proc_to_rq_end(proc);
                break;  
                }
            }
        }

      
    }
}