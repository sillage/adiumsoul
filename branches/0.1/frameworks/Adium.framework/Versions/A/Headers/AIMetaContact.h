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

#import <Adium/AIListContact.h>

#define	KEY_PREFERRED_DESTINATION_CONTACT	@"Preferred Destination Contact"

@interface AIMetaContact : AIListContact <AIContainingObject> {
	NSNumber				*objectID;
	
	NSMutableDictionary		*statusCacheDict;	//Cache of the status of our contained objects
	
	AIListContact			*_preferredContact;
	NSArray					*_listContacts;
	NSArray					*_listContactsIncludingOfflineAccounts;
	
	BOOL					containsOnlyOneUniqueContact;
	BOOL					containsOnlyOneService;

	NSMutableArray			*containedObjects;			//Manually ordered array of contents
	BOOL					containedObjectsNeedsSort;
	BOOL					delayContainedObjectSorting;
	BOOL					saveGroupingChanges;
	
    BOOL					expanded;			//Exanded/Collapsed state of this object
	
	float					largestOrder;
	float					smallestOrder;
}

//The objectID is unique to a meta contact and is used as the UID for purposes of AIListContact inheritance
- (id)initWithObjectID:(NSNumber *)objectID;
- (NSNumber *)objectID;
+ (NSString *)internalObjectIDFromObjectID:(NSNumber *)inObjectID;

- (AIListContact *)preferredContact;
- (AIListContact *)preferredContactWithService:(AIService *)inService;

- (void)remoteGroupingOfContainedObject:(AIListObject *)inListObject changedTo:(NSString *)inRemoteGroupName;

//YES if the metaContact has only one UID/serviceID within it - for example, three different accounts' AIListContacts for a particular screen name
- (BOOL)containsOnlyOneUniqueContact;

//Similarly, YES if the metaContact has only one serviceID within it.
- (BOOL)containsOnlyOneService;
- (unsigned)uniqueContainedObjectsCount;
- (AIListObject *)uniqueObjectAtIndex:(int)inIndex;

- (NSDictionary *)dictionaryOfServiceClassesAndListContacts;
- (NSArray *)servicesOfContainedObjects;

- (void)setExpanded:(BOOL)inExpanded;
- (BOOL)isExpanded;

// (PRIVATE: For contact controller ONLY)
- (BOOL)addObject:(AIListObject *)inObject;
- (void)removeObject:(AIListObject *)inObject;

//A flat array of AIListContacts each with a different internalObjectID
- (NSArray *)listContacts;
- (NSArray *)listContactsIncludingOfflineAccounts;

//Delay sorting the contained object list; this should only be used by the contactController. Be sure to set it back to YES when operations are done
- (void)setDelayContainedObjectSorting:(BOOL)flag;


@end
