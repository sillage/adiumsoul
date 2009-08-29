//
//  NSPAdiumsoul.m
//  NetSoulProtocol - AdiumSoul
//
//  Created by Naixn on 09/04/08.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>

#import <Adium/AIPreferenceControllerProtocol.h>
#import <Adium/AIAccountControllerProtocol.h>

#import "NSAdiumsoulAccount.h"
#import "NSPAdiumsoul.h"
#import "NSPMessages.h"

static NSMutableDictionary* gl_functions = nil;

@implementation NSPAdiumsoul

- (id)initWithAdiumAccount:(NSAdiumsoulAccount *)adiumsoulAccount;
{
    if (self = [super init])
    {
        connection     = nil;
        authenticated  = NO;
        account        = [adiumsoulAccount retain];
        lastMessage    = nil;
        replyDataPool  = nil;
    }
    return self;
}

- (void) dealloc
{
    [account release];
    [super dealloc];
}

- (void)threadConnect:(id)mainThreadOject
{
    NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
    NSData*         address;
    NSSocketPort*   sock;
    int             s;
    int             cs;

    AILog(@"[AdiumSoul] Thread connect");
    sock = [[NSSocketPort alloc] initRemoteWithTCPPort:[[account preferenceForKey:KEY_CONNECT_PORT group:GROUP_ACCOUNT_STATUS] intValue]
                                                  host:[account preferenceForKey:KEY_CONNECT_HOST group:GROUP_ACCOUNT_STATUS]
            ];
    if (sock == nil)
    {
        AILog(@"[AdiumSoul] sock == nil");
        [mainThreadOject performSelectorOnMainThread:@selector(failedToConnect) withObject:nil waitUntilDone:NO];
        [pool drain];
        return [NSThread exit];
    }
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s < 0)
    {
        AILog(@"[AdiumSoul] s < 0");
        [sock release];
        [mainThreadOject performSelectorOnMainThread:@selector(failedToConnect) withObject:nil waitUntilDone:NO];
        [pool drain];
        return [NSThread exit];
    }
    address = [sock address];
    cs = connect(s, [address bytes], [address length]);
    if (cs < 0)
    {
        AILog(@"[AdiumSoul] cs < 0");
        [sock release];
        close(s);
        [mainThreadOject performSelectorOnMainThread:@selector(failedToConnect) withObject:nil waitUntilDone:NO];
        [pool drain];
        return [NSThread exit];
    }
    [sock release];

    [mainThreadOject performSelectorOnMainThread:@selector(didConnectWithFd:) withObject:[[NSNumber alloc] initWithInt:s] waitUntilDone:NO];
    [pool drain];
    return [NSThread exit];
}

- (void)failedToConnect
{
    AILog(@"[AdiumSoul] Could not connect... Maybe server is offline?");
    [account didDisconnect];
}

- (void)didConnectWithFd:(id)fdNumber
{
    int fd = [fdNumber intValue];

    [fdNumber release];
    [account connectionProgressStep:NETSOUL_STEP_CONNECTION_ESTABLISHED];
    
    connection = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMessageFromSocket:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:connection];
    [connection readInBackgroundAndNotify];
//    [connection readInBackgroundAndNotifyForModes:[NSArray arrayWithObjects: NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, NSDefaultRunLoopMode, nil]];
    
    replyDataPool = [[NSMutableArray alloc] init];    
}

- (void)connect
{
    AILog(@"[AdiumSoul] adiumsoul connect");
    [NSThread detachNewThreadSelector:@selector(threadConnect:) toTarget:self withObject:self];
}

- (BOOL)disconnect
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (connection)
    {
        [connection closeFile];
        [connection release];
        connection = nil;
    }
    [replyDataPool release];
    replyDataPool = nil;
    authenticated = NO;
    if (account)
    {
        [account didDisconnect];
    }
    AILog(@"[AdiumSoul] Disconnecting");
    return YES;
}

- (BOOL)isAuthenticated
{
    return authenticated;
}

#pragma mark -
#pragma mark Socket relative methods

