/* Spiridon Mantadakis, 1100613 */
/* Apostolos Zekyrias, 1100554 */
/* Alexandros Georgios Chalampakis, 1100754 */
/* Panagiwths Papanikolaou, 1104804 */

#ifndef IPC_UTILS_H
#define IPC_UTILS_H

#include <winbase.h>
#include <stdio.h>
#include <stdlib.h>

// ΔΗΜΙΟΥΡΓΙΑ ΣΗΜΑΦΟΡΟΥ
HANDLE create_semaphore(const char *name, LONG initialCount, LONG maxCount) {
    HANDLE semaphore = CreateSemaphoreA(NULL, initialCount, maxCount, name);
    if (semaphore == NULL) {
        fprintf(stderr, "Error: ΑΔΥΝΑΜΙΑ ΔΗΜΙΟΥΡΓΙΑΣ ΣΗΜΑΦΟΡΟΥ. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }
    return semaphore;
}

// ΣΥΝΑΡΤΗΣΗ ΑΝΑΜΟΝΗΣ ΜΙΑΣ ΔΙΕΡΓΑΣΙΑΣ ΣΕ ΣΗΜΑΦΟΡΟ
void wait_semaphore(HANDLE semaphore) {
    DWORD waitResult = WaitForSingleObject(semaphore, INFINITE);
    if (waitResult != WAIT_OBJECT_0) {
        fprintf(stderr, "Error: ΑΔΥΝΑΜΙΑ ΝΑ ΠΕΡΙΜΕΝΟΥΜΕ ΤΟ ΣΗΜΑΦΟΡΟ. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }
}

// ΣΥΝΑΡΤΗΣΗ ΓΙΑ ΑΠΕΛΕΥΘΕΡΩΣΗ ΘΕΣΗΣ
void release_semaphore(HANDLE semaphore) {
    if (!ReleaseSemaphore(semaphore, 1, NULL)) {
        fprintf(stderr, "Error: ΑΔΥΝΑΜΙΑ ΑΠΕΛΕΥΘΕΡΩΣΗΣ ΘΕΣΗΣ. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }
}

#endif
