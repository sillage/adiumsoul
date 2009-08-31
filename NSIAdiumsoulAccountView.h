//
//  NSIAdiumsoulAccountView.h
//  NetSoul Interface - AdiumSoul
//
//  Created by Naixn on 19/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/AIAccountViewController.h>

@interface NSIAdiumsoulAccountView : AIAccountViewController
{
    IBOutlet    NSButton*       checkBox_askLocation;
    IBOutlet    NSButton*       checkBox_displayLocation;
    IBOutlet    NSButton*       checkBox_useKerberos;
    IBOutlet    NSButton*       checkBox_showAlert;
    IBOutlet    NSButton*       checkBox_reconnect;
    IBOutlet    NSStepper*      stepper_reconnectTime;
    IBOutlet    NSTextField*    textField_passwordHelper;
    IBOutlet    NSTextField*    textField_reconnectTime;
    IBOutlet    NSTextField*    textField_netsoulLocation;
    IBOutlet    NSTextField*    textField_netsoulUserData;
    IBOutlet    NSTextField*    textField_studentPromo;
    IBOutlet    NSTextField*    label_studentPromo;

    SInt32      macOsVersion;
}

- (NSString *)nibName;
- (void)configureForAccount:(AIAccount *)inAccount;
- (void)saveConfiguration;
- (IBAction)changedPreference:(id)sender;

@end
