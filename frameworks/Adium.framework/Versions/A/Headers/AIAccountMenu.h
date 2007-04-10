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

#import <Adium/AIAbstractListObjectMenu.h>

@protocol AIListObjectObserver;
@class AIAccount, AIStatusMenu;

typedef enum {
	AIAccountNoSubmenu = 0,
	AIAccountStatusSubmenu,
	AIAccountOptionsSubmenu
} AIAccountSubmenuType;

@interface AIAccountMenu : AIAbstractListObjectMenu <AIListObjectObserver> {
	id				delegate;
	BOOL			delegateRespondsToDidSelectAccount;
	BOOL			delegateRespondsToShouldIncludeAccount;	

	BOOL			submenuType;
	BOOL			showTitleVerbs;
	BOOL			includeDisabledAccountsMenu;

	AIStatusMenu	*statusMenu;
}

+ (id)accountMenuWithDelegate:(id)inDelegate
				  submenuType:(AIAccountSubmenuType)inSubmenuType
			   showTitleVerbs:(BOOL)inShowTitleVerbs;

- (void)setDelegate:(id)inDelegate;
- (id)delegate;

- (NSMenuItem *)menuItemForAccount:(AIAccount *)account;

@end

@interface NSObject (AIAccountMenuDelegate)
- (void)accountMenu:(AIAccountMenu *)inAccountMenu didRebuildMenuItems:(NSArray *)menuItems;
- (void)accountMenu:(AIAccountMenu *)inAccountMenu didSelectAccount:(AIAccount *)inAccount; 	//Optional
- (BOOL)accountMenu:(AIAccountMenu *)inAccountMenu shouldIncludeAccount:(AIAccount *)inAccount; //Optional

//Should the account menu include a submenu of 'disabled accounts'?
- (BOOL)accountMenuShouldIncludeDisabledAccountsMenu:(AIAccountMenu *)inAccountMenu;			//Optional
@end
