/*
 *  AIInterfaceControllerProtocol.h
 *  Adium
 *
 *  Created by Evan Schoenberg on 7/31/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#import <Adium/AIControllerProtocol.h>

#define Interface_ContactSelectionChanged			@"Interface_ContactSelectionChanged"
#define Interface_SendEnteredMessage				@"Interface_SendEnteredMessage"
#define Interface_WillSendEnteredMessage 			@"Interface_WillSendEnteredMessage"
#define Interface_DidSendEnteredMessage				@"Interface_DidSendEnteredMessage"
#define Interface_ShouldDisplayErrorMessage			@"Interface_ShouldDisplayErrorMessage"
#define Interface_ShouldDisplayQuestion				@"Interface_ShouldDisplayQuestion"
#define Interface_ContactListDidBecomeMain			@"Interface_ContactListDidBecomeMain"
#define Interface_ContactListDidResignMain			@"Interface_contactListDidResignMain"
#define Interface_ContactListDidClose				@"Interface_contactListDidClose"
#define Interface_TabArrangingPreferenceChanged		@"Interface_TabArrangingPreferenceChanged"
#define AIViewDesiredSizeDidChangeNotification		@"AIViewDesiredSizeDidChangeNotification"

#define PREF_GROUP_INTERFACE			@"Interface"
#define KEY_TABBED_CHATTING				@"Tabbed Chatting"
#define KEY_GROUP_CHATS_BY_GROUP		@"Group Chats By Group"

#define PREF_GROUP_CONTACT_LIST				@"Contact List"
#define KEY_CL_WINDOW_LEVEL					@"Window Level"
#define KEY_CL_HIDE							@"Hide While in Background"
#define KEY_CL_EDGE_SLIDE					@"Hide On Screen Edges"
#define KEY_CL_FLASH_UNVIEWED_CONTENT		@"Flash Unviewed Content"
#define KEY_CL_SHOW_TRANSITIONS				@"Show Transitions"
#define KEY_CL_SHOW_TOOLTIPS				@"Show Tooltips"
#define KEY_CL_SHOW_TOOLTIPS_IN_BACKGROUND	@"Show Tooltips in Background"
#define KEY_CL_WINDOW_HAS_SHADOW			@"Window Has Shadow"

typedef enum {
	AINormalWindowLevel = 0,
	AIFloatingWindowLevel = 1,
	AIDesktopWindowLevel = 2
} AIWindowLevel;

//Identifiers for the various message views
typedef enum {
	DCStandardMessageView = 1,	//webkit is not available
	DCWebkitMessageView			//Preferred message view
} DCMessageViewType;

@protocol AIInterfaceComponent, AIContactListComponent, AIMessageViewController, AIMessageViewPlugin;
@protocol AIContactListTooltipEntry, AIFlashObserver;

@class AIChat, AIListObject;

@protocol AIInterfaceController <AIController>
- (void)registerInterfaceController:(id <AIInterfaceComponent>)inController;
- (void)registerContactListController:(id <AIContactListComponent>)inController;
- (BOOL)handleReopenWithVisibleWindows:(BOOL)visibleWindows;

//Contact List
- (IBAction)showContactList:(id)sender;
- (IBAction)closeContactList:(id)sender;
- (BOOL)contactListIsVisibleAndMain;
- (BOOL)contactListIsVisible;

//Messaging
- (void)openChat:(AIChat *)inChat;
- (void)closeChat:(AIChat *)inChat;
- (void)consolidateChats;
- (void)setActiveChat:(AIChat *)inChat;
- (AIChat *)activeChat;
- (NSArray *)openChats;
- (NSArray *)openChatsInContainerWithID:(NSString *)containerID;

//Chat cycling
- (void)nextChat:(id)sender;
- (void)previousChat:(id)sender;

//Interface plugin callbacks
- (void)chatDidOpen:(AIChat *)inChat;
- (void)chatDidBecomeActive:(AIChat *)inChat;
- (void)chatDidBecomeVisible:(AIChat *)inChat inWindow:(NSWindow *)inWindow;
- (void)chatDidClose:(AIChat *)inChat;
- (void)chatOrderDidChange;
- (NSWindow *)windowForChat:(AIChat *)inChat;
- (AIChat *)activeChatInWindow:(NSWindow *)window;

//Interface selection
- (AIListObject *)selectedListObject;
- (AIListObject *)selectedListObjectInContactList;
- (NSArray *)arrayOfSelectedListObjectsInContactList;

//Message View
- (void)registerMessageViewPlugin:(id <AIMessageViewPlugin>)inPlugin;
- (id <AIMessageViewController>)messageViewControllerForChat:(AIChat *)inChat;

//Error Display
- (void)handleErrorMessage:(NSString *)inTitle withDescription:(NSString *)inDesc;
- (void)handleMessage:(NSString *)inTitle withDescription:(NSString *)inDesc withWindowTitle:(NSString *)inWindowTitle;

//Question Display
- (void)displayQuestion:(NSString *)inTitle withAttributedDescription:(NSAttributedString *)inDesc withWindowTitle:(NSString *)inWindowTitle
		  defaultButton:(NSString *)inDefaultButton alternateButton:(NSString *)inAlternateButton otherButton:(NSString *)inOtherButton
				 target:(id)inTarget selector:(SEL)inSelector userInfo:(id)inUserInfo;
- (void)displayQuestion:(NSString *)inTitle withDescription:(NSString *)inDesc withWindowTitle:(NSString *)inWindowTitle
		  defaultButton:(NSString *)inDefaultButton alternateButton:(NSString *)inAlternateButton otherButton:(NSString *)inOtherButton
				 target:(id)inTarget selector:(SEL)inSelector userInfo:(id)inUserInfo;

//Synchronized Flashing
- (void)registerFlashObserver:(id <AIFlashObserver>)inObserver;
- (void)unregisterFlashObserver:(id <AIFlashObserver>)inObserver;
- (int)flashState;

//Tooltips
- (void)registerContactListTooltipEntry:(id <AIContactListTooltipEntry>)inEntry secondaryEntry:(BOOL)isSecondary;
- (void)unregisterContactListTooltipEntry:(id <AIContactListTooltipEntry>)inEntry secondaryEntry:(BOOL)isSecondary;
- (void)showTooltipForListObject:(AIListObject *)object atScreenPoint:(NSPoint)point onWindow:(NSWindow *)inWindow;

//Window levels menu
- (NSMenu *)menuForWindowLevelsNotifyingTarget:(id)target;
@end

//Controls a contact list view
@protocol AIContactListViewController <NSObject>	
- (NSView *)contactListView;
@end

//Manages contact list view controllers
@protocol AIContactListController <NSObject>	
- (id <AIContactListViewController>)contactListViewController;
@end

@protocol AIMessageViewController <NSObject>
- (NSView *)messageView;
- (NSView *)messageScrollView;
@end

//manages message view controllers
@protocol AIMessageViewPlugin <NSObject>	
- (id <AIMessageViewController>)messageViewControllerForChat:(AIChat *)inChat;
@end

@protocol AIContactListTooltipEntry <NSObject>
- (NSString *)labelForObject:(AIListObject *)inObject;
- (NSAttributedString *)entryForObject:(AIListObject *)inObject;
@end

@protocol AIFlashObserver <NSObject>
- (void)flash:(int)value;
@end

//Handles any attributed text entry
@protocol AITextEntryView 
- (void)setAttributedString:(NSAttributedString *)inAttributedString;
- (void)setTypingAttributes:(NSDictionary *)attrs;
- (BOOL)availableForSending;
- (AIChat *)chat;
@end

@protocol AIInterfaceComponent <NSObject>
- (void)openInterface;
- (void)closeInterface;
- (id)openChat:(AIChat *)chat inContainerWithID:(NSString *)containerName atIndex:(int)index;
- (void)setActiveChat:(AIChat *)inChat;
- (void)moveChat:(AIChat *)chat toContainerWithID:(NSString *)containerID index:(int)index;
- (void)closeChat:(AIChat *)chat;
- (NSArray *)openContainersAndChats;
- (NSArray *)openContainers;
- (NSArray *)openChats;
- (NSArray *)openChatsInContainerWithID:(NSString *)containerID;
- (NSString *)containerIDForChat:(AIChat *)chat;
- (NSWindow *)windowForChat:(AIChat *)chat;
- (AIChat *)activeChatInWindow:(NSWindow *)window;
@end

@protocol AIContactListComponent <NSObject>
- (void)showContactListAndBringToFront:(BOOL)bringToFront;
- (BOOL)contactListIsVisibleAndMain;
- (BOOL)contactListIsVisible;
- (void)closeContactList;
@end

//Custom printing informal protocol
@interface NSObject (AdiumPrinting)
- (void)adiumPrint:(id)sender;
- (BOOL)validatePrintMenuItem:(id <NSMenuItem>)menuItem;
@end

@interface NSWindowController (AdiumBorderlessWindowClosing)
- (BOOL)windowPermitsClose;
@end
