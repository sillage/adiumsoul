//
//  ASAccount.h
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

#import <Adium/AIAccount.h>
//#import <AIUtilities/AIWiredString.h>
#import "NSPAdiumsoul.h"
#import "ASContactList.h"
#import "ASILocation.h"


#define NETSOUL_PHOTO_URL @"http://www.epitech.net/intra/photo.php?login="
#define NETSOUL_MESSAGE_MAX_LEN 512

typedef struct  s_connectionSteps
{
    int         nb;
    NSString*   text;
}               cnxSteps;

enum
{
    NETSOUL_STEP_CONNECTING = 0,
    NETSOUL_STEP_CONNECTION_ESTABLISHED,
    NETSOUL_STEP_AUTH_AG_REQUEST,
    NETSOUL_STEP_AUTHENTICATION
};

@interface ASAccount : AIAccount
{
    NSPAdiumsoul*           adiumsoul;
    ASContactList* netsoulContactList;
    BOOL                    tryingToConnect;
    BOOL                    connected;
    NSTimer*                connectionTimer;

    // attributes for location window
    ASILocation*   locationWindow;
    BOOL                    locationSet;
}

- (void)initAccount;

// Connection related methods
- (void)connect;
- (void)connectionProgressStep:(int)step;
- (void)disconnect;
- (void)didConnect;

//Properties
- (BOOL)disconnectOnFastUserSwitch;
- (BOOL)suppressTypingNotificationChangesAfterSend;

//Status
- (NSSet *)supportedPropertyKeys;
- (void)updateStatusForKey:(NSString *)key;

//Messaging, Chatting, Strings
- (BOOL)openChat:(AIChat *)chat;
- (BOOL)closeChat:(AIChat *)chat;
- (void)sendTypingObject:(AIContentTyping *)inTypingObject;
- (BOOL)sendMessageObject:(AIContentMessage *)inMessageObject;
- (void)receiveMessage:(NSString *)message fromUser:(NSString *)user;

//Presence Tracking
- (BOOL)contactListEditable;
- (void)addContact:(AIListContact *)contact toGroup:(AIListGroup *)group;
- (void)removeContacts:(NSArray *)objects;
- (void)moveListObjects:(NSArray *)objects toGroups:(NSSet *)groups;
- (NSData *)serversideIconDataForContact:(AIListContact *)contact;

// Interface interaction
- (void)setLocation:(NSString *)location;

// Other classes interaction
- (void)disconnectedFromServer;
- (void)tryToReconnect:(NSTimer*)theTimer;
- (void)stopTimer;
- (void)receivedInfo:(NSArray *)infos forUser:(NSString *)uid;
- (void)contactIsNowOnline:(NSString *)uid;
- (void)contactIsNowOffline:(NSString *)uid deleteInformationOnSocket:(NSString *)socket;
- (void)contact:(NSString *)uid changedState:(NSString *)state onSocket:(NSString *)socket;
- (void)contactStartedTyping:(NSString *)uid;
- (void)contactStoppedTyping:(NSString *)uid;

// Status management
- (void)updateUIStateForContact:(AIListContact *)contact;
- (void)updateUIStateForContact:(AIListContact *)contact withState:(NSString *)state;
- (NSString *)stateFromStatus:(AIStatus *)status;

// getters
- (NSString *)password;
- (NSPAdiumsoul *)netsoul;
- (AIStatus *)status;

@end