- (void)receiveMessageFromSocket:(NSNotification *)notification
{
    NSData*         messageData;
    NSString*       message;
    NSString*       tempMessage;
    NSString*       command;
    NSMutableArray* array;
    SEL             selector;

    messageData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    // If there was nothing to read, it means the server disconnected
    if ([messageData length] == 0)
    {
        AILog(@"Server closed the connection");
        //[self disconnect];
        [account disconnectedFromServer];
        return ;
    }

    // Get data string, and append to last time we got something
    tempMessage = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    if (lastMessage)
    {
        message = [lastMessage stringByAppendingString:tempMessage];
        [lastMessage release];
        lastMessage = nil;
    }
    else
    {
        message = [NSString stringWithString:tempMessage];
    }
    [tempMessage release];

    array = [[message componentsSeparatedByString:@"\n"] mutableCopy];
    // If the last component of the array has length >0, it means it didn't end with a \n. We need to keep it for later use.
    if ([[array lastObject] length])
    {
        lastMessage = [[array lastObject] retain];
    }
    [array removeLastObject];

    NSEnumerator*   enumerator = [array objectEnumerator];
    NSString*       line;
    while ((line = [enumerator nextObject]))
    {
        AILog(@"[AdiumSoul] Received line '%@'", line);
        command = [[line componentsSeparatedByString:@" "] objectAtIndex:0];
        selector = [NSPAdiumsoul selectorForCommand:command];
        if (selector != (SEL)0)
        {
            [self performSelector:[NSPAdiumsoul selectorForCommand:command]
                       withObject:[line substringFromIndex:([command length] + 1)]];
        }
        else
        {
            // if not regognized, let's assume it's a list_users reply
        }
    }
    [array release];

    [connection readInBackgroundAndNotify];
//    [connection readInBackgroundAndNotifyForModes:[NSArray arrayWithObjects: NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, NSDefaultRunLoopMode, nil]];
}

- (void)sendMessageToSocket:(NSString *)message appendNewLine:(BOOL)appendNewLine
{
    AILog(@"[AdiumSoul] Writing to socket: '%@'", message);
    if (appendNewLine)
    {
        message = [message stringByAppendingString:@"\n"];
    }
    NSData* messageData = [NSData dataWithBytes:[message UTF8String] length:[message length]];
    [connection writeData:messageData];
}

#pragma mark -
#pragma mark User-side actions

- (BOOL)sendMessage:(NSString *)message toUser:(NSString *)user
{
    NSString*   encodedMessage = [NSPMessages sendMessage:message toUser:user];

    if (!encodedMessage)
    {
        return NO;
    }
    [self sendMessageToSocket:encodedMessage appendNewLine:YES];
    return YES;
}

- (void)sendTypingEvent:(AITypingState)state toUser:(NSString *)user
{
    if (state == AITyping)
    {
        [self sendMessageToSocket:[NSPMessages startWritingToUser:user] appendNewLine:YES];
    }
    else if (state == AINotTyping)
    {
        [self sendMessageToSocket:[NSPMessages stopWritingToUser:user] appendNewLine:YES];
    }
}

- (void)watchUser:(NSString *)user
{
    [self watchUsers:[NSArray arrayWithObject:user]];
}

- (void)watchUsers:(NSArray *)users
{
    if (users && [users count] > 0)
    {
        [self sendMessageToSocket:[NSPMessages watchUsers:users] appendNewLine:YES];
    }
}

- (void)whoUser:(NSString *)user
{
    [self whoUsers:[NSArray arrayWithObject:user]];
}

- (void)whoUsers:(NSArray *)users
{
    if (users && [users count] > 0)
    {
        [self sendMessageToSocket:[NSPMessages whoUsers:users] appendNewLine:YES];
    }
}

#pragma mark -
#pragma mark Handling commands

