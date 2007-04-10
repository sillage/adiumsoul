/*-------------------------------------------------------------------------------------------------------*\
| Adium, Copyright (C) 2001-2005, Adam Iser  (adamiser@mac.com | http://www.adiumx.com)                   |
\---------------------------------------------------------------------------------------------------------/
 | This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 | General Public License as published by the Free Software Foundation; either version 2 of the License,
 | or (at your option) any later version.
 |
 | This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 | the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 | Public License for more details.
 |
 | You should have received a copy of the GNU General Public License along with this program; if not,
 | write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 \------------------------------------------------------------------------------------------------------ */

@class AICustomTabsView;

@protocol AICustomTabViewItem;

@interface AICustomTabCell : NSCell {
    BOOL								selected;
    BOOL								highlighted;
    BOOL								allowsInactiveTabClosing;
    
    BOOL								trackingClose;
    BOOL								hoveringClose;
    
    NSTrackingRectTag					trackingTag;
	NSToolTipTag						tooltipTag;
    NSDictionary						*userData;
    NSTrackingRectTag					closeTrackingTag;
    NSDictionary						*closeUserData;
    
	NSAttributedString					*attributedLabel;
    NSTabViewItem<AICustomTabViewItem>	*tabViewItem;
    NSRect								frame;
	
	AICustomTabsView					*view;
}

@end

@interface AICustomTabCell (PRIVATE_AICustomTabsViewOnly)
+ (id)customTabForTabViewItem:(NSTabViewItem<AICustomTabViewItem> *)inTabViewItem customTabsView:(AICustomTabsView *)inView;
- (void)setAllowsInactiveTabClosing:(BOOL)inValue;
- (BOOL)allowsInactiveTabClosing;
- (void)setSelected:(BOOL)inSelected;
- (BOOL)isSelected;
- (void)setHoveringClose:(BOOL)hovering;
- (void)setFrame:(NSRect)inFrame;
- (NSRect)frame;
- (NSSize)size;
- (NSComparisonResult)compareWidth:(AICustomTabCell *)tab;
- (NSTabViewItem<AICustomTabViewItem> *)tabViewItem;
- (void)drawWithFrame:(NSRect)rect inView:(NSView *)controlView ignoreSelection:(BOOL)ignoreSelection;
- (void)addTrackingRectsWithFrame:(NSRect)trackRect cursorLocation:(NSPoint)cursorLocation;
- (BOOL)willTrackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView;
- (void)removeTrackingRects;
- (NSAttributedString *)attributedLabel;
@end
