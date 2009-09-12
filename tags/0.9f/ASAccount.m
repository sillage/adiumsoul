//
//  ASAccount.m
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

/* Copied from Adium Source */
#import <Adium/AIAbstractAccount.h>
#import <Adium/AIListContact.h>
#import <Adium/AIContentMessage.h>
#import <Adium/AIContentNotification.h>
#import <Adium/AIService.h>
#import <Adium/AIChat.h> // Aïcha, Aïcha, t'en va pas, Aïcha, Aïcha, regarde-moi, Aïcha, Aïcha, réponds-moi
#import <Adium/ESFileTransfer.h>

#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AIContentControllerProtocol.h>
#import <Adium/AIAccountControllerProtocol.h>
#import <Adium/AIInterfaceControllerProtocol.h>
#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/AIChatControllerProtocol.h>
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AILoginControllerProtocol.h>

/* End of copy */

#import "ASAccount.h"
#import "ASContactList.h"

cnxSteps gl_steps[] =
{
    {NETSOUL_STEP_CONNECTING, @"Connecting to server..."},
    {NETSOUL_STEP_CONNECTION_ESTABLISHED, @"Connection established"},
    {NETSOUL_STEP_AUTH_AG_REQUEST, @"Requesting authentication agent"},
    {NETSOUL_STEP_AUTHENTICATION, @"Authentication"},
    {-1, nil}
};

@implementation ASAccount

/*!
 * @brief Init Account
 *
 * Init this account instance
 */
- (void)initAccount
{
    [super initAccount];

    AILog(@"[AdiumSoul] mainBundle path: %@", [[NSBundle bundleWithIdentifier:@"org.epimac.adiumsoul"] bundlePath]);
    adiumsoul = [[NSPAdiumsoul alloc] initWithAdiumAccount:self];
    netsoulContactList = [[ASContactList alloc] initWithAccount:self];
    tryingToConnect = NO;
    connected = NO;
    connectionTimer = nil;
    locationWindow = [[ASILocation alloc] initWithWindowNibName:@"ASILocation" withAccount:self];
    locationSet = NO;
}

- (void)dealloc
{
    [self stopTimer];
    [self disconnect];
    [adiumsoul release];
    [netsoulContactList release];
    [locationWindow release];
    [super dealloc];
}

#pragma mark Connection-related methods

/*!
 * @brief Connect
 *
 * Connect the account, transitioning it into an online state.
 */
- (void)connect
{
    NSNumber*   askLocationPref = [self preferenceForKey:NETSOUL_KEY_ASK_LOCATION group:GROUP_ACCOUNT_STATUS];

    connected = NO;
    tryingToConnect = YES;
    if ([askLocationPref intValue] == 1 && !locationSet)
    {
        [locationWindow show];
        return ;
    }
    AILog(@"[AdiumSoul] Trying to connect");
    [super connect];
//    AILog(@"[AdiumSoul] --> Before connectionProgressStep");
    [self connectionProgressStep:NETSOUL_STEP_CONNECTING];
    AILog(@"[AdiumSoul] <-- After connectionProgressStep");
    [adiumsoul connect];
}

- (void)connectionProgressStep:(int)step
{
//    AILog(@"[AdiumSoul] Entering connectionProgressStep");
    int         step_count = 5;
	NSString*   connectionProgressString = gl_steps[step].text;
    NSNumber*   connectionProgressPercent = [NSNumber numberWithFloat:((float)step / (float)(step_count - 1))];

//    AILog(@"[AdiumSoul] connectionProgressStep > declarations done, setting status objects with '%@' (%@) %@ (%@)", connectionProgressString, NSStringFromClass([connectionProgressString class]), connectionProgressPercent, NSStringFromClass([connectionProgressPercent class]));
	[self setValue:connectionProgressString forProperty:@"ConnectionProgressString" notify:NO];
//    AILog(@"[AdiumSoul] connectionProgressStep > Setting ConnectionProgressPercent");
	[self setValue:connectionProgressPercent forProperty:@"ConnectionProgressPercent" notify:NO];
    
//    AILog(@"[AdiumSoul] connectionProgressStep > setting status objects done, notifying");
	//Apply any changes
	[self notifyOfChangedPropertiesSilently:NO];
//    AILog(@"[AdiumSoul] connectionProgressStep > notified");
}

