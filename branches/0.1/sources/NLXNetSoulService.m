//
//  NLXNetSoulService.m
//  AdiumSoul
//
//  Created by Carbonimax on 10/04/07.
//  Copyright 2007 Neelyx. All rights reserved.
//

#import <Adium/AIAdiumProtocol.h>
#import <Adium/AIStatusControllerProtocol.h>
#import <AIUtilities/AIImageAdditions.h>
#import "NLXNetSoulService.h"
#import "NLXNetSoulAccountViewController.h"


@implementation NLXNetSoulService

- (Class)accountClass
{
		return [NLXNetSoulService class];
}

- (AIAccountViewController *)accountViewController
{
		return [NLXNetSoulAccountViewController accountViewController];
}

- (NSString *)serviceCodeUniqueID
{
		return @"netsoul";
}

- (NSString *)serviceID
{
		return @"NetSoul";
}

- (NSString *)serviceClass
{
		return @"NetSoul";
}

- (NSString *)shortDescription
{
		return @"NetSoul";
}

- (NSString *)longDescription
{
		return @"NetSoul";
}

- (NSCharacterSet *)allowedCharacters
{
    return [[NSCharacterSet illegalCharacterSet] invertedSet];
}

- (NSCharacterSet *)ignoredCharacters
{
		return [NSCharacterSet characterSetWithCharactersInString:@""];
}

- (int)allowedLength
{
		return 256;
}

- (BOOL)caseSensitive
{
		return YES;
}

- (AIServiceImportance)serviceImportance
{
		return AIServicePrimary;
}

- (BOOL)supportsProxySettings
{
		return YES;
}

- (BOOL)requiresPassword
{
		return YES;
}

- (void)registerStatuses
{
		[[adium statusController] registerStatus:STATUS_NAME_AVAILABLE
														 withDescription:[[adium statusController]
		   localizedDescriptionForCoreStatusName:STATUS_NAME_AVAILABLE]
																			ofType:AIAvailableStatusType
																	forService:self];
		
		[[adium statusController] registerStatus:STATUS_NAME_AWAY
														 withDescription:[[adium statusController]
		   localizedDescriptionForCoreStatusName:STATUS_NAME_AWAY]
																			ofType:AIAwayStatusType
																	forService:self];
}

- (NSImage *)defaultServiceIconOfType:(AIServiceIconType)iconType
{
		if (iconType == AIServiceIconLarge)
				return [NSImage imageNamed:@"NetSoulLarge" forClass:[self class]];
		return [NSImage imageNamed:@"NetSoulSmall" forClass:[self class]];
}

- (BOOL)canCreateGroupChats
{
		return NO;
}


@end
