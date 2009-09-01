//
//  ASContactList.m
//  AdiumSoul
//
//  Created by Naixn on 13/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "ASContactList.h"
#import "ASAccount.h"
#import <Adium/AIContactControllerProtocol.h>
#import <Adium/AILoginControllerProtocol.h>


@implementation ASContactList

- (id)initWithAccount:(ASAccount *)adiumsoulAccount
{
    if (self = [super init])
    {
        NSString*   userDir = [[adium loginController] userDirectory];
        NSString*   accountName = [adiumsoulAccount explicitFormattedUID];
        NSString*   netsoulContactsDir = [userDir stringByAppendingPathComponent:@"Netsoul Contacts"];
        NSString*   netsoulContactsFile = [[netsoulContactsDir stringByAppendingPathComponent:accountName] stringByAppendingPathExtension:@"plist"];

        NSMutableArray* tmpContactList;
        account = [adiumsoulAccount retain];
        adiumsoulContacts = [[NSMutableDictionary alloc] init];
        AILog(@"[AdiumSoul] Contact file : %@", netsoulContactsFile);
        tmpContactList = [NSMutableArray arrayWithContentsOfFile:netsoulContactsFile];
        if (!tmpContactList)
        {
            contactList = [[NSMutableArray alloc] init];
        }
        else
        {
            contactList = [[NSMutableArray alloc] initWithArray:tmpContactList];
        }
    }
    return self;
}

- (void)dealloc
{
    [account release];
    [contactList release];
    [adiumsoulContacts release];
    [super dealloc];
}

- (int)loadList
{
    NSArray*                contactListCopy = [contactList copy];
    NSEnumerator*           en = [contactListCopy objectEnumerator];
    NSMutableDictionary*    dic;
    id                      next;
    int                     i = 0;
    BOOL                    needSave = NO;
    
    while ((next = [en nextObject]))
    {
        if ([next isKindOfClass:[NSString class]]) /* Import list from AdiumSoul 0.8x */
        {
            dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithString:next], @"login",
                                                                    [NSMutableArray arrayWithObject:@"NetSoul"], @"groups",
                                                                    nil];
            [contactList removeObject:next];
            [contactList addObject:dic];
            needSave = YES;
        }
        else
        {
            dic = next;
            if ([dic objectForKey:@"group"]) /* Import list from AdiumSoul 0.9x */
            {
                [dic setObject:[NSMutableArray arrayWithObject:[dic objectForKey:@"group"]] forKey:@"groups"];
                [dic removeObjectForKey:@"group"];
            }
        }
        [self createContactWithUID:[dic objectForKey:@"login"] inGroups:[dic objectForKey:@"groups"] addToList:NO];
        i++;
    }
    if (needSave)
    {
        [self saveList];
    }
    [contactListCopy release];
    return i;
}

- (BOOL)saveList
{
    NSString*       userDir = [[adium loginController] userDirectory];
    NSString*       accountName = [account explicitFormattedUID];
    NSString*       netsoulContactsDir = [userDir stringByAppendingPathComponent:@"Netsoul Contacts"];
    NSString*       netsoulContactsFile = [[netsoulContactsDir stringByAppendingPathComponent:accountName] stringByAppendingPathExtension:@"plist"];
    NSFileManager*  fileManager = [NSFileManager defaultManager];
    BOOL            isDirectory = NO;

    if (![fileManager fileExistsAtPath:netsoulContactsDir isDirectory:&isDirectory])
    {
        [fileManager createDirectoryAtPath:netsoulContactsDir attributes:nil];
    }
    else if (!isDirectory)
    {
        return NO;
    }
    return [contactList writeToFile:netsoulContactsFile atomically:YES];
}

- (AIListContact *)createContactWithUID:(NSString *)uid inGroup:(NSString *)group addToList:(BOOL)addToList
{
    AIListContact* contact;
    
    contact = [[adium contactController] contactWithService:[account service] account:account UID:uid];
    if ([[contact remoteGroupNames] count] == 0)
    {
        if (group == nil)
        {
            [contact addRemoteGroupName:@"NetSoul"];
        }
        else
        {
            [contact addRemoteGroupName:group];
        }
    }
    ASContact* adiumsoulContact = [contact valueForProperty:NETSOUL_CONTACT];
    if (adiumsoulContact)
    {
        [contact setValue:nil forProperty:NETSOUL_CONTACT notify:NO];
    }
    [contact setValue:[[[ASContact alloc] initWithUID:uid] autorelease] forProperty:NETSOUL_CONTACT notify:NO];
    if (addToList)
    {
        [adiumsoulContacts setObject:[NSMutableDictionary dictionary] forKey:uid];
        [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:uid, @"login", group, @"group", nil]];
        [self saveList];
    }
    return contact;
}