+ (SEL)selectorForCommand:(NSString *)command
{
    if (gl_functions == nil)
    {
        gl_functions = [[NSMutableDictionary alloc] init];
        [gl_functions setObject:@"firstReply:"          forKey:@"salut"];
        [gl_functions setObject:@"ping"                 forKey:@"ping"];
        [gl_functions setObject:@"handleReply:"         forKey:@"rep"];
        [gl_functions setObject:@"userCommand:"         forKey:@"user_cmd"];
        [gl_functions setObject:@"recvMessage:"         forKey:@"msg"];
        [gl_functions setObject:@"recvUserInfo:"        forKey:@"who"];
        [gl_functions setObject:@"recvLogin:"           forKey:@"login"];
        [gl_functions setObject:@"recvLogout:"          forKey:@"logout"];
        [gl_functions setObject:@"recvStartTyping:"     forKey:@"typing_start"];
        [gl_functions setObject:@"recvStartTyping:"     forKey:@"dotnetSoul_UserTyping"];
        [gl_functions setObject:@"recvStopTyping:"      forKey:@"typing_end"];
        [gl_functions setObject:@"recvStopTyping:"      forKey:@"dotnetSoul_UserCancelledTyping"];
        [gl_functions setObject:@"recvChangeStatus:"    forKey:@"state"];
        [gl_functions setObject:@"ping"                 forKey:@"new_mail"];
    }
    return NSSelectorFromString([gl_functions objectForKey:command]);
}

- (void)userCommand:(NSString *)message
{
    NSArray*    arr = [message componentsSeparatedByString:@" | "];
    NSArray*    firstPart = [[arr objectAtIndex:0] componentsSeparatedByString:@":"];
    NSArray*    secondPart = [[arr objectAtIndex:1] componentsSeparatedByString:@" "];
    NSString*   socketId = [firstPart objectAtIndex:0];
    NSString*   login = [firstPart objectAtIndex:3];
    NSString*   command = [secondPart objectAtIndex:0];
    SEL         selector;
    
    NSRange range = [login rangeOfString:@"@"];
    login = [login substringToIndex:range.location];
    
    selector = [NSPAdiumsoul selectorForCommand:command];
    if (selector != (SEL)0)
    {
        [self performSelector:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:login, @"login", socketId, @"socketId", secondPart, @"content", nil]];
    }
}

- (void)firstReply:(NSString *)message
{
    NSArray*              arr;
    NSMutableDictionary*  authenticationValues;

    arr = [message componentsSeparatedByString:@" "];
    /*
    * When connecting, we reveive multiple values :
    *  0 - connection socket id
    *  1 - random MD5 hash
    *  2 - client_ip
    *  3 - client port
    *  4 - timestamp from server
    */
    authenticationValues = [NSMutableDictionary dictionary];
    [authenticationValues setObject:[arr objectAtIndex:0] forKey:@"socket"];
    [authenticationValues setObject:[arr objectAtIndex:1] forKey:@"md5hash"];
    [authenticationValues setObject:[arr objectAtIndex:2] forKey:@"clientIp"];
    [authenticationValues setObject:[arr objectAtIndex:3] forKey:@"clientPort"];
    [authenticationValues setObject:[arr objectAtIndex:4] forKey:@"timestamp"];
    [account connectionProgressStep:NETSOUL_STEP_AUTH_AG_REQUEST];
    [self waitReplyToSendMessage:@"authenticate:" withObject:authenticationValues];
    [self sendMessageToSocket:[NSPMessages askAuthentication] appendNewLine:YES];
}

- (void)authenticate:(NSMutableDictionary *)authenticationValues
{
    [authenticationValues setObject:[account UID] forKey:@"login"];
    [authenticationValues setObject:[account password] forKey:@"password"];
    [authenticationValues setObject:[account preferenceForKey:NETSOUL_KEY_LOCATION group:GROUP_ACCOUNT_STATUS] forKey:@"location"];
    [authenticationValues setObject:[account preferenceForKey:NETSOUL_KEY_USERDATA group:GROUP_ACCOUNT_STATUS] forKey:@"userData"];
    [authenticationValues setObject:[account preferenceForKey:NETSOUL_KEY_PROMO group:GROUP_ACCOUNT_STATUS] forKey:@"promo"];
    [account connectionProgressStep:NETSOUL_STEP_AUTHENTICATION];
    [self waitReplyToSendMessage:@"ready" withObject:nil orErrorMessage:@"authenticationFailed"];
    [self sendMessageToSocket:[NSPMessages authentication:authenticationValues
                                            usingKerberos:[[account preferenceForKey:NETSOUL_KEY_KERBEROOS group:GROUP_ACCOUNT_STATUS] boolValue]]
                appendNewLine:YES];
    [authenticationValues release];
}

