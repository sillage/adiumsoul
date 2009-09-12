//
//  NSNetsoulPlugin.m
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

#import "ASPlugin.h"
#import "ASService.h"

@implementation ASPlugin

- (void)installPlugin
{
    AILog(@"[AdiumSoul] AdiumSoul succesfully installed!");
    [[ASService alloc] init];
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
    return @"0.9f";
}

- (NSString *)pluginDescription
{
    return @"AdiumSoul is an Adium plugin for the Netsoul protocol, used in IONIS' schools";
}

- (NSString *)pluginURL
{
    return @"http://www.epimac.org";
}

@end
