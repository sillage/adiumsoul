//
//  ASContact.m
//  AdiumSoul
//
//  Created by Naixn on 13/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "ASContact.h"


static NSMutableDictionary* gl_contactStates = nil;

@implementation ASContact

- (id)initWithUID:(NSString *)uid
{
    if (self = [super init])
    {
        data = [[NSMutableDictionary alloc] init];
        UID = [[NSString alloc] initWithString:uid];
        mainSocket = nil;
    }
    return self;
}

- (void) dealloc
{
    [data release];
    [UID release];
    [super dealloc];
}


- (NSString *)UID
{
    return UID;
}

- (void)setInformation:(NSString *)info forKey:(NSString *)key onSocket:(NSString *)socket
{
    NSMutableDictionary*    dic = [data objectForKey:socket];

    if (dic == nil)
    {
        dic = [NSMutableDictionary dictionary];
        [data setObject:dic forKey:socket];
    }
    [dic setObject:info forKey:key];
    mainSocket = nil;
}

- (void)setInformations:(NSArray *)infos onSocket:(NSString *)socket
{
    NSArray*    state = [[infos objectAtIndex:11] componentsSeparatedByString:@":"];

    [self setInformation:[infos objectAtIndex:3] forKey:NETSOUL_CONTACT_IP onSocket:socket];
    [self setInformation:[state objectAtIndex:0] forKey:NETSOUL_CONTACT_STATE onSocket:socket];
    [self setInformation:[NSPMessages decode:[infos objectAtIndex:9]] forKey:NETSOUL_CONTACT_LOCATION onSocket:socket];
    [self setInformation:[NSPMessages decode:[infos objectAtIndex:12]] forKey:NETSOUL_CONTACT_USER_DATA onSocket:socket];
}

- (NSString *)informations
{
    NSMutableString*    ret = nil;
    NSEnumerator*       en = [data keyEnumerator];
    NSString*           key;

    while ((key = [en nextObject]))
    {
        if (ret == nil)
        {
            ret = [NSMutableString stringWithString:[self informationsOnSocket:key]];
        }
        else
        {
            [ret appendFormat:@"\r\r%@", [self informationsOnSocket:key]];
        }
    }
    return ret;
}

- (NSString *)informationsOnSocket:(NSString *)socket
{
    NSMutableString*        ret = nil;
    NSMutableDictionary*    dic = [data objectForKey:socket];
    NSEnumerator*           en = [dic keyEnumerator];
    NSString*               key;

    while ((key = [en nextObject]))
    {
        if (ret == nil)
        {
            ret = [NSMutableString stringWithFormat:@"%@: %@", key, [dic objectForKey:key]];
        }
        else
        {
            [ret appendFormat:@"\r%@: %@", key, [dic objectForKey:key]];
        }
    }
    return ret;
}

- (void)removeInformationsOnSocket:(NSString *)socket
{
    [data removeObjectForKey:socket];
    mainSocket = nil;
}

- (BOOL)stillOnline
{
    return [data count];
}

- (NSString *)mainSocket
{
    if (mainSocket == nil)
    {
        NSEnumerator*   en = [data keyEnumerator];
        NSString*       socket;
        int             higherStateLevel = -1;
        int             tmpLevel;
        
        while (socket = [en nextObject])
        {
            tmpLevel = [ASContact contactStateLevel:[[data objectForKey:socket] objectForKey:NETSOUL_CONTACT_STATE]];
            if (tmpLevel >= higherStateLevel)
            {
                higherStateLevel = tmpLevel;
                mainSocket = socket;
            }
        }
    }
    return mainSocket;
}

- (NSString *)mainState
{
    return [[data objectForKey:[self mainSocket]] objectForKey:NETSOUL_CONTACT_STATE];
}

- (NSString *)mainLocation
{
    return [[data objectForKey:[self mainSocket]] objectForKey:NETSOUL_CONTACT_LOCATION];
}

+ (int)contactStateLevel:(NSString *)state
{
    if (gl_contactStates == nil)
    {
        gl_contactStates = [[NSMutableDictionary alloc] init];
        [gl_contactStates setObject:[NSNumber numberWithInt:NETSOUL_CONTACTSTATE_ONLINE]    forKey:NETSOUL_SERVERSTATE_ONLINE];
        [gl_contactStates setObject:[NSNumber numberWithInt:NETSOUL_CONTACTSTATE_IDLE]      forKey:NETSOUL_SERVERSTATE_IDLE];
        [gl_contactStates setObject:[NSNumber numberWithInt:NETSOUL_CONTACTSTATE_AWAY]      forKey:NETSOUL_SERVERSTATE_SERVER];
        [gl_contactStates setObject:[NSNumber numberWithInt:NETSOUL_CONTACTSTATE_AWAY]      forKey:NETSOUL_SERVERSTATE_AWAY];
    }
    return [[gl_contactStates objectForKey:state] intValue];
}

@end
