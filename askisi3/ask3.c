#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#define MEMORY_CAPACITY 512  // Size of memory in KB
#define TIME_SLICE 3         // Quantum time slice (3 milliseconds)
#define MAX_PROCESS_COUNT 5  // Maximum number of processes

// Structure to represent a process
typedef struct {
    int pid;                // Process ID
    int arrival_time;       // When the process arrives
    int duration;     // Total time the process needs to run
    int remaining_duration; // Remaining execution time
    int memory_needed;    // Memory needed for the process (in KB)
    bool in_memory;      // Flag to check if the process is in memory
} Process;

// Structure for memory block
typedef struct {
    int start;             // Start address of memory block
    int size;              // Size of the memory block
    bool is_free;          // Whether the block is free or occupied
    int pid;               // Process ID occupying the block
} MemoryBlock;

MemoryBlock memory[MEMORY_CAPACITY]; // Memory array
Process processes[MAX_PROCESS_COUNT]; // Processes array
int process_count = 0;                // Total number of processes

// Initialize memory by creating a single large free memory block
void initialize_memory() {
    memory[0].start = 0;
    memory[0].size = MEMORY_CAPACITY;
    memory[0].is_free = true;
    memory[0].pid = -1; // No process occupies it initially
    for (int i = 1; i < MEMORY_CAPACITY; i++) {
        memory[i].start = -1;
        memory[i].size = 0;
        memory[i].is_free = false;
        memory[i].pid = -1;
    }
}

// Try to allocate memory to a process
int allocate_memory(int pid, int memory_needed) {
    for (int i = 0; i < MEMORY_CAPACITY; i++) {
        // Find a free block with sufficient space
        if (memory[i].is_free && memory[i].size >= memory_needed) {
            // If the block is larger than required, split it
            if (memory[i].size > memory_needed) {
                for (int j = MEMORY_CAPACITY - 1; j > i; j--) {
                    memory[j] = memory[j - 1];
                }
                memory[i + 1].start = memory[i].start + memory_needed;
                memory[i + 1].size = memory[i].size - memory_needed;
                memory[i + 1].is_free = true;
                memory[i + 1].pid = -1;
            }
            memory[i].size = memory_needed;
            memory[i].is_free = false;
            memory[i].pid = pid;
            return 1; // Memory successfully allocated
        }
    }
    return 0; // Memory allocation failed
}

// Deallocate memory of a process when it finishes
void deallocate_memory(int pid) {
    for (int i = 0; i < MEMORY_CAPACITY; i++) {
        if (memory[i].pid == pid) {
            memory[i].is_free = true;
            memory[i].pid = -1;
        }
    }
}

// Display the current memory status
void print_memory_status() {
    printf("\nMemory Status:\n");
    for (int i = 0; i < MEMORY_CAPACITY; i++) {
        if (memory[i].start != -1) {
            printf("Block %d: Start=%d, Size=%d, Free=%s, PID=%d\n",
                   i, memory[i].start, memory[i].size,
                   memory[i].is_free ? "Yes" : "No",
                   memory[i].pid);
        }
    }
    printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n");
}

// Simulate the round robin scheduling and memory management
void simulate_round_robin() {
    int time = 0;
    bool all_processes_done = false;

    while (!all_processes_done) {
        all_processes_done = true;
        for (int i = 0; i < process_count; i++) {
            // Check if the process has arrived and has remaining execution time
            if (processes[i].arrival_time <= time && processes[i].remaining_duration > 0) {
                all_processes_done = false;

                // If the process is not in memory, try loading it
                if (!processes[i].in_memory) {
                    if (allocate_memory(processes[i].pid, processes[i].memory_needed)) {
                        processes[i].in_memory = true;
                        printf("Time %d: Process %d loaded into memory.\n", time, processes[i].pid);
                        print_memory_status();
                    } else {
                        printf("Time %d: Process %d waiting for memory.\n", time, processes[i].pid);
                        continue; // Skip this iteration if no memory is available
                    }
                }

                // Run the process for the time quantum
                int slice_duration = (processes[i].remaining_duration < TIME_SLICE) ? processes[i].remaining_duration : TIME_SLICE;
                printf("Time %d: Process %d is running for %d msec.\n", time, processes[i].pid, slice_duration);

                // Update the remaining time and overall time
                time += slice_duration;
                processes[i].remaining_duration -= slice_duration;

                // If the process is finished, free its memory
                if (processes[i].remaining_duration == 0) {
                    printf("Time %d: Process %d completed.\n", time, processes[i].pid);
                    deallocate_memory(processes[i].pid);
                    processes[i].in_memory = false;
                    print_memory_status();
                }
            }
        }
    }
}

int main() {
    initialize_memory();

    // Get the number of processes
    printf("Enter the number of processes (max %d): ", MAX_PROCESS_COUNT);
    scanf("%d", &process_count);

    // Get the details for each process
    for (int i = 0; i < process_count; i++) {
        processes[i].pid = i + 1;
        printf("\nEnter arrival time, total duration, and memory needed (in KB) for Process %d: ", processes[i].pid);
        scanf("%d %d %d", &processes[i].arrival_time, &processes[i].duration, &processes[i].memory_needed);
        processes[i].remaining_duration = processes[i].duration;
        processes[i].in_memory = false;
    }

    // Start the simulation
    simulate_round_robin();

    return 0;
}
