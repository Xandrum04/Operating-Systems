#include <stdio.h>
#include "ipc_utils.h"

int main(int argc, char *argv[]) {
    // Έλεγχος ορθότητας ορίων εισόδου
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <semaphore_name>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *semaphore_name = argv[1];

    // Άνοιγμα σημαφόρου που διαχειρίζεται τις θέσεις στη λέμβο
    HANDLE semaphore = OpenSemaphoreA(SEMAPHORE_ALL_ACCESS, FALSE, semaphore_name);
    if (semaphore == NULL) {
        fprintf(stderr, "Error: Unable to open semaphore. Error code: %lu\n", GetLastError());
        return EXIT_FAILURE;
    }

    printf("Passenger: Attempting to board the boat...\n");

    // Αναμονή μέχρι να υπάρχει διαθέσιμη θέση στη λέμβο
    wait_semaphore(semaphore);

    printf("Passenger: Successfully boarded!\n");

    // Προσομοίωση παραμονής στη λέμβο (π.χ. μετακίνηση στη στεριά)
    Sleep(2000);

    printf("Passenger: Disembarking and freeing up a seat.\n");

    // Απελευθέρωση μιας θέσης στη λέμβο
    release_semaphore(semaphore);

    // Κλείσιμο του σημαφόρου
    CloseHandle(semaphore);

    return EXIT_SUCCESS;
}
