//
//  ASIncomingTransfer.m
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "ASIncomingTransfer.h"


static NSAutoreleasePool*   gl_pool = nil;

@implementation ASIncomingTransfer

+ (void)createTransferWithData:(NSDictionary *)tData
{
    gl_pool = [[NSAutoreleasePool alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanupThread:)
                                                 name:NSThreadWillExitNotification
                                               object:[NSThread currentThread]];
}

+ (void)cleanupThread:(NSNotification *)notification
{
    [gl_pool release];
}

- (void)cancel
{
    
}

@end
