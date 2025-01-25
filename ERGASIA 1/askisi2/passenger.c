/* Spiridon Mantadakis, 1100613 */
/* Apostolos Zekyrias, 1100554 */
/* Alexandros Georgios Chalampakis, 1100754 */
/* Panagiwths Papanikolaou, 1104804 */

#include <stdio.h>
#include "ipc_utils.h"

int main(int argc, char *argv[]) {

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <semaphore_name>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *semaphore_name = argv[1];


    HANDLE semaphore = OpenSemaphoreA(SEMAPHORE_ALL_ACCESS, FALSE, semaphore_name);
    if (semaphore == NULL) {
        fprintf(stderr, "Error: Unable to open semaphore. Error code: %lu\n", GetLastError());
        return EXIT_FAILURE;
    }

    printf("Passenger: Attempting to board the boat...\n");


    wait_semaphore(semaphore);

    printf("Passenger: Successfully boarded!\n");


    Sleep(2000);

    printf("Passenger: Disembarking and freeing up a seat.\n");


    release_semaphore(semaphore);


    CloseHandle(semaphore);

    return EXIT_SUCCESS;
}
