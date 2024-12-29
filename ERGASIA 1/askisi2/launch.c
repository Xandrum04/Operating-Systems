/* Spiridon Mantadakis, 1100613 */
/* Apostolos Zekyrias, 1100554 */
/* Alexandros Georgios Chalampakis, 1100754 */
/* Panagiwths Papanikolaou, 1104804 */

#include <winbase.h>
#include <stdio.h>
#include <stdlib.h>
#include "ipc_utils.h"

#define MAX_PASSENGERS 500
#define MAX_BOATS 500

// Updated function to create passenger processes and store handles
void create_passenger_process(const char *semaphore_name, PROCESS_INFORMATION *pi_array, int index) {
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;

    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    char command[256];
    snprintf(command, sizeof(command), "passenger.exe %s", semaphore_name);

    if (!CreateProcessA(NULL, command, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
        fprintf(stderr, "Error: Failed to create passenger process. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }

    // Store the process information for later use
    pi_array[index] = pi;
}

int main() {
    int num_passengers, num_boats, seats_per_boat;

    // Read input parameters
    printf("Enter number of passengers: ");
    scanf("%d", &num_passengers);
    printf("Enter number of boats: ");
    scanf("%d", &num_boats);
    printf("Enter seats per boat: ");
    scanf("%d", &seats_per_boat);

    if (num_passengers <= 0 || num_boats <= 0 || seats_per_boat <= 0) {
        fprintf(stderr, "Error: Invalid input values. Please provide positive integers.\n");
        return EXIT_FAILURE;
    }

    if (num_passengers > MAX_PASSENGERS) {
        fprintf(stderr, "Error: Too many passengers.\n");
        return EXIT_FAILURE;
    }

    // Create a semaphore to manage boat seats
    HANDLE semaphore = create_semaphore("BoatSemaphore", seats_per_boat, seats_per_boat);

    // Array to store process information for all passengers
    PROCESS_INFORMATION pi_array[MAX_PASSENGERS];

    // Create passenger processes
    for (int i = 0; i < num_passengers; i++) {
        create_passenger_process("BoatSemaphore", pi_array, i);
    }

    printf("All passengers are attempting to board. Please wait...\n");

    // Wait for all passenger processes to complete
    HANDLE process_handles[MAX_PASSENGERS];
    for (int i = 0; i < num_passengers; i++) {
        process_handles[i] = pi_array[i].hProcess;
    }
    WaitForMultipleObjects(num_passengers, process_handles, TRUE, INFINITE);

    // Clean up process handles
    for (int i = 0; i < num_passengers; i++) {
        CloseHandle(pi_array[i].hProcess);
        CloseHandle(pi_array[i].hThread);
    }

    // Clean up the semaphore
    CloseHandle(semaphore);

    printf("Simulation complete. All passengers have been processed.\n");
    return EXIT_SUCCESS;
}

