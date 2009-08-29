//
//  NSPMessages.m
//  NetSoulProtocol Messages - AdiumSoul
//
//  Created by Naixn on 11/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <openssl/md5.h>
#import "NSPMessages.h"
#import "NSPCUtilities.h"
#include "kerberos.lib.h"
#import "NLXKrb.h"

@implementation NSPMessages

#pragma mark Authentication

+ (NSString *)askAuthentication
{
    return @"auth_ag ext_user none -";
}

+ (NSString *)authentication:(NSDictionary *)connectionValues usingKerberos:(BOOL)useKerberos
{
    if (useKerberos)
        return [NSPMessages kerberosAuthentication:connectionValues];
    return [NSPMessages standardAuthentication:connectionValues];
}

+ (NSString *)kerberosAuthentication:(NSDictionary *)connectionValues
{
    NSString*   returnString;
    NLXKrb*     krb = [[NLXKrb alloc] init];
    
    [krb connectWithLogin:[connectionValues objectForKey:@"login"]
                   passwd:[connectionValues objectForKey:@"password"] 
                  service:NETSOUL_SERVICE_NAME 
                    realm:NETSOUL_REALM];
    NSString* token = [[krb token] retain];
    [krb release];
    
    returnString = [NSString stringWithFormat:@"ext_user_klog %@ MacOSX %@ %@ %@",
                    token,
                    [NSPMessages encode:[connectionValues objectForKey:@"location"]],
                    [NSPMessages encode:[connectionValues objectForKey:@"promo"]],
                    [NSPMessages encode:[connectionValues objectForKey:@"userData"]]
                    ];
    [token release];
    return returnString;
}

//+ (NSString *)kerberosAuthentication:(NSDictionary *)connectionValues
//{
//    NSString*       returnString;
//    gss_ctx_id_t    ctx = GSS_C_NO_CONTEXT;
//
//    Uchar*  tk = retrieve_token((char*)[[connectionValues objectForKey:@"login"] cStringUsingEncoding:NSUTF8StringEncoding],
//                                (char*)[[connectionValues objectForKey:@"password"] cStringUsingEncoding:NSUTF8StringEncoding],
//                                &ctx);
//    NSString* token = [NSString stringWithCString:(char *)tk encoding:NSUTF8StringEncoding];
//    free(tk);
//
//    returnString = [NSString stringWithFormat:@"ext_user_klog %@ MacOSX %@ epitech_2010 %@",
//                    token,
//                    [NSPMessages encode:[connectionValues objectForKey:@"location"]],
//                    [NSPMessages encode:[connectionValues objectForKey:@"userData"]]
//                    ];
//    return returnString;
//}

+ (NSString *)standardAuthentication:(NSDictionary *)connectionValues
{
    NSString*       hash_string;
    NSString*       returnStr;
    NSData*         data;
    char            hashMd5[64];
    unsigned char*  encoding;
    int             i;

    hash_string = [NSString stringWithFormat:@"%@-%@/%@%@",
                   [connectionValues objectForKey:@"md5hash"],
                   [connectionValues objectForKey:@"clientIp"],
                   [connectionValues objectForKey:@"clientPort"],
                   [connectionValues objectForKey:@"password"]];
    data = [hash_string dataUsingEncoding:[NSString defaultCStringEncoding]];

    encoding = MD5([data bytes], [data length], NULL);
    memset(hashMd5, 0, 64);
    for (i = 0; i < 16; i++)
    {
        sprintf(hashMd5, "%s%02x", hashMd5, encoding[i]);
    }
    returnStr = [NSString stringWithFormat:@"ext_user_log %@ %s %@ %@",
                 [connectionValues objectForKey:@"login"],
                 hashMd5,
                 [NSPMessages encode:[connectionValues objectForKey:@"location"]],
                 [NSPMessages encode:[connectionValues objectForKey:@"userData"]]
                 ];
    return returnStr;
}

#pragma mark Messages

+ (NSString *)decode:(NSString *)aMsg
{
//    char*       msg;
//    char*       res;
//    NSString*   message;

//    msg = strdup([[(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aMsg, CFSTR(""), kCFStringEncodingISOLatin1) autorelease] cStringUsingEncoding:NSISOLatin1StringEncoding]);
//    res = eval_carriage_returns(msg);
//    message = [NSString stringWithCString:res encoding:NSISOLatin1StringEncoding];
//    free(msg);
//    return message;
    return [(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aMsg, CFSTR(""), kCFStringEncodingISOLatin1) autorelease];
}

+ (NSString *)encode:(NSString *)aMsg
{
    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aMsg, NULL, (CFStringRef)@"!@#$%^&*()_+=-{[]};:?/.,~", kCFStringEncodingISOLatin1) autorelease];
}

+ (NSString *)sendMessage:(NSString *)message toUser:(NSString *)user
{
    NSString*   encodedMsg = [NSPMessages encode:message];

    if (!encodedMsg)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"user_cmd msg_user %@ msg %@", user, encodedMsg];
}

+ (NSString *)startWritingToUser:(NSString *)user
{
    return [NSString stringWithFormat:@"user_cmd msg_user %@ dotnetSoul_UserTyping null", user];
}

+ (NSString *)stopWritingToUser:(NSString *)user
{
    return [NSString stringWithFormat:@"user_cmd msg_user %@ dotnetSoul_UserCancelledTyping null", user];
}

#pragma mark User-related stuff

+ (NSString *)userListFromArray:(NSArray *)users
{
    if ([users count] == 0)
    {
        return (nil);
    }
    return [users componentsJoinedByString:@","];
}

+ (NSString *)listUsers:(NSArray *)users
{
    NSString*   userList = [NSPMessages userListFromArray:users];

    if (userList == nil)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"list_users {%@}", userList];
}

+ (NSString *)whoUsers:(NSArray *)users
{
    NSString*   userList = [NSPMessages userListFromArray:users];

    if (userList == nil)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"user_cmd who {%@}", userList];
}

+ (NSString *)setState:(NSString *)state
{
    return [NSString stringWithFormat:@"user_cmd state %@:%i", state, time(0)];
}

+ (NSString *)watchUsers:(NSArray *)users
{
    NSString*   userList = [NSPMessages userListFromArray:users];

    if (userList == nil)
        return nil;
    return [NSString stringWithFormat:@"user_cmd watch_log_user {%@}", userList];
}

+ (NSString *)who:(NSString *)user
{
    return [NSString stringWithFormat:@"user_cmd who %@", user];
}

#pragma mark Other stuff

+ (NSString *)exit
{
    return @"exit";
}

+ (NSString *)ping
{
    return @"ping";
}

+ (NSString *)setUserData:(NSString *)data
{
    return [NSString stringWithFormat: @"user_cmd user_data %@", [NSPMessages encode:data]];
}

@end

