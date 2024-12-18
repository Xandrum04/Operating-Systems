#include <winbase.h>
#include <stdio.h>
#include <stdlib.h>
#include "ipc_utils.h"

#define MAX_PASSENGERS 100
#define MAX_BOATS 10

// Συνάρτηση για τη δημιουργία διεργασίας επιβάτη
void create_passenger_process(const char *semaphore_name) {
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;

    // Αρχικοποίηση των δομών STARTUPINFOA και PROCESS_INFORMATION
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    // Δημιουργία εντολής για την εκτέλεση του passenger.exe
    char command[256];
    snprintf(command, sizeof(command), "passenger.exe %s", semaphore_name);

    // Δημιουργία της διεργασίας επιβάτη χωρίς νέο terminal
    if (!CreateProcessA(NULL, command, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
        fprintf(stderr, "Error: Failed to create passenger process. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }

    // Κλείσιμο των handles της διεργασίας και του thread
    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);
}

int main() {
    int num_passengers, num_boats, seats_per_boat;

    // Λήψη εισόδου από τον χρήστη για τις παραμέτρους του προγράμματος
    printf("Enter number of passengers: ");
    scanf("%d", &num_passengers);
    printf("Enter number of boats: ");
    scanf("%d", &num_boats);
    printf("Enter seats per boat: ");
    scanf("%d", &seats_per_boat);

    // Έλεγχος εγκυρότητας των εισόδων
    if (num_passengers <= 0 || num_boats <= 0 || seats_per_boat <= 0) {
        fprintf(stderr, "Error: Invalid input values. Please provide positive integers.\n");
        return EXIT_FAILURE;
    }

    // Δημιουργία σημαφόρου για τη διαχείριση των θέσεων στις λέμβους
    HANDLE semaphore = create_semaphore("BoatSemaphore", seats_per_boat, seats_per_boat);

    // Δημιουργία διεργασιών για τους επιβάτες
    for (int i = 0; i < num_passengers; i++) {
        create_passenger_process("BoatSemaphore");
    }

    printf("All passengers are attempting to board. Please wait...\n");

    // Προσομοίωση αναμονής για την ολοκλήρωση των διεργασιών
    Sleep(5000);

    // Καθαρισμός και κλείσιμο του σημαφόρου
    CloseHandle(semaphore);

    printf("Simulation complete. All passengers have been processed.\n");
    return EXIT_SUCCESS;
}

