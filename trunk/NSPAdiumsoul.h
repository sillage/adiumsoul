//
//  NSPAdiumsoul.h
//  NetSoulProtocol - AdiumSoul
//
//  Created by Naixn on 09/04/08.
//

#import <Adium/AIContentTyping.h>


@class NSAdiumsoulAccount;

#define NETSOUL_KEY_USERDATA @"User Data"
#define NETSOUL_KEY_LOCATION @"Location"
#define NETSOUL_KEY_ASK_LOCATION @"Ask Location On Start"
#define NETSOUL_KEY_DISPLAY_LOCATION @"Display location as status message"
#define NETSOUL_KEY_KERBEROOS @"Use Kerberos"
#define NETSOUL_KEY_DISCONNECT_ALERT @"Display an alert when disconnected"
#define NETSOUL_KEY_RECONNECT @"Reconnect avec disconnection"
#define NETSOUL_KEY_RECONNECT_TIME @"Reconnection time"
#define NETSOUL_KEY_PROMO @"Promotion"

@interface NSPAdiumsoul : NSObject
{
    NSAdiumsoulAccount* account;
    NSFileHandle*       connection;
    BOOL                authenticated;

    NSString*           lastMessage;
    /*
    * Each time we need to wait for a reply, we add a dictionnary with the message
    * to send to self, and an optionnal parameter object
    */
    NSMutableArray*     replyDataPool;
}

// Init and connexion
- (id)initWithAdiumAccount:(NSAdiumsoulAccount *)account;
- (void)threadConnect:(id)mainThreadOject;
- (void)failedToConnect;
- (void)didConnectWithFd:(id)fdNumber;
- (void)connect;
- (BOOL)disconnect;
- (BOOL)isAuthenticated;

// Socket relative function
- (void)receiveMessageFromSocket:(NSNotification *)notification;
- (void)sendMessageToSocket:(NSString *)message appendNewLine:(BOOL)appendNewLine;

// User-side actions
- (BOOL)sendMessage:(NSString *)message toUser:(NSString *)user;
- (void)sendTypingEvent:(AITypingState)state toUser:(NSString *)user;
- (void)watchUser:(NSString *)user;
- (void)watchUsers:(NSArray *)user;
- (void)whoUser:(NSString *)user;
- (void)whoUsers:(NSArray *)users;

// Handling commands
+ (SEL)selectorForCommand:(NSString *)command;
- (void)userCommand:(NSString *)message;
- (void)firstReply:(NSString *)message;
- (void)authenticate:(NSMutableDictionary *)authenticationValues;
- (void)authenticationFailed;
- (void)ready;
- (void)ping;
//// Events
- (void)recvMessage:(NSDictionary *)message;
- (void)recvLogin:(NSDictionary *)data;
- (void)recvLogout:(NSDictionary *)data;
- (void)recvChangeStatus:(NSDictionary *)data;
- (void)recvStartTyping:(NSDictionary *)data;
- (void)recvStopTyping:(NSDictionary *)data;
- (void)recvUserInfo:(NSDictionary *)data;

// Handling replies
- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)obj orErrorMessage:(NSString *)error;
- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)obj;
- (void)handleReply:(NSString *)message;

@end
