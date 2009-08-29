//
//  NSIncomingTransfer.h
//  AdiumSoul
//
//  Created by Naixn on 22/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/ESFileTransfer.h>
#import "NSTransferManager.h"


@interface NSIncomingTransfer : NSObject <NSTransferProtocol>
{
    NSTransferManager*  transferManagerProxy;
    ESFileTransfer*     fileTransfer;
}

+ (void)createTransferWithData:(NSDictionary *)tData;
+ (void)cleanupThread:(NSNotification *)notification;
- (void)cancel;

@end
