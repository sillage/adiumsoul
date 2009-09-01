//
//  ASService.h
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

#import <Adium/AIService.h>

@interface ASService : AIService
{
}

//Account Creation
- (Class)accountClass;

//Service Description
- (NSString *)serviceCodeUniqueID;
- (NSString *)serviceID;
- (NSString *)serviceClass;
- (NSString *)shortDescription;
- (NSString *)longDescription;
- (NSString *)userNameLabel;
- (AIServiceImportance)serviceImportance;
- (NSImage *)defaultServiceIconOfType:(AIServiceIconType)iconType;

//Service Properties
- (NSCharacterSet *)allowedCharacters;
- (int)allowedLength;
- (BOOL)caseSensitive;

@end
