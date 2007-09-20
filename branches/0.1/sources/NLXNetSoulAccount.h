//
//  NLXNetSoulAccount.h
//  AdiumSoul
//
//  Created by Carbonimax on 10/04/07.
//  Copyright 2007 Neelyx. All rights reserved.
//

#import <Adium/AIAccount.h>


@interface NLXNetSoulAccount : AIAccount
{
}

- (void)initAccount;
- (void)dealloc;
- (BOOL)disconnectOnFastUserSwitch;
- (BOOL)connectivityBasedOnNetworkReachability;
- (NSData *)userIconData;
- (BOOL)sendTypingObject:(AIContentTyping *)inTypingObject;
- (BOOL)openChat:(AIChat *)chat;
- (BOOL)closeChat:(AIChat *)inChat;
- (BOOL)availableForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact;
- (void)connect;
- (void)disconnect;
- (void)setStatusState:(AIStatus *)statusState usingStatusMessage:(NSAttributedString *)statusMessage;
- (BOOL)sendMessageObject:(AIContentMessage *)inContentMessage;
- (NSSet *)supportedPropertyKeys;
- (BOOL)contactListEditable;
- (void)addContacts:(NSArray *)objects toGroup:(AIListGroup *)group;
- (void)removeContacts:(NSArray *)objects;

@end
