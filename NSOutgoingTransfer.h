//
//  NSOutgoingTransfer.h
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/ESFileTransfer.h>
#import "NSTransferManager.h"


@interface NSOutgoingTransfer : NSObject <NSTransferProtocol>
{
    NSTransferManager*  transferManagerProxy;
    ESFileTransfer*     fileTransfer;
    NSSocketPort*       serverSock;
    NSFileHandle*       socketHandle;
}

+ (void)createTransferWithData:(NSDictionary *)tData;
+ (void)cleanupThread:(NSNotification *)notification;
- (id)initTransfer:(ESFileTransfer *)inFileTransfer withTransferManager:(NSTransferManager *)inTransferManager;
- (void)connectionAccepted:(NSNotification *)notification;
- (void)cancel;

@end
