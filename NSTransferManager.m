//
//  NSTransferManager.m
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "NSTransferManager.h"
#import "NSIncomingTransfer.h"
#import "NSOutgoingTransfer.h"
#import "NSAdiumsoulAccount.h"


@interface NSTransferManager (Private)
- (void)createThreadForTransfer:(ESFileTransfer *)fileTransfer andPerformSelectorOnTarget:(id)aTarget withObject:(id)anArgument;
@end

@implementation NSTransferManager

- (id)initWithAccount:(NSAdiumsoulAccount *)inAccount
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
       andPerformSelectorOnTarget:[NSOutgoingTransfer class]
                       withObject:nil];
}

- (void)prepareIncomingTransfer:(ESFileTransfer *)fileTransfer fromAddress:(NSString *)ipAddress andPort:(NSString *)port
{
    [self createThreadForTransfer:fileTransfer
       andPerformSelectorOnTarget:[NSIncomingTransfer class]
                       withObject:[NSDictionary dictionaryWithObjectsAndKeys:ipAddress, @"ipAddress", port, @"port"]];
}

- (void)setThreadedObject:(id)threadedObject forTransfer:(ESFileTransfer *)fileTransfer
{
    [dataLock lock];
    [transfers setObject:(id<NSTransferProtocol>)threadedObject
                  forKey:@"threadedObject"];
    [dataLock unlock];
    [threadedObject setProtocolForProxy:@protocol(NSTransferProtocol)];
}

@end

@implementation NSTransferManager (Private)

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
