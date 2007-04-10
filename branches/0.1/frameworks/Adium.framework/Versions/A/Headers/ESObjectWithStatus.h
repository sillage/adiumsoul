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

#import <Adium/AIObject.h>

@class AIMutableOwnerArray;

typedef enum {
	NotifyNever = -9999,
	NotifyLater = NO,   /* 0 */
	NotifyNow = YES		/* 1 */
} NotifyTiming;
	
@interface ESObjectWithStatus : AIObject {
    NSMutableDictionary		*statusDictionary;
    NSMutableSet			*changedStatusKeys;		//Status keys that have changed since the last notification
	
	NSMutableDictionary		*displayDictionary;		//A dictionary of values affecting this object's display
}

//Setting status objects
- (void)setStatusObject:(id)value forKey:(NSString *)key notify:(NotifyTiming)notify;
- (void)setStatusObject:(id)value forKey:(NSString *)key afterDelay:(NSTimeInterval)delay;
- (void)notifyOfChangedStatusSilently:(BOOL)silent;

//Getting status objects
- (NSEnumerator *)statusKeyEnumerator;
- (id)statusObjectForKey:(NSString *)key;
- (int)integerStatusObjectForKey:(NSString *)key;
- (NSDate *)earliestDateStatusObjectForKey:(NSString *)key;
- (NSNumber *)numberStatusObjectForKey:(NSString *)key;
- (NSString *)stringFromAttributedStringStatusObjectForKey:(NSString *)key;

- (id)statusObjectForKey:(NSString *)key fromAnyContainedObject:(BOOL)fromAnyContainedObject;
- (NSDate *)earliestDateStatusObjectForKey:(NSString *)key fromAnyContainedObject:(BOOL)fromAnyContainedObject;
- (int)integerStatusObjectForKey:(NSString *)key fromAnyContainedObject:(BOOL)fromAnyContainedObject;
- (NSNumber *)numberStatusObjectForKey:(NSString *)key fromAnyContainedObject:(BOOL)fromAnyContainedObject;
- (NSString *)stringFromAttributedStringStatusObjectForKey:(NSString *)key fromAnyContainedObject:(BOOL)fromAnyContainedObject;

//Status objects: Specifically for subclasses
- (void)object:(id)inObject didSetStatusObject:(id)value forKey:(NSString *)key notify:(NotifyTiming)notify;
- (void)didModifyStatusKeys:(NSSet *)keys silent:(BOOL)silent;
- (void)didNotifyOfChangedStatusSilently:(BOOL)silent;

//Display array
- (AIMutableOwnerArray *)displayArrayForKey:(NSString *)inKey;
- (AIMutableOwnerArray *)displayArrayForKey:(NSString *)inKey create:(BOOL)create;
- (id)displayArrayObjectForKey:(NSString *)inKey;

//Name
- (NSString *)displayName;

//Mutable owner array delegate method
- (void)mutableOwnerArray:(AIMutableOwnerArray *)inArray didSetObject:(id)anObject withOwner:(id)inOwner priorityLevel:(float)priority;

@end
