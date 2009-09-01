//
//  ASISendFile.h
//  AdiumSoul
//
//  Created by Naixn on 11/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Adium/AIWindowController.h>
#import <Adium/AIListContact.h>
#import <Adium/ESFileTransfer.h>


enum NSISendMethods
{
    NSISendMethodAllLocation = 0,
    NSISendMethodOneLocation
};

@class ASAccount, ASContact;

@interface ASISendFile : AIWindowController
{
    // Outlets
    IBOutlet    NSTextField*    label_login;
    IBOutlet    NSMatrix*       matrix_sendMethod;
    IBOutlet    NSPopUpButton*  popUp_sendLocation;
    IBOutlet    NSImageView*    imageView_contactIcon;

    ASAccount*         account;
    ESFileTransfer*             fileTransfer;
    NSArray*                    locationArray;
}

+ (void)promptSendLocationForTransfer:(ESFileTransfer *)inFileTransfer onAccount:(ASAccount *)inAccount;
- (id)initWithWindowNibName:(NSString *)windowNibName forTransfer:(ESFileTransfer *)inFileTransfer onAccount:(ASAccount *)inAccount;
- (void)dealloc;
- (void)windowDidLoad;
- (IBAction)changePreference:(id)sender;
- (IBAction)sendFile:(id)sender;
- (IBAction)cancel:(id)sender;

@end
