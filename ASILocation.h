//
//  ASILocation.h
//  AdiumSoul
//
//  Created by Naixn on 20/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class ASAccount;

@interface ASILocation : NSWindowController
{
    IBOutlet NSTextField*   netsoul_location;

    ASAccount*     netsoul_account;
}

- (id)initWithWindowNibName:(NSString *)windowNibName withAccount:(ASAccount *)account;
- (void)show;
- (IBAction)setLocation:(id)sender;

@end
