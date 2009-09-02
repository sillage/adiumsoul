//
//  NSString+Base64.h
//  AdiumSoul
//
//  Created by Naixn on 25/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <openssl/bio.h>
#include <openssl/evp.h>

@interface NSString (Base64)

- (NSData *) decodeBase64;
- (NSData *) decodeBase64WithNewlines: (BOOL) encodedWithNewlines;

@end
