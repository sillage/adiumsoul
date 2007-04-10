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

#import <Adium/AIObject.h>

@class AIChat, AIListObject;

@interface AIContentObject : AIObject {
    AIChat				*chat;
    AIListObject		*source;
    AIListObject		*destination;
    BOOL				outgoing;
    
	NSAttributedString	*message;
    NSDate  			*date;
	
	BOOL				filterContent;
	BOOL				trackContent;
	BOOL				displayContent;
	BOOL				displayContentImmediately;
	BOOL				sendContent;
	BOOL				postProcessContent;
	
	NSDictionary		*userInfo;
}

- (id)initWithChat:(AIChat *)inChat
			source:(AIListObject *)inSource
	   destination:(AIListObject *)inDest
	          date:(NSDate*)inDate;
- (id)initWithChat:(AIChat *)inChat
			source:(AIListObject *)inSource
	   destination:(AIListObject *)inDest
			  date:(NSDate*)inDate
		   message:(NSAttributedString *)inMessage;
- (NSString *)type;

//Comparing
- (BOOL)isSimilarToContent:(AIContentObject *)inContent;
- (BOOL)isFromSameDayAsContent:(AIContentObject *)inContent;

//Content
- (AIListObject *)source;
- (AIListObject *)destination;
- (NSDate *)date;
- (BOOL)isOutgoing;
- (void)_setIsOutgoing:(BOOL)inOutgoing;
- (AIChat *)chat;
- (void)setChat:(AIChat *)inChat;
- (void)setMessage:(NSAttributedString *)inMessage;
- (NSAttributedString *)message;
- (NSString *)messageString;

- (id)userInfo;
- (void)setUserInfo:(id)inUserInfo;

//Behavior
- (BOOL)filterContent;
- (void)setFilterContent:(BOOL)inFilterContent;

- (BOOL)trackContent;
- (void)setTrackContent:(BOOL)inTrackContent;

- (BOOL)displayContent;
- (void)setDisplayContent:(BOOL)inDisplayContent;

- (BOOL)displayContentImmediately;
- (void)setDisplayContentImmediately:(BOOL)inDisplayContentImmediately;

- (BOOL)sendContent;
- (void)setSendContent:(BOOL)inSendContent;

- (BOOL)postProcessContent;
- (void)setPostProcessContent:(BOOL)inPostProcessContent;
@end
