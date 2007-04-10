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

#import <Adium/AIAbstractListController.h>
#import <Adium/AIListCell.h>
//#import <Adium/AIListLayoutWindowController.h>
#import <AIUtilities/AIImageAdditions.h>

//User Icon
#define USER_ICON_LEFT_PAD			2
#define USER_ICON_RIGHT_PAD			2

//Status icon
#define STATUS_ICON_LEFT_PAD		2
#define STATUS_ICON_RIGHT_PAD		2

//Service icon
#define SERVICE_ICON_LEFT_PAD		2
#define SERVICE_ICON_RIGHT_PAD		2

@interface AIListContactCell : AIListCell {
	BOOL				userIconVisible;
	BOOL				extendedStatusVisible;
	BOOL				statusIconsVisible;
	BOOL				serviceIconsVisible;
	NSSize				userIconSize;
	int					userIconRoundingRadius;
	int					statusFontHeight;	
	
	BOOL				backgroundColorIsStatus;
	BOOL				backgroundColorIsEvents;
	BOOL				shouldUseContactTextColors;

	LIST_POSITION		userIconPosition;
	LIST_POSITION		statusIconPosition;
	LIST_POSITION		serviceIconPosition;
	BOOL				extendedStatusIsBelowName;
	
	float				backgroundOpacity;

	NSFont				*statusFont;
	NSColor				*statusColor;

	NSDictionary		*_statusAttributes;
	NSMutableDictionary	*_statusAttributesInverted;	
}

//Status Text
- (void)setStatusFont:(NSFont *)inFont;
- (NSFont *)statusFont;
- (NSDictionary *)statusAttributes;
- (NSDictionary *)statusAttributesInverted;
- (void)setTextAlignment:(NSTextAlignment)inAlignment;
- (void)setStatusColor:(NSColor *)inColor;
- (NSColor *)statusColor;

//Display options
- (void)setUserIconVisible:(BOOL)inShowIcon;
- (BOOL)userIconVisible;
- (void)setUserIconSize:(int)inSize;
- (int)userIconSize;
- (void)setExtendedStatusVisible:(BOOL)inShowStatus;
- (BOOL)extendedStatusVisible;
- (void)setStatusIconsVisible:(BOOL)inShowStatus;
- (BOOL)statusIconsVisible;
- (void)setServiceIconsVisible:(BOOL)inShowService;
- (BOOL)serviceIconsVisible;
- (void)setExtendedStatusIsBelowName:(BOOL)inBelowName;
- (void)setUserIconPosition:(LIST_POSITION)inPosition;
- (void)setStatusIconPosition:(LIST_POSITION)inPosition;
- (void)setServiceIconPosition:(LIST_POSITION)inPosition;
- (void)setBackgroundOpacity:(float)inOpacity;
- (float)backgroundOpacity;
- (void)setBackgroundColorIsStatus:(BOOL)isStatus;
- (void)setBackgroundColorIsEvents:(BOOL)isEvents;
- (void)setShouldUseContactTextColors:(BOOL)flag;

//Drawing
- (void)drawContentWithFrame:(NSRect)rect;
- (void)drawBackgroundWithFrame:(NSRect)rect;
- (NSRect)drawUserIconInRect:(NSRect)inRect position:(IMAGE_POSITION)position;
- (NSRect)drawStatusIconInRect:(NSRect)rect position:(IMAGE_POSITION)position;
- (NSRect)drawServiceIconInRect:(NSRect)rect position:(IMAGE_POSITION)position;
- (NSRect)drawUserExtendedStatusInRect:(NSRect)rect drawUnder:(BOOL)drawUnder;
- (NSColor *)labelColor;
- (NSColor *)textColor;
- (NSImage *)userIconImage;
- (NSImage *)statusImage;
- (NSImage *)serviceImage;
//- (BOOL)drawStatusBelowLabelInRect:(NSRect)rect;
- (float)imageOpacityForDrawing;

@end
