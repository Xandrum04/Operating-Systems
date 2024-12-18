// ipc_utils.h
#ifndef IPC_UTILS_H
#define IPC_UTILS_H

#include <winbase.h>
#include <stdio.h>
#include <stdlib.h>

// Συνάρτηση για τη δημιουργία σημαφόρου
HANDLE create_semaphore(const char *name, LONG initialCount, LONG maxCount) {
    HANDLE semaphore = CreateSemaphoreA(NULL, initialCount, maxCount, name);
    if (semaphore == NULL) {
        fprintf(stderr, "Error: Unable to create semaphore. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }
    return semaphore;
}

// Συνάρτηση για να περιμένει μια διεργασία σε σημαφόρο
void wait_semaphore(HANDLE semaphore) {
    DWORD waitResult = WaitForSingleObject(semaphore, INFINITE);
    if (waitResult != WAIT_OBJECT_0) {
        fprintf(stderr, "Error: Failed to wait on semaphore. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }
}

// Συνάρτηση για να απελευθερώσει μια θέση στον σημαφόρο
void release_semaphore(HANDLE semaphore) {
    if (!ReleaseSemaphore(semaphore, 1, NULL)) {
        fprintf(stderr, "Error: Failed to release semaphore. Error code: %lu\n", GetLastError());
        exit(EXIT_FAILURE);
    }
}

#endif // IPC_UTILS_H
