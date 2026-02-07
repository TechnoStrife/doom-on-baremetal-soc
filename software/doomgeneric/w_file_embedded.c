// Embedded WAD backend
// Exposes a linked-in doom1.wad via the wad_file_class API.

#include <string.h>
#include <stdio.h>

#include "w_file.h"
#include "z_zone.h"

extern const unsigned char _binary_doom1_wad_start[];
extern const unsigned char _binary_doom1_wad_end[];

typedef struct
{
    wad_file_t wad;
} embedded_wad_file_t;

wad_file_class_t embedded_wad_file;

static wad_file_t *W_Embedded_OpenFile(char *path)
{
    embedded_wad_file_t *result;

    if (path == NULL) return NULL;

    /* Only recognise requests for doom1.wad (any path containing that name) */
    if (strstr(path, "doom1.wad") == NULL)
    {
        return NULL;
    }

    result = Z_Malloc(sizeof(embedded_wad_file_t), PU_STATIC, 0);

    result->wad.file_class = &embedded_wad_file;
    result->wad.mapped = (byte *)_binary_doom1_wad_start;
    result->wad.length = (unsigned int)(_binary_doom1_wad_end - _binary_doom1_wad_start);

    return &result->wad;
}

static void W_Embedded_CloseFile(wad_file_t *wad)
{
    embedded_wad_file_t *e = (embedded_wad_file_t *) wad;
    Z_Free(e);
}

static size_t W_Embedded_Read(wad_file_t *wad, unsigned int offset,
                             void *buffer, size_t buffer_len)
{
    const unsigned char *base = (const unsigned char *) wad->mapped;
    size_t avail;

    if (offset >= wad->length) return 0;

    avail = wad->length - offset;
    if (buffer_len > avail) buffer_len = avail;

    memcpy(buffer, base + offset, buffer_len);

    return buffer_len;
}

wad_file_class_t embedded_wad_file =
{
    W_Embedded_OpenFile,
    W_Embedded_CloseFile,
    W_Embedded_Read,
};
