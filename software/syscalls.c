#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <stddef.h>

int _link(const char *oldpath, const char *newpath) {
    (void)oldpath; (void)newpath; errno = ENOSYS;
    __asm volatile("bkpt #0");
    return -1;
}
int _unlink(const char *pathname) {
    (void)pathname;
    errno = ENOENT;
    __asm volatile("bkpt #0");
    return -1;
}

