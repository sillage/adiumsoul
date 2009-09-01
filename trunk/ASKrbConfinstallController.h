//
//  ASKrbConfinstallController.h
//  AdiumSoul
//
//  Created by naixn on 31/08/09.
//  Copyright 2009 Epitech / Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *ASProfileInstallationDidFinishNotification;

@interface ASKrbConfinstallController : NSObject
{
    // Install Kerberos config outlets
    IBOutlet    NSWindow*               installationWindow;
    IBOutlet    NSProgressIndicator*    progress_installationWheel;
    IBOutlet    NSTextField*            label_installationText;
    IBOutlet    NSMatrix*               matrix_installationPath;
    IBOutlet    NSButton*               button_cancel;
    IBOutlet    NSButton*               button_install;

    NSLock* lock;
}

#pragma mark -
- (NSWindow *)installationWindow;
#pragma mark Installation
- (void)thread_installKrb5AtPath:(NSString *)path;
#pragma mark Install Sheet
- (IBAction)cancelKerberosInstall:(id)sender;
- (IBAction)startKerberosInstall:(id)sender;
- (void)closeInstallationSheet;

@end
