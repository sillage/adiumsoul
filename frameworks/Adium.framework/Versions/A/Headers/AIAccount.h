/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <Adium/AIListObject.h>

@class AIListContact, AIChat, AIContentObject, ESFileTransfer, AIStatus, AIContentMessage, AIContentTyping;

#define GROUP_ACCOUNT_STATUS   @"Account Status"

//All keys below are for NSString objects
#define KEY_CONNECT_HOST 			@"Connect Host"
#define KEY_DEFAULT_USER_ICON		@"Default User Icon"
#define KEY_USE_USER_ICON			@"Use User Icon"

//NSNumber objects
#define KEY_CONNECT_PORT 			@"Connect Port"
#define KEY_ACCOUNT_CHECK_MAIL		@"Check Mail"
#define KEY_ENABLED					@"Enabled"
#define KEY_AUTOCONNECT				@"AutoConnect"

//NSData archive of an NSAttributedString
#define KEY_ACCOUNT_DISPLAY_NAME	@"FullNameAttr"

#define	Adium_RequestImmediateDynamicContentUpdate	@"Adium_RequestImmediateDynamicContentUpdate"

//Proxy
#define KEY_ACCOUNT_PROXY_ENABLED		@"Proxy Enabled"
#define KEY_ACCOUNT_PROXY_TYPE			@"Proxy Type"
#define KEY_ACCOUNT_PROXY_HOST			@"Proxy Host"
#define KEY_ACCOUNT_PROXY_PORT			@"Proxy Port"
#define KEY_ACCOUNT_PROXY_USERNAME		@"Proxy Username"
#define KEY_ACCOUNT_PROXY_PASSWORD		@"Proxy Password"

//Proxy types
typedef enum
{
	Adium_Proxy_HTTP,
	Adium_Proxy_SOCKS4,
	Adium_Proxy_SOCKS5,
	Adium_Proxy_Default_HTTP,
	Adium_Proxy_Default_SOCKS4,
	Adium_Proxy_Default_SOCKS5,
	Adium_Proxy_None
} AdiumProxyType;

//Privacy
typedef enum {
    AIPrivacyTypePermit = 0,
    AIPrivacyTypeDeny
}  AIPrivacyType;

typedef enum {
    AIPrivacyOptionAllowAll = 1,		//Anyone can conctact you
	AIPrivacyOptionDenyAll,				//Nobody can contact you
	AIPrivacyOptionAllowUsers,			//Only those on your allow list can contact you
	AIPrivacyOptionDenyUsers,			//Those on your deny list can't contact you
	AIPrivacyOptionAllowContactList,	//Only those on your contact list can contact you
	AIPrivacyOptionUnknown,			//used by the privacy settings window, but could probably also be used by accounts
	AIPrivacyOptionCustom				//used by the privacy settings window
} AIPrivacyOption;

//Support for file transfer
@protocol AIAccount_Files
	//can the account send entire folders on its own?
	- (BOOL)canSendFolders;

    //Instructs the account to accept a file transfer request
    - (void)acceptFileTransferRequest:(ESFileTransfer *)fileTransfer;

    //Instructs the account to reject a file receive request
    - (void)rejectFileReceiveRequest:(ESFileTransfer *)fileTransfer;

    //Instructs the account to initiate sending of a file
	- (void)beginSendOfFileTransfer:(ESFileTransfer *)fileTransfer;

	//Instructs the account to cancel a filet ransfer in progress
	- (void)cancelFileTransfer:(ESFileTransfer *)fileTransfer;
@end

//Support for privacy settings
@protocol AIAccount_Privacy
    //Add a list object to the privacy list (either AIPrivacyTypePermit or AIPrivacyTypeDeny). Return value indicates success.
    -(BOOL)addListObject:(AIListObject *)inObject toPrivacyList:(AIPrivacyType)type;
    //Remove a list object from the privacy list (either AIPrivacyTypePermit or AIPrivacyTypeDeny). Return value indicates success
    -(BOOL)removeListObject:(AIListObject *)inObject fromPrivacyList:(AIPrivacyType)type;
	//Return an array of AIListContacts on the specified privacy list.  Returns an empty array if no contacts are on the list.
	-(NSArray *)listObjectsOnPrivacyList:(AIPrivacyType)type;
    //Set the privacy options
    -(void)setPrivacyOptions:(AIPrivacyOption)option;
	//Get the privacy options
	-(AIPrivacyOption)privacyOptions;
@end

