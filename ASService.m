//
//  ASService.m
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

#import <Adium/AIAccount.h>
#import <AIUtilities/AIImageAdditions.h>

//#import "ASAccountViewController.h"
#import "ASAccount.h"
#import "ASService.h"
#import "ASIAccountView.h"

@implementation ASService

//Account Creation -----------------------------------------------------------------------------------------------------
#pragma mark Account Creation

/*!
 * @brief Account class associated with this service
 *
 * Subclass to return the account class associated with this service ([AISomethingAccount class]).
 * @return The account class associated with this service.
 */
- (Class)accountClass
{
    return [ASAccount class];
}

/*!
 * @brief Account view controller for this service
 *
 * Subclass to return an account view controller which provides the necessary controls for configuring an account
 * on this service.
 * @return An AIAccountViewController or subclass for this service.
 */
- (AIAccountViewController *)accountViewController
{
	return [ASIAccountView accountViewController];
}

//Service Description --------------------------------------------------------------------------------------------------
#pragma mark Service Description

/*!
 * @brief Unique ID for this class
 *
 * Subclass to return a unique string ID which identifies this class.  No two classes should have the same uniqueID.
 * This value is used to determine which protocol code to use for the user's accounts.
 * Examples: "libgaim-aim", "aim-toc2", "imservices-aim-.mac"
 * @return NSString unique ID
 */
- (NSString *)serviceCodeUniqueID
{
    return @"epimac-adiumsoul";
}

/*!
 * @brief Service ID for this service
 *
 * Subclass to return a string which identifies this service.  If multiple service classes are supporting the same
 * service they should have the same serviceID.  Not for user-display.
 * Examples: "AIM", "MSN", "Jabber", "ICQ", "Mac"
 * @return NSString service ID
 */
- (NSString *)serviceID
{
    return @"AdiumSoul";
}

/*!
 * @brief Service class for this service
 *
 * Some separate services can communicate with eachother.  These services, while they have separate serviceID's,
 * are all part of a common service class.  For instance, AIM, ICQ, and .Mac are all part of the "AIM" service class.
 * For many services, the serviceClass will be identical to the serviceID.  Not for user-display.
 * Service classes may change, do not use them for any permenant storage (logs, preferences, etc).
 * Examples: "AIM-compatible", "Jabber", "MSN"
 * @return NSString service class
 */
- (NSString *)serviceClass
{
	return @"AdiumSoul";
}

/*!
 * @brief Human readable short description
 *
 * Human readable, short description of this service
 * This value is used in tooltips and the message window.
 * Examples: "Jabber", "MSN", "AIM", ".Mac"
 * @return NSString short description
 */
- (NSString *)shortDescription
{
  return @"AdiumSoul";
}

/*!
 * @brief Human readable long description
 *
 * Human readable, long description of this service
 * If there are multiple classes available for the same service, this description should briefly show the difference
 * between the implementations.  This value is used in the account preferences service menu.
 * Examples: "Jabber", "MSN", "AOL Instant Messenger", ".Mac"
 * @return NSString long description
 */
- (NSString *)longDescription
{
    return @"AdiumSoul";
}

/*!
 * @brief Label for user name (general)
 *
 * String to use for describing the UID/username of this service.  This value varies by service, but should be something
 * along the lines of "User name", "Account name", "Screen name", "Member name", etc.
 *
 * This will be used for the account preferences to indicate the field for the account's user name.  By default, contactUserNameLabel
 * will return this value, as well.
 *
 * @return NSString label for username
 */
- (NSString *)userNameLabel
{
    return @"Login";
}

/*!
 * @brief Service importance
 *
 * Importance grouping of this service.  Used to make service listings and menus more organized by placing more important
 * services at the top of lists or displaying them with more visibility.
 * @return AIServiceImportance importance of this service
 */
- (AIServiceImportance)serviceImportance
{
    return AIServicePrimary;
}

/*!
 * @brief Default icon
 *
 * Service Icon packs should always include images for all the built-in Adium services.  This method allows external
 * service plugins to specify an image which will be used when the service icon pack does not specify one.  It will
 * also be useful if new services are added to Adium itself after a significant number of Service Icon packs exist
 * which do not yet have an image for this service.  If the active Service Icon pack provides an image for this service,
 * this method will not be called.
 *
 * The service should _not_ cache this icon internally; multiple calls should return unique NSImage objects.
 *
 * @param iconType The AIServiceIconType of the icon to return. This specifies the desired size of the icon.
 * @return NSImage to use for this service by default
 */
- (NSImage *)defaultServiceIconOfType:(AIServiceIconType)iconType
{
    if (iconType == AIServiceIconLarge)
        return [NSImage imageNamed:@"netsoullargeicon" forClass:[self class]];
    return [NSImage imageNamed:@"netsoulmediumicon" forClass:[self class]];
}

//Service Properties ---------------------------------------------------------------------------------------------------
#pragma mark Service Properties

/*!
 * @brief Allowed characters
 *
 * Characters allowed in user names on this service.  The user will not be allowed to type any characters not in this
 * set as a contact or account name.
 * @return NSCharacterSet of allowed characters
 */
- (NSCharacterSet *)allowedCharacters
{
    return [[NSCharacterSet illegalCharacterSet] invertedSet];
}

/*!
 * @brief Allowed name length
 *
 * Max allowed length of user names of this service.  Account and contact names longer than this will not be allowed.
 * @return Max name length
 */
- (NSUInteger)allowedLength
{
    return 100;
}

/*!
 * @brief Case sensitivity of names
 *
 * Determines if usernames such as "Adam" and "adam" are unique.
 * @return Case sensitivity
 */
- (BOOL)caseSensitive
{
    return YES;
}

@end
