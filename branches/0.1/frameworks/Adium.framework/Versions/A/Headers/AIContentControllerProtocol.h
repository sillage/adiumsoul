/*
 *  AIContentControllerProtocol.h
 *  Adium
 *
 *  Created by Evan Schoenberg on 7/31/06.
 *
 */

#import <Adium/AIControllerProtocol.h>
#import <Adium/AIListContact.h>

#define Content_ContentObjectAdded					@"Content_ContentObjectAdded"
#define Content_ChatDidFinishAddingUntrackedContent	@"Content_ChatDidFinishAddingUntrackedContent"
#define Content_WillSendContent						@"Content_WillSendContent"
#define Content_WillReceiveContent					@"Content_WillReceiveContent"

//XXX - This is really UI, but it can live here for now
#define PREF_GROUP_FORMATTING				@"Formatting"
#define KEY_FORMATTING_FONT					@"Default Font"
#define KEY_FORMATTING_TEXT_COLOR			@"Default Text Color"
#define KEY_FORMATTING_BACKGROUND_COLOR		@"Default Background Color"

//Not displayed, but used for internal identification of the encryption menu
#define ENCRYPTION_MENU_TITLE						@"Encryption Menu"

typedef enum {
	AIFilterContent = 0,		// Changes actual message and non-message content
	AIFilterDisplay,			// Changes only how non-message content is displayed locally (Profiles, aways, auto-replies, ...)
	AIFilterMessageDisplay,  	// Changes only how messages are displayed locally
	AIFilterTooltips,			// Changes only information displayed in contact tooltips
	AIFilterContactList,		// Changes only information in statuses displayed in the contact list
	/* A special content mode for AIM auto-replies that will only apply to bounced away messages.  This allows us to
	 * filter %n,%t,... just like the official client.  A small tumor in our otherwise beautiful filter system *cry*
	 */
	AIFilterAutoReplyContent
	
} AIFilterType;
#define FILTER_TYPE_COUNT 6

typedef enum {
	AIFilterIncoming = 0,   // Content we are receiving
	AIFilterOutgoing		// Content we are sending
} AIFilterDirection;
#define FILTER_DIRECTION_COUNT 2

#define HIGHEST_FILTER_PRIORITY 0
#define HIGH_FILTER_PRIORITY 0.25
#define DEFAULT_FILTER_PRIORITY 0.5
#define LOW_FILTER_PRIORITY 0.75
#define LOWEST_FILTER_PRIORITY 1.0

@protocol AIContentFilter, AIDelayedContentFilter;
@protocol AdiumMessageEncryptor;

@class AIAccount, AIChat, AIListContact, AIListObject, AIContentObject;
@class AIContentMessage;

@protocol AIContentController <AIController>
//Typing
- (void)userIsTypingContentForChat:(AIChat *)chat hasEnteredText:(BOOL)hasEnteredText;

	//Formatting
- (NSDictionary *)defaultFormattingAttributes;

	//Content Filtering
- (void)registerContentFilter:(id <AIContentFilter>)inFilter
					   ofType:(AIFilterType)type
					direction:(AIFilterDirection)direction;
- (void)registerDelayedContentFilter:(id <AIDelayedContentFilter>)inFilter
							  ofType:(AIFilterType)type
						   direction:(AIFilterDirection)direction;;
- (void)unregisterContentFilter:(id <AIContentFilter>)inFilter;
- (void)registerFilterStringWhichRequiresPolling:(NSString *)inPollString;
- (BOOL)shouldPollToUpdateString:(NSString *)inString;

- (NSAttributedString *)filterAttributedString:(NSAttributedString *)attributedString
							   usingFilterType:(AIFilterType)type
									 direction:(AIFilterDirection)direction
									   context:(id)context;
- (void)filterAttributedString:(NSAttributedString *)attributedString
			   usingFilterType:(AIFilterType)type
					 direction:(AIFilterDirection)direction
				 filterContext:(id)filterContext
			   notifyingTarget:(id)target
					  selector:(SEL)selector
					   context:(id)context;
- (void)delayedFilterDidFinish:(NSAttributedString *)attributedString uniqueID:(unsigned long long)uniqueID;

	//Sending / Receiving content
- (BOOL)availableForSendingContentType:(NSString *)inType toContact:(AIListContact *)inContact onAccount:(AIAccount *)inAccount;
- (void)receiveContentObject:(AIContentObject *)inObject;
- (BOOL)sendContentObject:(AIContentObject *)inObject;
- (void)sendRawMessage:(NSString *)inString toContact:(AIListContact *)inContact;
- (void)displayContentObject:(AIContentObject *)inObject;
- (void)displayContentObject:(AIContentObject *)inObject immediately:(BOOL)immediately;
- (void)displayContentObject:(AIContentObject *)inObject usingContentFilters:(BOOL)useContentFilters;
- (void)displayContentObject:(AIContentObject *)inObject usingContentFilters:(BOOL)useContentFilters immediately:(BOOL)immediately;
- (void)displayEvent:(NSString *)message ofType:(NSString *)type inChat:(AIChat *)inChat;

	//Encryption
- (NSAttributedString *)decodedIncomingMessage:(NSString *)inString
								   fromContact:(AIListContact *)inListContact 
									 onAccount:(AIAccount *)inAccount;
- (NSString *)decryptedIncomingMessage:(NSString *)inString
						   fromContact:(AIListContact *)inListContact
							 onAccount:(AIAccount *)inAccount;

- (NSMenu *)encryptionMenuNotifyingTarget:(id)target withDefault:(BOOL)withDefault;

- (BOOL)chatIsReceivingContent:(AIChat *)chat;

	//OTR
- (void)setEncryptor:(id<AdiumMessageEncryptor>)inEncryptor;
- (void)requestSecureOTRMessaging:(BOOL)inSecureMessaging inChat:(AIChat *)inChat;
- (void)promptToVerifyEncryptionIdentityInChat:(AIChat *)inChat;
@end

//AIContentFilters have the opportunity to examine every attributed string.  Non-attributed strings are not passed through these filters.
@protocol AIContentFilter
- (NSAttributedString *)filterAttributedString:(NSAttributedString *)inAttributedString context:(id)context;
- (float)filterPriority;
@end

//Delayed content filters return YES if they begin a delayed filter, NO if they don't.
@protocol AIDelayedContentFilter
- (BOOL)delayedFilterAttributedString:(NSAttributedString *)inAttributedString context:(id)context uniqueID:(unsigned long long)uniqueID;
- (float)filterPriority;
@end

@protocol AdiumMessageEncryptor <NSObject>
- (void)willSendContentMessage:(AIContentMessage *)inContentMessage;
- (NSString *)decryptIncomingMessage:(NSString *)inString fromContact:(AIListContact *)inListContact onAccount:(AIAccount *)inAccount;

- (void)requestSecureOTRMessaging:(BOOL)inSecureMessaging inChat:(AIChat *)inChat;
- (void)promptToVerifyEncryptionIdentityInChat:(AIChat *)inChat;
@end
