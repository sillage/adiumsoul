//
//  NSIAdiumsoulAccountView.h
//  NetSoul Interface - AdiumSoul
//
//  Created by Naixn on 19/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/AIAccountViewController.h>

#import "ASKrbConfinstallController.h"


@interface NSIAdiumsoulAccountView : AIAccountViewController
{
    // Setup outlets
    IBOutlet    NSButton*       checkBox_useKerberos;
    IBOutlet    NSButton*       button_configureKerberos;
    IBOutlet    NSTextField*    textField_studentPromo;
    IBOutlet    NSTextField*    label_passwordHelper;
    IBOutlet    NSTextField*    label_kerberosStatus;
    IBOutlet    NSTextField*    label_studentPromo;

    IBOutlet    ASKrbConfinstallController* confinstallController;

    // Profile outlets
    IBOutlet    NSTextField*    textField_netsoulLocation;
    IBOutlet    NSTextField*    textField_netsoulUserData;

    // Options outlets
    IBOutlet    NSButton*       checkBox_displayLocation;
    IBOutlet    NSButton*       checkBox_askLocation;
    IBOutlet    NSButton*       checkBox_showAlert;
    IBOutlet    NSButton*       checkBox_reconnect;
    IBOutlet    NSStepper*      stepper_reconnectTime;
    IBOutlet    NSTextField*    textField_reconnectTime;

    SInt32                      macOsVersion;
}

- (NSString *)nibName;
#pragma mark Preferences
- (void)configureForAccount:(AIAccount *)inAccount;
- (void)saveConfiguration;
#pragma mark User interaction
- (void)checkKrbConf;
- (IBAction)changedPreference:(id)sender;
- (IBAction)installKerberosConfig:(id)sender;

@end
