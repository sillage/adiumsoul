//
//  AIListObjectMenu.h
//  Adium
//
//  Created by Adam Iser on 5/31/05.
//  Copyright 2006 The Adium Team. All rights reserved.
//

#import <Adium/AIObject.h>

@class AIListObject;

@interface AIAbstractListObjectMenu : AIObject {
	NSMutableArray	*menuItems;
	NSMenu			*menu;
}

- (NSArray *)menuItems;
- (NSMenu *)menu;
- (NSMenuItem *)menuItemWithRepresentedObject:(id)object;
- (void)rebuildMenu;

//For Subclassers
- (NSArray *)buildMenuItems;
- (NSImage *)imageForListObject:(AIListObject *)listObject;

@end
