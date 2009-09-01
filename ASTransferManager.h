//
//  ASTransferManager.h
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/ESFileTransfer.h>


@class ASAccount;

@protocol ASTransferProtocol
+ (void)createTransferWithData:(NSDictionary *)tData;
- (void)cancel;
@end

@interface ASTransferManager : NSObject
{
    NSLock*                 dataLock;
    NSMutableDictionary*    transfers;
    ASAccount*     account;
}

- (id)initWithAccount:(ASAccount *)inAccount;
- (void)prepareOutgoingTransfer:(ESFileTransfer *)fileTransfer;
- (void)prepareIncomingTransfer:(ESFileTransfer *)fileTransfer fromAddress:(NSString *)ipAddress andPort:(NSString *)port;
- (void)setThreadedObject:(id)threadedObject forTransfer:(ESFileTransfer *)fileTransfer;

@end
