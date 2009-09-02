//
//  ASContactList.h
//  AdiumSoul
//
//  Created by Naixn on 13/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/AISharedAdium.h>
#import <Adium/AIListContact.h>
#import "ASContact.h"

#define NETSOUL_CONTACT @"NetSoul contact"

@class ASAccount;

@interface ASContactList : NSObject
{
    ASAccount*     account;
    NSMutableArray*         contactList;
    NSMutableDictionary*    adiumsoulContacts;
}

- (id)initWithAccount:(ASAccount *)account;
- (int)loadList;
- (BOOL)saveList;
- (AIListContact *)createContactWithUID:(NSString *)uid inGroup:(NSString *)group addToList:(BOOL)addToList;
- (AIListContact *)createContactWithUID:(NSString *)uid inGroups:(NSMutableArray *)groups addToList:(BOOL)addToList;
- (AIListContact *)contactWithUID:(NSString *)uid;
- (void)moveUsers:(NSArray *)users toGroup:(NSString *)group;
- (void)moveUsers:(NSArray *)users toGroups:(NSSet *)group;
- (void)removeContactWithUID:(NSString *)uid;

- (NSArray *)contacts;

@end
