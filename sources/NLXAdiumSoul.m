//
//  NLXAdiumSoul.m
//  AdiumSoul
//
//  Created by Carbonimax on 10/04/07.
//  Copyright 2007 Neelyx. All rights reserved.
//

#import "NLXAdiumSoul.h"
#import "NLXNetSoulService.h"


@implementation NLXAdiumSoul

- (void)installPlugin
{
		NSLog(@"AdiumSoul installed!");
		[[NLXNetSoulService alloc] init];
}

- (void)uninstallPlugin 
{
		NSLog(@"AdiumSoul going away!");
}

- (NSString *)pluginAuthor
{
		return @"Neelyx.net";
}

- (NSString *)pluginVersion
{
		return @"0.1";
}

- (NSString *)pluginDescription
{
		return @"NetSoul Adium plugin.";
}

- (NSString *)pluginURL
{
		return @"http://www.neelyx.net/projets/AdiumSoul";
}

@end