- (void)didConnect
{
    [super didConnect];
    tryingToConnect = NO;
    connected = YES;
    [netsoulContactList loadList];
    [adiumsoul watchUsers:[netsoulContactList contacts]];
    [adiumsoul whoUsers:[netsoulContactList contacts]];
}

- (void)didDisconnect
{
    AILog(@"[AdiumSoul] Did disconnect");
    tryingToConnect = NO;
    connected = NO;
    [super didDisconnect];
}

/*!
 * @brief Disconnect
 *
 * Disconnect the account, transitioning it into an offline state.
 */
- (void)disconnect
{
    locationSet = NO;
    [adiumsoul disconnect];
	[self notifyOfChangedPropertiesSilently:NO];
    [super disconnect];
}

//Properties -----------------------------------------------------------------------------------------------------------
#pragma mark Properties

/*!
 * @brief Disconnect on fast user switch
 *
 * It may be required for a service to disconnect when logged in users change.  If this is the case, subclass this
 * method to return YES and Adium will automatically disconnect and reconnect on FUS events.
 */
- (BOOL)disconnectOnFastUserSwitch
{
	return YES;
}

/*!
 * @brief Suppress typing notifications after send
 *
 * Some protocols require a 'Stopped typing' notification to be sent along with an instant message.  Other protocols
 * implicitly assume that typing has stopped with an incoming message and the extraneous typing notification may cause
 * strange behavior.  Return YES from this method to suppress the sending of a stopped typing notification along with
 * messages.
 */
- (BOOL)suppressTypingNotificationChangesAfterSend
{
    return NO;
}

//Status ---------------------------------------------------------------------------------------------------------------
#pragma mark Status

/*!
 * @brief Supported status keys
 *
 * Returns an array of status keys supported by this account.  This account will not be informed of changes to keys
 * it does not support.  Available keys are:
 *   @"Display Name", @"Online", @"Offline", @"IdleSince", @"IdleManuallySet", @"User Icon"
 *   @"TextProfile", @"DefaultUserIconFilename", @"StatusState"
 * @return NSSet of supported keys
 */
- (NSSet *)supportedPropertyKeys
{
	static	NSSet	*supportedPropertyKeys = nil;
	if (!supportedPropertyKeys) {
		supportedPropertyKeys = [[NSSet alloc] initWithObjects:
                                 @"Online",
                                 @"FormattedUID",
                                 KEY_ACCOUNT_DISPLAY_NAME,
                                 @"Display Name",
                                 @"StatusState",
                                 @"IdleSince",
                                 @"Enabled",
                                 nil];
	}
    
	return supportedPropertyKeys;
}

/*!
 * @brief Update account status
 *
 * Update account status for the changed key.  This is called when account status changes Adium-side and the account
 * code should update status account/server side in response.  The new value for the key can be accessed using
 * the statusForKey method.
 * @param key The updated status key
 */
- (void)updateStatusForKey:(NSString *)key
{
	[super updateStatusForKey:key];

    if ([key isEqualToString:@"Enabled"] && [[self valueForProperty:@"Enabled"] boolValue] == NO)
    {
        tryingToConnect = NO;
        connected = NO;
        [self stopTimer];
    }
    else if ([self online])
    {
        if ([key isEqualToString:@"StatusState"])
        {
            AIStatus*   status = [self status];
            [adiumsoul sendMessageToSocket:[NSPMessages setState:[self stateFromStatus:status]] appendNewLine:YES];
        }
        else if ([key isEqualToString:@"IdleSince"])
        {
            NSDate* date = [self statusForKey:key];
            [adiumsoul sendMessageToSocket:[NSPMessages setState:(date ? NETSOUL_SERVERSTATE_IDLE : NETSOUL_SERVERSTATE_ONLINE)] appendNewLine:YES];
        }
    }
}

//Messaging, Chatting, Strings -----------------------------------------------------------------------------------------
#pragma mark Messaging, Chatting, Strings

/*!
 * @brief Open a chat
 *
 * Open the passed chat account-side.  Depending on the protocol, account code may need to establish a connection in
 * response to this method or perhaps make no actions at all.  This method is used by both one-on-one chats and
 * multi-user chats.
 * @param chat The chat to open
 * @return YES on success
 */
- (BOOL)openChat:(AIChat *)chat
{
    return YES;
}

