//
//  NLXNetSoulAccount.m
//  AdiumSoul
//
//  Created by Carbonimax on 10/04/07.
//  Copyright 2007 Neelyx. All rights reserved.
//

#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIStatusControllerProtocol.h>
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AIChatControllerProtocol.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/AIInterfaceControllerProtocol.h>
#import <Adium/AIAccountControllerProtocol.h>
#import <Adium/AIChat.h>
#import <Adium/AIContentMessage.h>
#import <Adium/AIContentTyping.h>
#import <Adium/AIHTMLDecoder.h>
#import <Adium/AIListContact.h>
#import <Adium/AIStatus.h>
#import <Adium/NDRunLoopMessenger.h>
#import <AIUtilities/AIMutableOwnerArray.h>
#import <AIUtilities/AIObjectAdditions.h>
#import <Adium/AIAccount.h>
#import <Adium/AIPreferenceControllerProtocol.h>

#import "gssapi/gssapi_krb5.h"

#import "NLXAdiumSoul.h"
#import "NLXNetSoulAccount.h"
#import "NLXNetSoulAccountViewController.h"


@implementation NLXNetSoulAccount

- (void)initAccount
{
    [super initAccount];

//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAcceptOrDenyInvitation:) name:@"KWXfireDenyAcceptInvitation" object:nil];
}

- (void)dealloc
{
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (BOOL)disconnectOnFastUserSwitch
{
  return YES;
}

- (BOOL)connectivityBasedOnNetworkReachability
{
  return YES;
}

 // NetSoul doens't provide user icons
- (NSData *)userIconData
{
  return nil;
}

// Je ne sais pas ce que c'est, mais je ne pense pas que ça existe dans netsoul
- (BOOL)sendTypingObject:(AIContentTyping *)inTypingObject
{
  return NO;
}

- (BOOL)availableForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact
{
  return NO;
}

// initiate a new chat
- (BOOL)openChat:(AIChat *)chat
{
  return YES;
}

// close a chat instance
- (BOOL)closeChat:(AIChat *)inChat
{
  return YES;
}

#pragma mark -
#pragma mark Adium Methods

// called when we need to connect
- (void)connect
{
	[super connect];
	// recuperation du token kerberos
	// connection socket
	// authentification netsoul
}

// called when we need to disconnect
- (void)disconnect
{
	[super disconnect];
}

// respond to changes in status messages
- (void)setStatusState:(AIStatus *)statusState usingStatusMessage:(NSAttributedString *)statusMessage
{
	// we were told to go offline...
	if ([statusState statusType] == AIOfflineStatusType)
	{
		[self disconnect];
		return;
	}

	// we need to be online for any other status, so check that first
	if ([self online] == NO)
	{
		[self connect];
		return;
	}
	
	// hande Away and Available statuses
	switch ([statusState statusType])
	{
//		case AIAvailableStatusType:
//			[self setStatusMessage:[statusMessage string]];
//			break;
//		case AIAwayStatusType:
//			// Adium sends nil statusMessage for Away..
//			[self setStatusMessage:([statusMessage string] ? [statusMessage string] : @"")];
//			break;
		default:
			break;
	}
}

// we are sending a message to another Xfire user
- (BOOL)sendMessageObject:(AIContentMessage *)inContentMessage
{
//	[_xfire sendMessage:[inContentMessage messageString]
//					 to:[[_xfire buddyList] entryWithUsername:[[inContentMessage destination] UID]]];
	return NO;
}

// status keys this account supports
- (NSSet *)supportedPropertyKeys
{
	static NSMutableSet *supportedPropertyKeys = nil;
	
	if (!supportedPropertyKeys) {
		supportedPropertyKeys = [[NSMutableSet alloc] initWithObjects:
			@"Online",
			@"Offline",
			@"Away",
			nil];
		
		[supportedPropertyKeys unionSet:[super supportedPropertyKeys]];
	}
	
	return supportedPropertyKeys;
}

- (BOOL)contactListEditable
{
	return YES;
}

- (void)addContacts:(NSArray *)objects toGroup:(AIListGroup *)group
{

}

- (void)removeContacts:(NSArray *)objects
{

}


#pragma mark -
#pragma mark Xfire Delegate

// delegate method called from our Xfire object when a login attempt has succeeded or failed
//- (void)xfire:(Xfire *)xfire loginStatus:(BOOL)success
//{
//	if (success)
//	{
//		[self didConnect];
//		
//		[_connectDate release];
//		_connectDate = [[NSDate date] retain];
//	}
//	else
//	{
//		[self disconnect];
//		
//		[[adium interfaceController] handleErrorMessage:@"Xfire Error"
//										withDescription:@"Failed to log in with supplied username and password. Please try again."];
//	}
//}

// delegate method called from our Xfire object when we've received a message from another Xfire user
//- (void)xfire:(Xfire *)xfire receivedMessage:(NSString *)message fromBuddy:(XfireBuddyListEntry *)entry
//{
//	// get the contact that sent the message
//	AIListContact *source = [self contactWithUID:[entry username]];
//	// create the messsage content
//	AIContentMessage *msg = [[[AIContentMessage alloc] initWithChat:[[adium chatController] chatWithContact:source]
//															 source:source
//														destination:nil
//															   date:[NSDate date]
//															message:[[[NSAttributedString alloc] initWithString:message] autorelease]] autorelease];
//	// display the message in the chat window
//	[[adium contentController] displayContentObject:msg immediately:YES];
//}

//- (void)xfire:(Xfire *)xfire receivedInvitationMessage:(NSString *)message fromUser:(NSString *)username withNickname:(NSString *)nickname
//{
//	KWXfireInvitationController *inv = [[KWXfireInvitationController alloc] init];
//
//	[inv showWindowForUsername:username message:message];
//	
//	[_invites addObject:inv];
//	[inv release];
//}

//- (void)userDidAcceptOrDenyInvitation:(NSNotification *)n
//{
//	NSDictionary *d = (NSDictionary *)[n object];
//	NSString *username = [d objectForKey:@"username"];
//	BOOL accept = [[d objectForKey:@"accept"] boolValue];
//	if (accept)
//		[_xfire acceptInvitationFromUser:username];
//	else
//		[_xfire denyInvitationFromUser:username];
//}

// delegate method called from our Xfire object when our Xfire buddy list has been updated
// (i.e. status messages, on/offline buddies, etc
//- (void)xfireDidUpdateBuddyList:(Xfire *)xfire
//{
//	[self updateBuddyList];
//}

// delegate method sent when this account was logged on from another location
//- (void)xfireOtherUseLoggedOn:(Xfire *)xfire
//{
//	[[adium interfaceController] handleErrorMessage:@"Xfire Error"
//									withDescription:@"Another user has logged on with your username."];
//	[self disconnect];
//}

//- (void)xfire:(Xfire *)xfire setGameStatus:(XfireGameInfo *)gameInfo
//{
	
//}

@end
