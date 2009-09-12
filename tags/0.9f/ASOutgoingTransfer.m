//
//  ASOutgoingTransfer.m
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "ASOutgoingTransfer.h"


static NSAutoreleasePool*   gl_pool = nil;

@implementation ASOutgoingTransfer

+ (void)createTransferWithData:(NSDictionary *)tData
{
    NSConnection*       connectionToTransferManager;
    ASOutgoingTransfer* transfer;

    gl_pool = [[NSAutoreleasePool alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanupThread:)
                                                 name:NSThreadWillExitNotification
                                               object:[NSThread currentThread]];
    connectionToTransferManager = [NSConnection connectionWithReceivePort:[tData objectForKey:@"port2"] sendPort:[tData objectForKey:@"port1"]];
    transfer = [[self alloc] initTransfer:[tData objectForKey:@"fileTransfer"]
                      withTransferManager:((ASTransferManager *)[connectionToTransferManager rootProxy])];
    [transfer release];
}

+ (void)cleanupThread:(NSNotification *)notification
{
    [gl_pool release];
}

- (id)initTransfer:(ESFileTransfer *)inFileTransfer withTransferManager:(ASTransferManager *)inTransferManager
{
    if (self = [super init])
    {
        fileTransfer = [inFileTransfer retain];
        transferManagerProxy = [inTransferManager retain];
        [transferManagerProxy setThreadedObject:self forTransfer:inFileTransfer];
        serverSock = [[NSSocketPort alloc] initWithTCPPort:4243];
        socketHandle = [[NSFileHandle alloc] initWithFileDescriptor:[serverSock socket] closeOnDealloc:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectionAccepted:)
                                                     name:NSFileHandleConnectionAcceptedNotification
                                                   object:socketHandle];
        [socketHandle acceptConnectionInBackgroundAndNotify];
    }
    return self;
}

- (void)dealloc
{
    [transferManagerProxy release];
    [fileTransfer release];
    [super dealloc];
}

- (void)connectionAccepted:(NSNotification *)notification
{
    
}

- (void)cancel
{
    
}

@end
