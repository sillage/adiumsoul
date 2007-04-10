//
//  AICustomTabDragWindow.h
//  Adium
//
//  Created by Adam Iser on Sat Mar 06 2004.
//  Copyright (c) 2004-2005 The Adium Team. All rights reserved.
//

@class AIFloater, AICustomTabsView, AICustomTabCell;

@interface AICustomTabDragWindow : NSObject {
	NSImage				*floaterTabImage;
	NSImage				*floaterWindowImage;
	AIFloater			*dragTabFloater;
	AIFloater			*dragWindowFloater;
	BOOL				fullWindow;
	
	BOOL				useFancyAnimations;
}
@end

@interface AICustomTabDragWindow (PRIVATE_AICustomTabDraggingOnly)
+ (AICustomTabDragWindow *)dragWindowForCustomTabView:(AICustomTabsView *)inTabView cell:(AICustomTabCell *)inTabCell transparent:(BOOL)transparent;
- (void)setDisplayingFullWindow:(BOOL)fullWindow animate:(BOOL)animate;
- (void)moveToPoint:(NSPoint)inPoint;
- (void)closeWindow;
- (NSImage *)dragImage;
@end
