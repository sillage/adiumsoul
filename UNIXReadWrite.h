/*
 * UNIXReadWrite.h
 *
 * $Header$
 *
 * Copyright 2004 Massachusetts Institute of Technology.
 * All Rights Reserved.
 *
 * Export of this software from the United States of America may
 * require a specific license from the United States Government.
 * It is the responsibility of any person or organization contemplating
 * export to obtain such a license before exporting.
 * 
 * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
 * distribute this software and its documentation for any purpose and
 * without fee is hereby granted, provided that the above copyright
 * notice appear in all copies and that both that copyright notice and
 * this permission notice appear in supporting documentation, and that
 * the name of M.I.T. not be used in advertising or publicity pertaining
 * to distribution of the software without specific, written prior
 * permission.  Furthermore if you modify this software you must label
 * your software as modified software and not distribute it in such a
 * fashion that it might be confused with the original M.I.T. software.
 * M.I.T. makes no representations about the suitability of
 * this software for any purpose.  It is provided "as is" without express
 * or implied warranty.
 */
/*
 * Modified by Thibault Martin-Lagardette for AdiumSoul
 * Changed the following:
 * - Modified headers and commented error handling, to avoid using Internal APIs
 */

#include <sys/types.h>

int ReadBuffer (int inDescriptor, size_t inBufferLength, char *ioBuffer);
int WriteBuffer (int inDescriptor, const char *inBuffer, size_t inBufferLength);

int ReadDynamicLengthBuffer (int inDescriptor, char **outData, size_t *outLength);
int WriteDynamicLengthBuffer (int inDescriptor, const char *inData, size_t inLength);
