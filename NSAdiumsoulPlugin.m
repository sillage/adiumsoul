//
//  NSNetsoulPlugin.m
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

#import "NSAdiumsoulPlugin.h"
#import "NSAdiumsoulService.h"

@implementation NSAdiumsoulPlugin

- (void)installPlugin
{
    AILog(@"[AdiumSoul] AdiumSoul succesfully installed!");
    [[NSAdiumsoulService alloc] init];
}

- (void)uninstallPlugin
{
    AILog(@"[AdiumSoul] AdiumSoul uninstalled");
}

- (NSString *)pluginAuthor
{
    return @"EpiMac";
}

- (NSString *)pluginVersion
{
    return @"0.9b1.3";
}

- (NSString *)pluginDescription
{
    return @"AdiumSoul is an Adium plugin for the Netsoul protocol, used is IONIS' schools";
}

- (NSString *)pluginURL
{
    return @"http://www.epimac.org";
}

@end
