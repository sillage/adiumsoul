//
//  NSIAdiumsoulAccountView.m
//  NetSoul Interface - AdiumSoul
//
//  Created by Naixn on 19/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "NSIAdiumsoulAccountView.h"
#import "NSPAdiumsoul.h"
#import "kerberos.lib.h"

#import <Adium/AIAccount.h>

#define kAdiumSoulMinimumVersionForKerberos 0x1060


@implementation NSIAdiumsoulAccountView

- (id)init
{
    if (self = [super init])
    {
        if (Gestalt(gestaltSystemVersion, &macOsVersion) != noErr)
        {
            macOsVersion = 0;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkKrbConf)
                                                     name:ASProfileInstallationDidFinishNotification
                                                   object:nil];        
    }
    return self;
}

- (NSString *)nibName
{
    return @"NSIAdiumsoulAccountView";
}

//Preferences ----------------------------------------------------------------------------------------------------------
#pragma mark Preferences
/*!
 * @brief Configure the account view
 *
 * Configures the account view controls for the passed account.
 */
- (void)configureForAccount:(AIAccount *)inAccount
{
    [super configureForAccount:inAccount];

    NSString*   connectHost = [account preferenceForKey:KEY_CONNECT_HOST group:GROUP_ACCOUNT_STATUS];
    NSString*   connectHostDefault = @"ns-server.epita.fr";
    NSString*   connectPort = [account preferenceForKey:KEY_CONNECT_PORT group:GROUP_ACCOUNT_STATUS];
    NSString*   connectPortDefault = @"4242";
    NSString*   studentPromo = [account preferenceForKey:NETSOUL_KEY_PROMO group:GROUP_ACCOUNT_STATUS];
    NSString*   netsoulLocation = [account preferenceForKey:NETSOUL_KEY_LOCATION group:GROUP_ACCOUNT_STATUS];
    NSString*   netsoulLocationDefault = @"AdiumSoul";
    NSString*   netsoulUserData = [account preferenceForKey:NETSOUL_KEY_USERDATA group:GROUP_ACCOUNT_STATUS];
    NSString*   netsoulUserDataDefault = @"AdiumSoul, it just works.";
    NSNumber*   netsoulReconnectTime = [account preferenceForKey:NETSOUL_KEY_RECONNECT_TIME group:GROUP_ACCOUNT_STATUS];
    NSNumber*   netsoulReconnectTimeDefault = [NSNumber numberWithInt:5];

    // Server
    [textField_connectHost setStringValue:(connectHost ? connectHost : connectHostDefault)];
    // Port
    [textField_connectPort setStringValue:(connectPort ? connectPort : connectPortDefault)];
    // Use Kerberos
    if (macOsVersion < kAdiumSoulMinimumVersionForKerberos)
    {
        [checkBox_useKerberos setState:NSOffState];
        [checkBox_useKerberos setHidden:YES];
    }
    else if ([[account preferenceForKey:NETSOUL_KEY_KERBEROOS group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        [checkBox_useKerberos setState:NSOnState];
        [self changedPreference:checkBox_useKerberos];
    }
    [self checkKrbConf];
    // Student promotion
    if (macOsVersion < kAdiumSoulMinimumVersionForKerberos)
    {
        [textField_studentPromo setHidden:YES];
        [label_studentPromo setHidden:YES];
    }
    else if (studentPromo)
    {
        [textField_studentPromo setStringValue:studentPromo];
    }
    // Location
    [textField_netsoulLocation setStringValue:(netsoulLocation ? netsoulLocation : netsoulLocationDefault)];
    // User data
    [textField_netsoulUserData setStringValue:(netsoulUserData ? netsoulUserData : netsoulUserDataDefault)];
    // Ask location on start
    if ([[account preferenceForKey:NETSOUL_KEY_ASK_LOCATION group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        [checkBox_askLocation setState:NSOnState];
    }
    // Display user's location as status message
    if ([[account preferenceForKey:NETSOUL_KEY_DISPLAY_LOCATION group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        [checkBox_displayLocation setState:NSOnState];
    }
    // Display alert when disconnected
    if ([[account preferenceForKey:NETSOUL_KEY_DISCONNECT_ALERT group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        [checkBox_showAlert setState:NSOnState];
    }
    // Reconnect after disconnection
    if ([[account preferenceForKey:NETSOUL_KEY_RECONNECT group:GROUP_ACCOUNT_STATUS] boolValue])
    {
        [checkBox_reconnect setState:NSOnState];
    }
    // Try to reconnect after X seconds
    [textField_reconnectTime setIntValue:[(netsoulReconnectTime ? netsoulReconnectTime : netsoulReconnectTimeDefault) intValue]];
    [stepper_reconnectTime setIntValue:[(netsoulReconnectTime ? netsoulReconnectTime : netsoulReconnectTimeDefault) intValue]];
}

- (void)saveConfiguration
{
    [super saveConfiguration];

    if (macOsVersion >= kAdiumSoulMinimumVersionForKerberos)
    {
        // Student promo
        NSString*   studentPromo = [textField_studentPromo stringValue];
        [account setPreference:([studentPromo length] ? studentPromo : nil) forKey:NETSOUL_KEY_PROMO group:GROUP_ACCOUNT_STATUS];
        // Use Kerberos
        [account setPreference:[NSNumber numberWithBool:[checkBox_useKerberos state]] forKey:NETSOUL_KEY_KERBEROOS group:GROUP_ACCOUNT_STATUS];
    }
    // Location
    NSString*   netsoulLocation = [textField_netsoulLocation stringValue];
    [account setPreference:([netsoulLocation length] ? netsoulLocation : nil) forKey:NETSOUL_KEY_LOCATION group:GROUP_ACCOUNT_STATUS];
    // User data
    NSString*   netsoulUserData = [textField_netsoulUserData stringValue];
    [account setPreference:([netsoulUserData length] ? netsoulUserData : nil) forKey:NETSOUL_KEY_USERDATA group:GROUP_ACCOUNT_STATUS];
    // Ask location on start
    [account setPreference:[NSNumber numberWithBool:[checkBox_askLocation state]] forKey:NETSOUL_KEY_ASK_LOCATION group:GROUP_ACCOUNT_STATUS];
    // Display user's location as status message
    [account setPreference:[NSNumber numberWithBool:[checkBox_displayLocation state]] forKey:NETSOUL_KEY_DISPLAY_LOCATION group:GROUP_ACCOUNT_STATUS];
    // Display alert when disconnected
    [account setPreference:[NSNumber numberWithBool:[checkBox_showAlert state]] forKey:NETSOUL_KEY_DISCONNECT_ALERT group:GROUP_ACCOUNT_STATUS];
    // Reconnect after disconnection
    [account setPreference:[NSNumber numberWithBool:[checkBox_reconnect state]] forKey:NETSOUL_KEY_RECONNECT group:GROUP_ACCOUNT_STATUS];
    // Try to reconnect after X seconds
    [account setPreference:[NSNumber numberWithInt:[textField_reconnectTime intValue]]
                    forKey:NETSOUL_KEY_RECONNECT_TIME
                     group:GROUP_ACCOUNT_STATUS];
    AILog(@"[AdiumSoul] Configuration saved");
}

#pragma mark User interaction

- (void)checkKrbConf
{
    if (macOsVersion < kAdiumSoulMinimumVersionForKerberos)
    {
        return ;
    }
    if ([checkBox_useKerberos state] == NSOffState || krb_configured_for_netsoul())
    {
        [label_kerberosStatus setHidden:YES];
        [button_configureKerberos setHidden:YES];
        [button_configureKerberos setEnabled:NO];
    }
    else
    {
        [label_kerberosStatus setHidden:NO];
        [button_configureKerberos setHidden:NO];
        [button_configureKerberos setEnabled:YES];
    }
}

- (IBAction)changedPreference:(id)sender
{
    if (macOsVersion >= kAdiumSoulMinimumVersionForKerberos && sender == checkBox_useKerberos)
    {
        [textField_studentPromo setEnabled:([checkBox_useKerberos state] == NSOnState ? YES : NO)];
        [label_passwordHelper setStringValue:([checkBox_useKerberos state] == NSOnState ? @"(UNIX Password)" : @"(SOCKS Password)")];
        [self checkKrbConf];
    }
}

- (IBAction)installKerberosConfig:(id)sender
{
    [NSApp beginSheet:[confinstallController installationWindow]
       modalForWindow:[sender window]
        modalDelegate:confinstallController
       didEndSelector:nil
          contextInfo:nil];
}

@end