/*!
 * @brief Close a chat
 *
 * Close the passed chat account-side.  Depending on the protocol, account code may need to close a connection in
 * response to this method or perhaps make no actions at all.  This method is used by both one-on-one chats and
 * multi-user chats.
 *
 * This method should *only* be called by a core controller.  Call [[adium interfaceController] closeChat:chat] to perform a close from other code.
 *
 * @param chat The chat to close
 * @return YES on success
 */
- (BOOL)closeChat:(AIChat *)chat
{
    return YES;
}

/*!
 * @brief Send a typing object
 *
 * The content object contains all the necessary information for sending,
 * including the destination contact.
 */
- (void)sendTypingObject:(AIContentTyping *)inTypingObject
{
    [adiumsoul sendTypingEvent:[inTypingObject typingState] toUser:[[[inTypingObject chat] listObject] UID]];
}

/*!
 * @brief Send a message
 *
 * The content object contains all the necessary information for sending,
 * including the destination contact. [inMessageObject encodedMessage] contains the NSString which should be sent.
 */
- (BOOL)sendMessageObject:(AIContentMessage *)inMessageObject
{
    NSString*   encodedMessage = [inMessageObject encodedMessage];

    if ([encodedMessage length] > NETSOUL_MESSAGE_MAX_LEN)
    {
        [[adium contentController] displayEvent:[NSString stringWithFormat:@"Message is too long : %i characters maximum, your has %i", NETSOUL_MESSAGE_MAX_LEN, [encodedMessage length]]
                                         ofType:@"chat-error"
                                         inChat:[inMessageObject chat]];
        return NO;
    }
    return [adiumsoul sendMessage:encodedMessage toUser:[[[inMessageObject chat] listObject] UID]];
}

- (void)receiveMessage:(NSString *)message fromUser:(NSString *)user
{
    AIListContact*      listContact;
    AIChat*             chat;
    AIContentMessage*   msg;

    listContact = [[adium contactController] contactWithService:service account:self UID:user];
    chat = [[adium chatController] chatWithContact:listContact];
    msg = [AIContentMessage messageInChat:chat
                               withSource:listContact
                              destination:self
                                     date:nil
                                  message:[[[NSAttributedString alloc] initWithString:message
                                                                           attributes:[[adium contentController]
                                                                                       defaultFormattingAttributes]]
                                           autorelease]
                                autoreply:NO];
    [[adium contentController] receiveContentObject:msg];
}

//Presence Tracking ----------------------------------------------------------------------------------------------------
#pragma mark Presence Tracking

/*!
 * @brief Contact list editable?
 *
 * Returns YES if the contact list is currently editable
 * // XXX - Ce paramètre apparait dans le .m dans les commentaires (comme ici), mais pas dans la déclaration ni implémentation -naixn
 * @param object AIContentObject to send
 * @return YES on success
 */
- (BOOL)contactListEditable
{
    return YES;
}

/*!
 * @brief Add contacts
 *
 * Add contacts to a group on this account.  Create the group if it doesn't already exist.
 * @param objects NSArray of AIListContact objects to add
 * @param group AIListGroup destination for contacts
 */
- (void)addContact:(AIListContact *)contact toGroup:(AIListGroup *)group
{
    [netsoulContactList createContactWithUID:[contact UID] inGroup:[group UID] addToList:YES];
    [adiumsoul watchUser:[contact UID]];
    [adiumsoul whoUser:[contact UID]];
}

/*!
 * @brief Remove contacts
 *
 * Remove contacts from this account.
 * @param objects NSArray of AIListContact objects to remove
 */
- (void)removeContacts:(NSArray *)objects
{
    NSEnumerator*   en = [objects objectEnumerator];
    AIListContact*  contact;
    
    while ((contact = [en nextObject]))
    {
        [netsoulContactList removeContactWithUID:[contact UID]];
    }
}

/*!
 * @brief Move contacts
 *
 * Move existing contacts to a specific group on this account.  The passed contacts should already exist somewhere on
 * this account.
 * @param objects NSArray of AIListContact objects to remove
 * @param groups NSSet of AIListGroup's destination for contacts
 */
- (void)moveListObjects:(NSArray *)objects toGroups:(NSSet *)groups
{
    [netsoulContactList moveUsers:objects toGroups:groups];

    for (AIListGroup* group in groups)
    {
        for (AIListContact* contact in objects)
        {
            [contact addRemoteGroupName:[group UID]];
            [contact notifyOfChangedPropertiesSilently:NO];
        }
    }
//    NSEnumerator*   en = [objects objectEnumerator];
//    AIListContact*  contact;
//    while ((contact = [en nextObject]))
//    {
//        [contact addRemoteGroupName:[group UID]];
//        [contact notifyOfChangedPropertiesSilently:NO];
//    }
    AILog(@"[Adiumsoul] Changed contact(s) group");
}

