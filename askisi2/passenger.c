// passenger.c

#include <stdio.h>
#include "ipc_utils.h"

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <semaphore_name>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *semaphore_name = argv[1];

    // Άνοιγμα σημαφόρου
    HANDLE semaphore = OpenSemaphoreA(SEMAPHORE_ALL_ACCESS, FALSE, semaphore_name);
    if (semaphore == NULL) {
        fprintf(stderr, "Failed to open semaphore: %lu\n", GetLastError());
        return EXIT_FAILURE;
    }

    printf("Passenger attempting to board...\n");

    // Αναμονή για θέση στη λέμβο
    wait_semaphore(semaphore);

    printf("Passenger boarded successfully!\n");

    // Προσομοίωση χρόνου παραμονής στη λέμβο
    Sleep(2000);

    printf("Passenger disembarking and freeing up a spot.\n");

    // Απελευθέρωση θέσης
    release_semaphore(semaphore);

    // Κλείσιμο σημαφόρου
    CloseHandle(semaphore);

    return EXIT_SUCCESS;
}
