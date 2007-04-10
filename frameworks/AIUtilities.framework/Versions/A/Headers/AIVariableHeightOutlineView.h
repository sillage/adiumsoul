//
//  AIVariableHeightOutlineView.h
//  AIUtilities.framework
//
//  Created by Evan Schoenberg on 11/25/04.
//  Copyright (c) 2004-2005 The Adium Team. All rights reserved.
//

#import "AIAlternatingRowOutlineView.h"

/*!
 * @protocol AIVariableHeightOutlineViewDataSource
 * @brief Required protocol for the  <tt>AIVariableHeightOutlineView</tt> data source.
 *
 * The <tt>AIVariableHeightOutlineView</tt> data source must implement the methods in the informal protocol AIVariableHeightOutlineViewDataSource.  It is informal, so the data source should not be declared as actually conforming to it, it should simply implement its method(s).
 */
@interface NSObject (AIVariableHeightOutlineViewDataSource)
/*!
 * outlineView:heightForItem:atRow:
 * @brief Requests the height needed to display <b>item</b> from the data source
 *
 * The data source should return the height required to display <b>item</b> at row <b>row</b>. This will be the height of the row.
 * @return An integer height (which must be greater than 0) at which to display <b>row</b>.
 */
- (int)outlineView:(NSOutlineView *)inOutlineView heightForItem:(id)item atRow:(int)row;
@end

/*!
 * @class AIVariableHeightOutlineView
 * @brief An outlineView which supports variable heights on a per-row basis.
 *
 * This <tt>AIAlternatingRowOutlineView</tt> subclass allows each row to have a different height as determined by the data source. Note that the delegate <b>must</b> implement the method(s) described in <tt>AIVariableHeightOutlineViewDataSource</tt>. 
 */
@interface AIVariableHeightOutlineView : AIAlternatingRowOutlineView {
	int 	*rowHeightCache;
	int 	*rowOriginCache;
	int		totalHeight;
	int 	cacheSize;
	int		entriesInCache;

	BOOL	drawHighlightOnlyWhenMain;
	BOOL	drawsSelectedRowHighlight;
}

/*!
 * @brief Returns the total height needed to display all rows of the outline view
 *
 * Returns the total height needed to display all rows of the outline view
 * @return The total required height
 */
- (int)totalHeight;

/*!
 * @brief Set if the selection highlight should only be drawn when the outlineView is the main (active) view.
 *
 * Set to YES if the selection highlight should only be drawn when the outlineView is the main (active) view. The default value is NO.
 * @param inFlag YES if the highlight should only be drawn when main.
 */
- (void)setDrawHighlightOnlyWhenMain:(BOOL)inFlag;
/*!
 * @brief Return if the highlight is only drawn when the outlineView is the main view.
 *
 * Return if the highlight is only drawn when the outlineView is the main view.
 * @return YES if the highlight is only be drawn when main.
 */
- (BOOL)drawHighlightOnlyWhenMain;

/*!
 * @brief Set if the selection highlight should be drawn at all.
 *
 * Set to YES if the selection highlight should be drawn; no if it should be suppressed.  The default value is YES.
 * @param inFlag YES if the highlight be drawn; NO if it should not.
 */
- (void)setDrawsSelectedRowHighlight:(BOOL)inFlag;

/*!
 * @brief Cell corresponding to table column.
 *
 * Mostly useful for subclassing; by default, this is simple [tableColumn dataCell]
 * @return NSCell object corresponding to the given table column.
 */
- (id)cellForTableColumn:(NSTableColumn *)tableColumn item:(id)item;

@end

@interface AIVariableHeightOutlineView (AIVariableHeightOutlineViewAndSubclasses)
- (void)resetRowHeightCache;
- (void)updateRowHeightCache;
@end

@interface NSObject (AIVariableHeightGridSupport)
- (BOOL)drawGridBehindCell;
@end

@interface NSCell (UndocumentedHighlightDrawing)
- (void)_drawHighlightWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
@end