- (void)authenticationFailed
{
    AILog(@"[AdiumSoul] Authentication failed");
    [self disconnect];
}

- (void)ready
{
    [account didConnect];
    [self sendMessageToSocket:[NSPMessages setState:[account stateFromStatus:[account status]]]
                appendNewLine:YES];
    authenticated = YES;
}

- (void)ping
{
    [self sendMessageToSocket:[NSPMessages ping] appendNewLine:YES];
}

#pragma mark Events

- (void)recvMessage:(NSDictionary *)data
{
    NSString*   message = [[data objectForKey:@"content"] objectAtIndex:1];

    [account receiveMessage:[NSPMessages decode:message] fromUser:[data objectForKey:@"login"]];
}

- (void)recvLogin:(NSDictionary *)data
{
    [account contactIsNowOnline:[data objectForKey:@"login"]];
}

- (void)recvLogout:(NSDictionary *)data
{
    [account contactIsNowOffline:[data objectForKey:@"login"] deleteInformationOnSocket:[data objectForKey:@"socketId"]];
}

- (void)recvChangeStatus:(NSDictionary *)data
{
    NSString*   stateInfos = [[data objectForKey:@"content"] objectAtIndex:1];
    NSRange     range = [stateInfos rangeOfString:@":"];
    NSString*   state = [stateInfos substringToIndex:range.location];
    
    [account contact:[data objectForKey:@"login"] changedState:state onSocket:[data objectForKey:@"socketId"]];
}

- (void)recvStartTyping:(NSDictionary *)data
{
    [account contactStartedTyping:[data objectForKey:@"login"]];
}

- (void)recvStopTyping:(NSDictionary *)data
{
    [account contactStoppedTyping:[data objectForKey:@"login"]];
}

- (void)recvUserInfo:(NSDictionary *)data
{
    if (![[[data objectForKey:@"content"] objectAtIndex:1] isEqualToString:@"rep"])
    {
        [account receivedInfo:[data objectForKey:@"content"] forUser:[[data objectForKey:@"content"] objectAtIndex:2]];
    }
}

#pragma mark -
#pragma mark Handling replies

- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)obj orErrorMessage:(NSString *)error
{
    NSMutableDictionary*  dic;

    dic = [[NSMutableDictionary alloc] init];
    if (message)
    {
        [dic setObject:message forKey:@"selector"];
        if (error)
        {
            [dic setObject:error forKey:@"error"];
        }
        if (obj)
        {
            [dic setObject:obj forKey:@"object"];
        }
    }
    [replyDataPool addObject:dic];
    [dic release];
}

- (void)waitReplyToSendMessage:(NSString *)message withObject:(id)obj
{
    [self waitReplyToSendMessage:message withObject:obj orErrorMessage:nil];
}

- (void)handleReply:(NSString *)message
{
    if ([replyDataPool count] == 0)
        return ;

    NSMutableDictionary* data = [[replyDataPool objectAtIndex:0] retain];
    [replyDataPool removeObjectAtIndex:0];
    // Netsoul replies 2 is everything is OK, interesting isn't it?
    if ([message intValue] == 2)
    {
        SEL selector = NSSelectorFromString([data objectForKey:@"selector"]);
        id obj = [data objectForKey:@"object"];
        if (obj)
            [self performSelector:selector withObject:[obj retain]];
        else
            [self performSelector:selector];
    }
    else
    {
        AILog(@"[AdiumSoul] We got an error, it is mal les errors.");
        SEL errorSelector = NSSelectorFromString([data objectForKey:@"error"]);
        if (errorSelector != (SEL)0)
        {
            [self performSelector:errorSelector];
        }
        else
        {
            NSRange range = [message rangeOfString:@" -- "];
            AILog(@"Command unsuccessful : %@", [message substringFromIndex:range.location + 4]);
        }
    }
    [data release];
}

@end