/*!
 * @brief Return the data for the serverside icon for a contact
 */
- (NSData *)serversideIconDataForContact:(AIListContact *)contact
{
    return [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", NETSOUL_PHOTO_URL, [contact UID]]]];
}

#pragma mark -
#pragma mark Interface interaction

- (void)setLocation:(NSString *)location
{
    [self setPreference:location forKey:NETSOUL_KEY_LOCATION group:GROUP_ACCOUNT_STATUS];
    locationSet = YES;
    [self connect];
}

#pragma mark -
#pragma mark Other classes interaction

- (void)disconnectedFromServer
{
    BOOL    reconnect = [[self preferenceForKey:NETSOUL_KEY_RECONNECT group:GROUP_ACCOUNT_STATUS] boolValue];
    int     reconnectTime = [[self preferenceForKey:NETSOUL_KEY_RECONNECT_TIME group:GROUP_ACCOUNT_STATUS] intValue];

    AILog(@"[AdiumSoul] Disconnected from server.");
    [self disconnect];
    if ([[self preferenceForKey:NETSOUL_KEY_DISCONNECT_ALERT group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        NSMutableString*   errorDesc = [NSMutableString stringWithString:@"AdiumSoul has been disconnected from the server."];
        if (reconnect)
        {
            [errorDesc appendFormat:@" As you configured, AdiumSoul will try to reconnect every %i seconds until connected", reconnectTime];
        }
        [[adium interfaceController] handleErrorMessage:[NSString stringWithFormat:@"AdiumSoul - Server error"]
                                        withDescription:errorDesc];
    }
    if (reconnect)
    {
        AILog(@"[AdiumSoul] Launching reconnection timer");
        if (connectionTimer)
        {
            [self stopTimer];
        }
        connectionTimer = [NSTimer scheduledTimerWithTimeInterval:reconnectTime target:self selector:@selector(tryToReconnect:) userInfo:nil repeats:YES];
        [connectionTimer retain];
    }
}

- (void)tryToReconnect:(NSTimer*)theTimer
{
    if (connected)
    {
        AILog(@"[AdiumSoul] Connected, need to invalidate timer");
        [self stopTimer];
        return ;
    }
    if (tryingToConnect)
    {
        AILog(@"[AdiumSoul] Already trying to connect, waiting...");
        return ;
    }
    locationSet = YES;
    [self connect];
}

- (void)stopTimer
{
    AILog(@"[AdiumSoul] Invalidating potential timer");
    [connectionTimer invalidate];
    [connectionTimer release];
    connectionTimer = nil;
}

- (void)receivedInfo:(NSArray *)infos forUser:(NSString *)uid
{
    AIListContact*          contact = [netsoulContactList contactWithUID:uid];
    ASContact*     adiumsoulContact;

    AILog(@"[AdiumSoul] Updatding %@", contact);
    adiumsoulContact = [contact valueForProperty:NETSOUL_CONTACT];
    [adiumsoulContact setInformations:infos onSocket:[infos objectAtIndex:1]];
    [contact setValue:[adiumsoulContact informations] forProperty:@"Client" notify:NO];
    [contact setValue:[NSNumber numberWithBool:YES] forProperty:@"Online" notify:NO];
    [contact setValue:[contact UID] forProperty:@"Server Display Name" notify:NO];
    [contact setValue:[NSDate dateWithTimeIntervalSince1970:[[infos objectAtIndex:4] intValue]] forProperty:@"Signon Date" notify:NO];
    [contact setUserIconData:[self serversideIconDataForContact:contact]];
    [self updateUIStateForContact:contact];
    [contact notifyOfChangedPropertiesSilently:NO];
}

- (void)contactIsNowOnline:(NSString *)uid
{
    AIListContact*  contact = [netsoulContactList contactWithUID:uid];

    [contact setOnline:YES notify:YES silently:NO];
    [contact addRemoteGroupName:@"NetSoul"];
    [adiumsoul whoUser:uid];
}

- (void)contactIsNowOffline:(NSString *)uid deleteInformationOnSocket:(NSString *)socket
{
    AIListContact*      contact = [netsoulContactList contactWithUID:uid];
    ASContact* adiumsoulContact;

    adiumsoulContact = [contact valueForProperty:NETSOUL_CONTACT];
    [adiumsoulContact removeInformationsOnSocket:socket];
    [contact setValue:[adiumsoulContact informations] forProperty:@"Client" notify:NO];
    if (![adiumsoulContact stillOnline])
    {
        [contact setUserIconData:nil];
        [contact setOnline:NO notify:YES silently:NO];
    }
    else
    {
        [self updateUIStateForContact:contact];
    }
    [contact notifyOfChangedPropertiesSilently:NO];
}

- (void)contact:(NSString *)uid changedState:(NSString *)state onSocket:(NSString *)socket
{
    AIListContact*      contact = [netsoulContactList contactWithUID:uid];
    ASContact* adiumsoulContact;
    NSString*           previousMainSocket;
    NSString*           previousMainState;

    adiumsoulContact = [contact valueForProperty:NETSOUL_CONTACT];
    previousMainSocket = [[adiumsoulContact mainSocket] retain];
    previousMainState = [[adiumsoulContact mainState] retain];
    [adiumsoulContact setInformation:state forKey:NETSOUL_CONTACT_STATE onSocket:socket];
    [contact setValue:[adiumsoulContact informations] forProperty:@"Client" notify:NO];
    if ((![[adiumsoulContact mainSocket] isEqualToString:previousMainSocket]) || (![[adiumsoulContact mainState] isEqualToString:previousMainState]))
    {
        [self updateUIStateForContact:contact];
    }
    [contact notifyOfChangedPropertiesSilently:NO];
    [previousMainState release];
    [previousMainSocket release];
}

- (void)contactStartedTyping:(NSString *)uid
{
    AIChat* chat = [[adium chatController] existingChatWithContact:[netsoulContactList contactWithUID:uid]];

    [chat setValue:[NSNumber numberWithInt:AITyping] forProperty:KEY_TYPING notify:YES];
}

- (void)contactStoppedTyping:(NSString *)uid
{
    AIChat* chat = [[adium chatController] existingChatWithContact:[netsoulContactList contactWithUID:uid]];
    
    [chat setValue:nil forProperty:KEY_TYPING notify:YES];
}

#pragma mark -
#pragma mark Status management

- (void)updateUIStateForContact:(AIListContact *)contact
{
    [self updateUIStateForContact:contact withState:[[contact valueForProperty:NETSOUL_CONTACT] mainState]];
}

- (void)updateUIStateForContact:(AIListContact *)contact withState:(NSString *)state
{
    if ([[self preferenceForKey:NETSOUL_KEY_DISPLAY_LOCATION group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        [contact setStatusMessage:[[[NSAttributedString alloc] initWithString:[[contact valueForProperty:NETSOUL_CONTACT] mainLocation]] autorelease]
                           notify:NO];
    }
    if ([state isEqualToString:NETSOUL_SERVERSTATE_ONLINE])
    {
        [contact setIdle:NO sinceDate:nil notify:NO];
        [contact setValue:nil forProperty:@"StatusType" notify:NO];
    }
    else if ([state isEqualToString:NETSOUL_SERVERSTATE_IDLE])
    {
        [contact setIdle:YES sinceDate:[NSDate date] notify:NO];
    }
    else if ([state isEqualToString:NETSOUL_SERVERSTATE_AWAY] || [state isEqualToString:NETSOUL_SERVERSTATE_SERVER])
    {
        [contact setIdle:NO sinceDate:nil notify:NO];
        [contact setValue:[NSNumber numberWithInt:AIAwayStatusType] forProperty:@"StatusType" notify:NO];
    }
}

- (NSString *)stateFromStatus:(AIStatus *)status
{
    if ([status statusType] == AIAvailableStatusType)
    {
        return NETSOUL_SERVERSTATE_ONLINE;
    }
    else if ([status statusType] == AIAwayStatusType)
    {
        return NETSOUL_SERVERSTATE_AWAY;
    }
    return NETSOUL_SERVERSTATE_AWAY;
}

#pragma mark -
#pragma mark Getters

- (NSString *)password
{
    return [password description];
}

- (NSPAdiumsoul *)netsoul
{
    return adiumsoul;
}

- (AIStatus *)status
{
    return [self valueForProperty:@"StatusState"];
}

@end