- (AIListContact *)createContactWithUID:(NSString *)uid inGroups:(NSMutableArray *)groups addToList:(BOOL)addToList
{
    AIListContact* contact;
    
    contact = [[adium contactController] contactWithService:[account service] account:account UID:uid];
    if ([[contact remoteGroupNames] count] == 0)
    {
        if ([groups count] == 0)
        {
            [contact addRemoteGroupName:@"NetSoul"];
        }
        else
        {
            for (NSString* group in groups)
            {
                [contact addRemoteGroupName:group];
            }
        }
    }
    ASContact* adiumsoulContact = [contact valueForProperty:NETSOUL_CONTACT];
    if (adiumsoulContact)
    {
        [contact setValue:nil forProperty:NETSOUL_CONTACT notify:NO];
    }
    [contact setValue:[[[ASContact alloc] initWithUID:uid] autorelease] forProperty:NETSOUL_CONTACT notify:NO];
    if (addToList)
    {
        [adiumsoulContacts setObject:[NSMutableDictionary dictionary] forKey:uid];
        [contactList addObject:[NSDictionary dictionaryWithObjectsAndKeys:uid, @"login", groups, @"groups", nil]];
        [self saveList];
    }
    return contact;
}

- (AIListContact *)contactWithUID:(NSString *)uid
{
    return [[adium contactController] contactWithService:[account service] account:account UID:uid];
}

- (void)moveUsers:(NSArray *)users toGroup:(NSString *)group
{
    NSEnumerator*           listEnum;
    NSEnumerator*           contactEnum;
    NSMutableDictionary*    dic;
    AIListContact*          contact;
    
    listEnum = [contactList objectEnumerator];
    while ((dic = [listEnum nextObject]))
    {
        contactEnum = [users objectEnumerator];
        while ((contact = [contactEnum nextObject]))
        {
            if ([[contact UID] isEqualToString:[dic objectForKey:@"login"]])
            {
                [dic setObject:group forKey:@"group"];
            }
        }
    }
    [self saveList];
}

- (void)moveUsers:(NSArray *)users toGroups:(NSSet *)groups
{
    NSEnumerator*           listEnum;
    NSEnumerator*           contactEnum;
    NSMutableDictionary*    dic;
    AIListContact*          contact;
    
    listEnum = [contactList objectEnumerator];
    while ((dic = [listEnum nextObject]))
    {
        contactEnum = [users objectEnumerator];
        while ((contact = [contactEnum nextObject]))
        {
            if ([[contact UID] isEqualToString:[dic objectForKey:@"login"]])
            {
                [dic setObject:[[[groups allObjects] mutableCopy] autorelease] forKey:@"groups"];
            }
        }
    }
    [self saveList];
}

- (void)removeContactWithUID:(NSString *)uid
{
    NSEnumerator*   en;
    NSDictionary*   dic;
    NSDictionary*   toRemove = nil;
    AIListContact*  contact;

    [adiumsoulContacts removeObjectForKey:uid];
    en = [contactList objectEnumerator];
    while ((dic = [en nextObject]))
    {
        if ([[dic objectForKey:@"login"] isEqualToString:uid])
        {
            toRemove = dic;
            break;
        }
    }
    if (toRemove)
    {
        [contactList removeObject:toRemove];
    }
    contact = [[adium contactController] contactWithService:[account service] account:account UID:uid];
    [contact setValue:nil forProperty:NETSOUL_CONTACT notify:NO];
    [contact addRemoteGroupName:nil];
    [self saveList];
}

- (NSArray *)contacts
{
    NSMutableArray* contactArray = [NSMutableArray array];
    NSEnumerator*   en = [contactList objectEnumerator];
    NSDictionary*   dic;

    while ((dic = [en nextObject]))
    {
        [contactArray addObject:[dic objectForKey:@"login"]];
    }
    return contactArray;
}

@end
