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

#import <Adium/AIAccount.h>

@interface AIAccount (Abstract)

- (id)initWithUID:(NSString *)inUID internalObjectID:(NSString *)inInternalObjectID service:(AIService *)inService;
- (NSData *)userIconData;
- (void)setUserIconData:(NSData *)inData;
- (NSString *)host;
- (int)port;
- (void)filterAndSetUID:(NSString *)inUID;
- (BOOL)enabled;
- (void)setEnabled:(BOOL)inEnabled;

//Status
- (void)preferencesChangedForGroup:(NSString *)group key:(NSString *)key object:(AIListObject *)object
					preferenceDict:(NSDictionary *)prefDict firstTime:(BOOL)firstTime;
- (void)silenceAllContactUpdatesForInterval:(NSTimeInterval)interval;
- (void)updateContactStatus:(AIListContact *)inContact;
- (void)updateCommonStatusForKey:(NSString *)key;
- (AIStatus *)statusState;
- (AIStatus *)actualStatusState;
- (void)setStatusState:(AIStatus *)statusState;
- (void)setStatusStateAndRemainOffline:(AIStatus *)statusState;
- (NSString *)currentDisplayName;

//Auto-Refreshing Status String
- (NSAttributedString *)autoRefreshingOutgoingContentForStatusKey:(NSString *)key;
- (void)autoRefreshingOutgoingContentForStatusKey:(NSString *)key selector:(SEL)selector;
- (void)autoRefreshingOutgoingContentForStatusKey:(NSString *)key selector:(SEL)selector context:(id)originalContext;
- (NSAttributedString *)autoRefreshingOriginalAttributedStringForStatusKey:(NSString *)key;
- (void)setStatusObject:(id)value forKey:(NSString *)key notify:(NotifyTiming)notify;
- (void)startAutoRefreshingStatusKey:(NSString *)key forOriginalValueString:(NSString *)originalValueString;
- (void)stopAutoRefreshingStatusKey:(NSString *)key;
- (void)_startAttributedRefreshTimer;
- (void)_stopAttributedRefreshTimer;
- (void)gotFilteredStatusMessage:(NSAttributedString *)statusMessage forStatusState:(AIStatus *)statusState;
- (void)updateLocalDisplayNameTo:(NSAttributedString *)displayName;
- (NSString *)currentDisplayName;

//Contacts
- (NSArray *)contacts;
- (AIListContact *)contactWithUID:(NSString *)sourceUID;
- (void)removeAllContacts;
- (void)removeStatusObjectsFromContact:(AIListContact *)listContact silently:(BOOL)silent;

//Connectivity
- (BOOL)shouldBeOnline;
- (void)setShouldBeOnline:(BOOL)inShouldBeOnline;
- (void)toggleOnline;
- (void)didConnect;
- (NSSet *)contactStatusObjectKeys;
- (void)didDisconnect;
- (void)connectScriptCommand:(NSScriptCommand *)command;
- (void)disconnectScriptCommand:(NSScriptCommand *)command;
- (void)serverReportedInvalidPassword;
- (void)getProxyConfigurationNotifyingTarget:(id)target selector:(SEL)selector context:(id)context;

//FUS Disconnecting
- (void)autoReconnectAfterDelay:(NSTimeInterval)delay;
- (void)cancelAutoReconnect;
- (void)initFUSDisconnecting;

//Temporary Accounts
- (BOOL)isTemporary;
- (void)setIsTemporary:(BOOL)inIsTemporary;

- (void)setPasswordTemporarily:(NSString *)inPassword;

@end
