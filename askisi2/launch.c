// launch.c
#include <winbase.h>
#include <stdio.h>
#include <stdlib.h>
#include "ipc_utils.h"

#define MAX_PASSENGERS 100
#define MAX_BOATS 10

void create_passenger_process(const char *semaphore_name) {
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    char command[256];
    snprintf(command, sizeof(command), "passenger.exe %s", semaphore_name);

    // Δημιουργία διεργασίας χωρίς νέο terminal
    if (!CreateProcessA(NULL, command, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
        fprintf(stderr, "Failed to create process: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }

    // Κλείσιμο των handles για τη διεργασία και το thread
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
}

int main() {
    int num_passengers, num_boats, seats_per_boat;

    printf("Enter number of passengers: ");
    scanf("%d", &num_passengers);
    printf("Enter number of boats: ");
    scanf("%d", &num_boats);
    printf("Enter seats per boat: ");
    scanf("%d", &seats_per_boat);

    if (num_passengers <= 0 || num_boats <= 0 || seats_per_boat <= 0) {
        fprintf(stderr, "Invalid input values.\n");
        return EXIT_FAILURE;
    }

    HANDLE semaphore = create_semaphore("BoatSemaphore", seats_per_boat, seats_per_boat);

    for (int i = 0; i < num_passengers; i++) {
        create_passenger_process("BoatSemaphore");
    }

    printf("All passengers are attempting to board.\n");

    // Καθαρισμός και αναμονή
    Sleep(5000);
    CloseHandle(semaphore);

    return EXIT_SUCCESS;
}
