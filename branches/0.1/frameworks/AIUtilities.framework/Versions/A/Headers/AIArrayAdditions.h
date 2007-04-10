//
//  AIArrayAdditions.h
//  AIUtilities.framework
//
//  Created by Evan Schoenberg on 2/15/05.
//  Copyright 2005 The Adium Team. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSArray (AIArrayAdditions)
- (BOOL)containsObjectIdenticalTo:(id)obj;
+ (NSArray *)arrayNamed:(NSString *)name forClass:(Class)inClass;
- (NSComparisonResult)compare:(NSArray *)other;
@end

@interface NSMutableArray (ESArrayAdditions)
- (void)addObjectsFromArrayIgnoringDuplicates:(NSArray *)inArray;
- (void)moveObject:(id)object toIndex:(unsigned)newIndex;
- (void)setObject:(id)object atIndex:(unsigned)index;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;//XXX 10.3 compatibility, this is implemented in 10.4
@end
