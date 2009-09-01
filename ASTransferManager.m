//
//  ASTransferManager.m
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "ASTransferManager.h"
#import "ASIncomingTransfer.h"
#import "ASOutgoingTransfer.h"
#import "ASAccount.h"


@interface ASTransferManager (Private)
- (void)createThreadForTransfer:(ESFileTransfer *)fileTransfer andPerformSelectorOnTarget:(id)aTarget withObject:(id)anArgument;
@end

@implementation ASTransferManager

- (id)initWithAccount:(ASAccount *)inAccount
{
    if (self = [super init])
    {
        account = [inAccount retain];
        dataLock = [[NSLock alloc] init];
        transfers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [account release];
    [dataLock release];
    [transfers release];
    [super dealloc];
}

- (void)prepareOutgoingTransfer:(ESFileTransfer *)fileTransfer
{
    [self createThreadForTransfer:fileTransfer
       andPerformSelectorOnTarget:[ASOutgoingTransfer class]
                       withObject:nil];
}

- (void)prepareIncomingTransfer:(ESFileTransfer *)fileTransfer fromAddress:(NSString *)ipAddress andPort:(NSString *)port
{
    [self createThreadForTransfer:fileTransfer
       andPerformSelectorOnTarget:[ASIncomingTransfer class]
                       withObject:[NSDictionary dictionaryWithObjectsAndKeys:ipAddress, @"ipAddress", port, @"port"]];
}

- (void)setThreadedObject:(id)threadedObject forTransfer:(ESFileTransfer *)fileTransfer
{
    [dataLock lock];
    [transfers setObject:(id<ASTransferProtocol>)threadedObject
                  forKey:@"threadedObject"];
    [dataLock unlock];
    [threadedObject setProtocolForProxy:@protocol(ASTransferProtocol)];
}

@end

@implementation ASTransferManager (Private)

- (void)createThreadForTransfer:(ESFileTransfer *)fileTransfer andPerformSelectorOnTarget:(id)aTarget withObject:(id)anArgument
{
    NSPort*         port1;
    NSPort*         port2;
    NSConnection*   connection;

    port1 = [NSPort port];
    port2 = [NSPort port];
    connection = [[NSConnection alloc] initWithReceivePort:port1 sendPort:port2];
    [connection setRootObject:self];
    [transfers setObject:[NSMutableDictionary dictionaryWithObject:connection forKey:@"connection"]
                  forKey:fileTransfer];
    [NSThread detachNewThreadSelector:@selector(createTransferWithData:)
                             toTarget:aTarget
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       port1, @"port1",
                                       port2, @"port2",
                                       fileTransfer, @"fileTransfer",
                                       anArgument, @"arguments",
                                       nil]];
}

@end
