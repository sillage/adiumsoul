/*
 *  AIContactAlertsControllerProtocol.h
 *  Adium
 *
 *  Created by Evan Schoenberg on 7/31/06.
 *
 */

#import <Adium/AIControllerProtocol.h>

@class AIListObject, AIModularPane;

@protocol AIEventHandler, AIActionHandler;

//Event preferences
#define PREF_GROUP_CONTACT_ALERTS	@"Contact Alerts"
#define KEY_CONTACT_ALERTS			@"Contact Alerts"
#define KEY_DEFAULT_EVENT_ID		@"Default Event ID"
#define KEY_DEFAULT_ACTION_ID		@"Default Action ID"

//Event Dictionary keys
#define	KEY_EVENT_ID				@"EventID"
#define	KEY_ACTION_ID				@"ActionID"
#define	KEY_ACTION_DETAILS			@"ActionDetails"
#define KEY_ONE_TIME_ALERT			@"OneTime"

typedef enum {
	AIContactsEventHandlerGroup = 0,
	AIMessageEventHandlerGroup,
	AIAccountsEventHandlerGroup,
	AIFileTransferEventHandlerGroup,
	AIOtherEventHandlerGroup
} AIEventHandlerGroupType;
#define EVENT_HANDLER_GROUP_COUNT 5

@protocol AIContactAlertsController <AIController>
//Events
- (void)registerEventID:(NSString *)eventID withHandler:(id <AIEventHandler>)handler inGroup:(AIEventHandlerGroupType)inGroup globalOnly:(BOOL)global;
- (NSArray *)allEventIDs;
- (NSMenu *)menuOfEventsWithTarget:(id)target forGlobalMenu:(BOOL)global;
- (NSArray *)arrayOfMenuItemsForEventsWithTarget:(id)target forGlobalMenu:(BOOL)global;
- (NSArray *)sortedArrayOfEventIDsFromArray:(NSArray *)inArray;
- (NSSet *)generateEvent:(NSString *)eventID forListObject:(AIListObject *)listObject userInfo:(id)userInfo previouslyPerformedActionIDs:(NSSet *)previouslyPerformedActionIDs;
- (NSString *)defaultEventID;
- (NSString *)eventIDForEnglishDisplayName:(NSString *)displayName;
- (NSString *)globalShortDescriptionForEventID:(NSString *)eventID;
- (NSString *)longDescriptionForEventID:(NSString *)eventID forListObject:(AIListObject *)listObject;
- (NSString *)naturalLanguageDescriptionForEventID:(NSString *)eventID
										listObject:(AIListObject *)listObject
										  userInfo:(id)userInfo
									includeSubject:(BOOL)includeSubject;
- (NSImage *)imageForEventID:(NSString *)eventID;
- (BOOL)isMessageEvent:(NSString *)eventID;

//Actions
- (void)registerActionID:(NSString *)actionID withHandler:(id <AIActionHandler>)handler;
- (NSDictionary *)actionHandlers;
- (NSMenu *)menuOfActionsWithTarget:(id)target;
- (NSString *)defaultActionID;

//Alerts
- (NSArray *)alertsForListObject:(AIListObject *)listObject;
- (NSArray *)alertsForListObject:(AIListObject *)listObject withEventID:(NSString *)eventID actionID:(NSString *)actionID;
- (void)addAlert:(NSDictionary *)alert toListObject:(AIListObject *)listObject setAsNewDefaults:(BOOL)setAsNewDefaults;
- (void)addGlobalAlert:(NSDictionary *)newAlert;
- (void)removeAlert:(NSDictionary *)victimAlert fromListObject:(AIListObject *)listObject;
- (void)setAllGlobalAlerts:(NSArray *)allGlobalAlerts;
- (void)removeAllGlobalAlertsWithActionID:(NSString *)actionID;
- (void)mergeAndMoveContactAlertsFromListObject:(AIListObject *)oldObject intoListObject:(AIListObject *)newObject;
@end

/*!
 * @protocol AIEventHandler <NSObject>
 * @brief Protocol for a class which posts and supplies information about an Event
 *
 * Example Events are Account Connected, Contact Signed On, New Message Received
 */
@protocol AIEventHandler <NSObject>
- (NSString *)shortDescriptionForEventID:(NSString *)eventID;
- (NSString *)globalShortDescriptionForEventID:(NSString *)eventID;
- (NSString *)englishGlobalShortDescriptionForEventID:(NSString *)eventID;
- (NSString *)longDescriptionForEventID:(NSString *)eventID forListObject:(AIListObject *)listObject;
- (NSImage *)imageForEventID:(NSString *)eventID;
- (NSString *)naturalLanguageDescriptionForEventID:(NSString *)eventID
										listObject:(AIListObject *)listObject
										  userInfo:(id)userInfo
									includeSubject:(BOOL)includeSubject;
@end

/*!
 * @protocol AIActionHandler <NSObject>
 * @brief Protocol for an Action which can be taken in response to an Event
 *
 * An action may optionally supply a details pane.  If it does, it can store information in a details dictionary
 * which will be passed back to the action when it is triggered as well as when it is queried for a  long description.
 *
 * Example Actions are Play Sound, Speak Event, Display Growl Notification
 */
@protocol AIActionHandler <NSObject>
/*!
 * @brief Short description
 * @result A short localized description of the action
 */
- (NSString *)shortDescriptionForActionID:(NSString *)actionID;

/*!
 * @brief Long description
 * @result A longer localized description of the action which should take into account the details dictionary as appropraite.
 */
- (NSString *)longDescriptionForActionID:(NSString *)actionID withDetails:(NSDictionary *)details;

/*!
 * @brief Image
 */
- (NSImage *)imageForActionID:(NSString *)actionID;

/*!
 * @brief Details pane
 * @result An <tt>AIModularPane</tt> to use for configuring this action, or nil if no configuration is possible.
 */
- (AIModularPane *)detailsPaneForActionID:(NSString *)actionID;

/*!
 * @brief Perform an action
 *
 * @param actionID The ID of the action to perform
 * @param listObject The listObject associated with the event triggering the action. It may be nil
 * @param details If set by the details pane when the action was created, the details dictionary for this particular action
 * @param eventID The eventID which triggered this action
 * @param userInfo Additional information associated with the event; userInfo's type will vary with the actionID.
 *
 * @result YES if the action was performed successfully.  If NO, other actions of the same type will be attempted even if allowMultipleActionsWithID: returns NO for eventID.
 */
- (BOOL)performActionID:(NSString *)actionID forListObject:(AIListObject *)listObject withDetails:(NSDictionary *)details triggeringEventID:(NSString *)eventID userInfo:(id)userInfo;

/*!
 * @brief Allow multiple actions?
 *
 * If this method returns YES, every one of this action associated with the triggering event will be executed.
 * If this method returns NO, only the first will be.
 *
 * Example of relevance: An action which plays a sound may return NO so that if the user has sound actions associated
 * with the "Message Received (Initial)" and "Message Received" events will hear the "Message Received (Initial)"
 * sound [which is triggered first] and not the "Message Received" sound when an initial message is received. If this
 * method returned YES, both sounds would be played.
 */
- (BOOL)allowMultipleActionsWithID:(NSString *)actionID;
@end
