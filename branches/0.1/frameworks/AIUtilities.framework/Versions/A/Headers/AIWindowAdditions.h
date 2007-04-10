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

@interface NSWindow (AIWindowAdditions)
- (void)setContentSize:(NSSize)aSize display:(BOOL)displayFlag animate:(BOOL)animateFlag;
- (BOOL)isTextured;
-(void)setIgnoresExpose:(BOOL)flag;
- (BOOL)isBorderless;
- (void)betterCenter;
- (float)toolbarHeight;

- (NSResponder *)earliestResponderWhichRespondsToSelector:(SEL)selector andIsNotOfClass:(Class)classToAvoid;
- (NSResponder *)earliestResponderOfClass:(Class)targetClass;
@end

// The following code is Copyright (C) 2003, 2004 Richard J Wareham <richwareham@users.sourceforge.net>,
// distributed under the GNU General Public License (see above).

/* These functions all return a status code. Typical CoreGraphics replies are:
kCGErrorSuccess = 0,
kCGErrorFirst = 1000,
kCGErrorFailure = kCGErrorFirst,
kCGErrorIllegalArgument = 1001,
kCGErrorInvalidConnection = 1002,
*/

// Internal CoreGraphics typedefs

typedef UInt32 WindowTags;
typedef void  *CGSWindow;
typedef void  *CGSConnection;
typedef int		CGSValue;

//// CONSTANTS ////

/* Window ordering mode. */
typedef enum _CGSWindowOrderingMode {
    kCGSOrderAbove                =  1, // Window is ordered above target.
    kCGSOrderBelow                = -1, // Window is ordered below target.
    kCGSOrderOut                  =  0  // Window is removed from the on-screen window list.
} CGSWindowOrderingMode;

// Internal CoreGraphics functions.

/* Retrieve the workspace number associated with the workspace currently
* being shown.
*
* cid -- Current connection.
* workspace -- Pointer to int value to be set to workspace number.
*/
extern OSStatus CGSGetWorkspace(const CGSConnection cid, int *workspace);

/* Retrieve workspace number associated with the workspace a particular window
* resides on.
*
* cid -- Current connection.
* wid -- Window number of window to examine.
* workspace -- Pointer to int value to be set to workspace number.
*/
extern OSStatus CGSGetWindowWorkspace(const CGSConnection cid, const CGSWindow wid, int *workspace);

/* Show workspace associated with a workspace number.
*
* cid -- Current connection.
* workspace -- Workspace number.
*/
extern OSStatus CGSSetWorkspace(const CGSConnection cid, int workspace);

typedef enum {
    CGSNone = 0,	// No transition effect.
    CGSFade,		// Cross-fade.
    CGSZoom,		// Zoom/fade towards us.
    CGSReveal,		// Reveal new desktop under old.
    CGSSlide,		// Slide old out and new in.
    CGSWarpFade,	// Warp old and fade out revealing new.
    CGSSwap,		// Swap desktops over graphically.
    CGSCube,		// The well-known cube effect.
    CGSWarpSwitch   // Warp old, switch and un-warp.
} CGSTransitionType;

typedef enum {
    CGSDown,				// Old desktop moves down.
    CGSLeft,				// Old desktop moves left.
    CGSRight,				// Old desktop moves right.
    CGSInRight,				// CGSSwap: Old desktop moves into screen, 
							//			new comes from right.
    CGSBottomLeft = 5,		// CGSSwap: Old desktop moves to bl,
							//			new comes from tr.
    CGSBottomRight,			// Old desktop to br, New from tl.
    CGSDownTopRight,		// CGSSwap: Old desktop moves down, new from tr.
    CGSUp,					// Old desktop moves up.
    CGSTopLeft,				// Old desktop moves tl.
    
    CGSTopRight,			// CGSSwap: old to tr. new from bl.
    CGSUpBottomRight,		// CGSSwap: old desktop up, new from br.
    CGSInBottom,			// CGSSwap: old in, new from bottom.
    CGSLeftBottomRight,		// CGSSwap: old one moves left, new from br.
    CGSRightBottomLeft,		// CGSSwap: old one moves right, new from bl.
    CGSInBottomRight,		// CGSSwap: onl one in, new from br.
    CGSInOut				// CGSSwap: old in, new out.
} CGSTransitionOption;

extern OSStatus CGSSetWorkspaceWithTransition(const CGSConnection cid,
					      int workspaceNumber, CGSTransitionType transition, CGSTransitionOption subtype, 
					      float time);

/* Get the default connection for the current process. */
extern CGSConnection _CGSDefaultConnection(void);

// thirtyTwo must = 32 for some reason. tags is pointer to 
//array ot ints (size 2?). First entry holds window tags.
// 0x0800 is sticky bit.
OSStatus      CGSSetWindowTags(  CGSConnection cgsID, CGSWindow theWindow, SInt32 *theTags, SInt32 tagSize);
OSStatus      CGSGetWindowTags(  CGSConnection cgsID, CGSWindow theWindow, SInt32 *theTags, SInt32 tagSize);
OSStatus      CGSClearWindowTags(CGSConnection cgsID, CGSWindow theWindow, SInt32 *theTags, SInt32 tagSize);

// Get on-screen window counts and lists.
extern OSStatus CGSGetOnScreenWindowCount(const CGSConnection cid, CGSConnection targetCID, int* outCount); 
extern OSStatus CGSGetOnScreenWindowList(const CGSConnection cid, CGSConnection targetCID, 
					 int count, int* list, int* outCount);

// Per-workspace window counts and lists.
extern OSStatus CGSGetWorkspaceWindowCount(const CGSConnection cid, int workspaceNumber, int *outCount);
extern OSStatus CGSGetWorkspaceWindowList(const CGSConnection cid, int workspaceNumber, int count, 
					  int* list, int* outCount);

// Gets the level of a window
extern OSStatus CGSGetWindowLevel(const CGSConnection cid, CGSWindow wid, 
				  int *level);

// Window ordering
extern OSStatus CGSOrderWindow(const CGSConnection cid, const CGSWindow wid, 
			       CGSWindowOrderingMode place, CGSWindow relativeToWindowID /* can be NULL */);	

// Gets the screen rect for a window.
extern OSStatus CGSGetScreenRectForWindow(const CGSConnection cid, CGSWindow wid, 
					  CGRect *outRect);

// Window appearance/position
extern OSStatus CGSSetWindowAlpha(const CGSConnection cid, const CGSWindow wid, float alpha);
extern OSStatus CGSMoveWindow(const CGSConnection cid, const CGSWindow wid, CGPoint *point);

// extern OSStatus CGSConnectionGetPID(const CGSConnection cid, pid_t *pid, CGSConnection b);

extern OSStatus CGSGetWindowProperty(const CGSConnection cid, CGSWindow wid, CGSValue key,
				     CGSValue *outValue);

//extern OSStatus CGSWindowAddRectToDirtyShape(const CGSConnection cid, const CGSWindow wid, CGRect *rect);
extern OSStatus CGSUncoverWindow(const CGSConnection cid, const CGSWindow wid);
extern OSStatus CGSFlushWindow(const CGSConnection cid, const CGSWindow wid, int unknown /* 0 works */ );

extern OSStatus CGSGetWindowOwner(const CGSConnection cid, const CGSWindow wid, CGSConnection *ownerCid);
extern OSStatus CGSConnectionGetPID(const CGSConnection cid, pid_t *pid, const CGSConnection ownerCid);

// Values
extern CGSValue CGSCreateCStringNoCopy(const char *str);
extern char* CGSCStringValue(CGSValue string);

