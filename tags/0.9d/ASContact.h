//
//  ASContact.h
//  AdiumSoul
//
//  Created by Naixn on 13/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/AIListContact.h>
#import "NSPMessages.h"


#define NETSOUL_CONTACT_STATE @"State"
#define NETSOUL_CONTACT_IP @"IP"
#define NETSOUL_CONTACT_LOCATION @"Location"
#define NETSOUL_CONTACT_USER_DATA @"UserData"

#define NETSOUL_SERVERSTATE_ONLINE @"actif"
#define NETSOUL_SERVERSTATE_IDLE @"idle"
#define NETSOUL_SERVERSTATE_SERVER @"server"
#define NETSOUL_SERVERSTATE_AWAY @"away"

enum
{
    NETSOUL_CONTACTSTATE_AWAY = 0,
    NETSOUL_CONTACTSTATE_IDLE,
    NETSOUL_CONTACTSTATE_ONLINE
};

@interface ASContact : NSObject
{
    NSString*               UID;
    NSString*               mainSocket;
    NSMutableDictionary*    data;
}

- (id)initWithUID:(NSString *)uid;
- (NSString *)UID;

- (void)setInformation:(NSString *)info forKey:(NSString *)key onSocket:(NSString *)socket;
- (void)setInformations:(NSArray *)infos onSocket:(NSString *)socket;
- (NSString *)informations;
- (NSString *)informationsOnSocket:(NSString *)socket;
- (void)removeInformationsOnSocket:(NSString *)socket;
- (BOOL)stillOnline;
- (NSString *)mainSocket;
- (NSString *)mainState;
- (NSString *)mainLocation;

+ (int)contactStateLevel:(NSString *)state;

@end
