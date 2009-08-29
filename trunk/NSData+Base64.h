//
//  NSData+Base64.h
//  AdiumSoul
//
//  Created by Naixn on 25/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <openssl/bio.h>
#include <openssl/evp.h>

@interface NSData (Base64)

- (NSString *) encodeBase64;
- (NSString *) encodeBase64WithNewlines: (BOOL) encodeWithNewlines;

@end