/*!
 * @class AIAccount
 * @abstract An account of ours (one we connect to and use to talk to handles)
 * @discussion The base AIAccount class provides no practical functionality,
 * so almost all of the AIAccounts you deal with will be subclasses.  You will
 * almost never need to talk directly with an AIAccount.  For information on
 * accounts, check out 'working with accounts' and 'creating service code'.
 */
@interface AIAccount : AIListObject {
	int							accountNumber;					//Unique integer that represents this account
	
    NSString                    *password;
    BOOL                        silentAndDelayed;				//We are waiting for and processing our sign on updates
    BOOL						disconnectedByFastUserSwitch;	//We are offline because of a fast user switch
	BOOL						namesAreCaseSensitive;
	BOOL						isTemporary;

	BOOL						enabled;
	
	//Attributed string refreshing
    NSTimer                     *attributedRefreshTimer;
    NSMutableSet				*autoRefreshingKeys;
	NSMutableSet				*dynamicKeys;
	
	//Contact update guarding
	NSTimer						*delayedUpdateStatusTimer;
	AIListContact				*delayedUpdateStatusTarget;
	NSTimer						*silenceAllContactUpdatesTimer;
}

- (void)initAccount;
- (void)connect;
- (void)disconnect;
- (void)disconnectFromDroppedNetworkConnection;
- (void)performRegisterWithPassword:(NSString *)inPassword;
- (NSString *)accountWillSetUID:(NSString *)proposedUID;
- (void)didChangeUID;
- (void)willBeDeleted;
- (NSString *)explicitFormattedUID;

//Properties
- (BOOL)supportsAutoReplies;
- (BOOL)disconnectOnFastUserSwitch;
- (BOOL)connectivityBasedOnNetworkReachability;
- (BOOL)suppressTypingNotificationChangesAfterSend;
- (BOOL)canSendOfflineMessageToContact:(AIListContact *)inContact;
- (BOOL)allowsNewlinesInMessages;
- (BOOL)supportsFolderTransfer;

//Status
- (NSSet *)supportedPropertyKeys;
- (id)statusForKey:(NSString *)key;
- (void)updateStatusForKey:(NSString *)key;
- (void)delayedUpdateContactStatus:(AIListContact *)inContact;
- (float)delayedUpdateStatusInterval;
- (void)setStatusState:(AIStatus *)statusState usingStatusMessage:(NSAttributedString *)statusMessage;
- (BOOL)shouldUpdateAutorefreshingAttributedStringForKey:(NSString *)inKey;

//Messaging, Chatting, Strings
- (BOOL)availableForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact;
- (BOOL)openChat:(AIChat *)chat;
- (BOOL)closeChat:(AIChat *)chat;
- (BOOL)inviteContact:(AIListObject *)contact toChat:(AIChat *)chat withMessage:(NSString *)inviteMessage;
- (BOOL)joinGroupChatNamed:(NSString *)name;
- (void)sendTypingObject:(AIContentTyping *)inTypingObject;
- (BOOL)sendMessageObject:(AIContentMessage *)inMessageObject;
- (NSString *)encodedAttributedString:(NSAttributedString *)inAttributedString forListObject:(AIListObject *)inListObject;
- (NSString *)encodedAttributedStringForSendingContentMessage:(AIContentMessage *)inContentMessage;

//Presence Tracking
- (BOOL)contactListEditable;
- (void)addContacts:(NSArray *)objects toGroup:(AIListGroup *)group;
- (void)removeContacts:(NSArray *)objects;
- (void)deleteGroup:(AIListGroup *)group;
- (void)moveListObjects:(NSArray *)objects toGroup:(AIListGroup *)group;
- (void)renameGroup:(AIListGroup *)group to:(NSString *)newName;

//Contact-specific menu items
- (NSArray *)menuItemsForContact:(AIListContact *)inContact;

//Account-specific menu items
- (NSArray *)accountActionMenuItems;

//Secure messaging
- (BOOL)allowSecureMessagingTogglingForChat:(AIChat *)inChat;
- (NSString *)aboutEncryption;
- (void)requestSecureMessaging:(BOOL)inSecureMessaging
						inChat:(AIChat *)inChat;
- (void)promptToVerifyEncryptionIdentityInChat:(AIChat *)inChat;

- (BOOL)canSendImagesForChat:(AIChat *)inChat;

- (void)authorizationWindowController:(NSWindowController *)inWindowController authorizationWithDict:(NSDictionary *)infoDict didAuthorize:(BOOL)inDidAuthorize;

@end

@interface AIAccount (Private_ForSubclasses)
- (void)gotFilteredDisplayName:(NSAttributedString *)attributedDisplayName;
@end

#import <Adium/AIAbstractAccount.h>
