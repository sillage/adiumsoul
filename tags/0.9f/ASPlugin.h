//
//  ASPlugin.h
//  AdiumSoul
//
//  Created by Naixn on 08/04/08.
//

@interface ASPlugin : AIPlugin
{
}

- (void)installPlugin;
- (void)uninstallPlugin;
- (NSString *)pluginAuthor;
- (NSString *)pluginVersion;
- (NSString *)pluginDescription;
- (NSString *)pluginURL;

@end
