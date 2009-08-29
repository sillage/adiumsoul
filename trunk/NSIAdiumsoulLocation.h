//
//  NSIAdiumsoulLocation.h
//  AdiumSoul
//
//  Created by Naixn on 20/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class NSAdiumsoulAccount;

@interface NSIAdiumsoulLocation : NSWindowController
{
    IBOutlet NSTextField*   netsoul_location;

    NSAdiumsoulAccount*     netsoul_account;
}

- (id)initWithWindowNibName:(NSString *)windowNibName withAccount:(NSAdiumsoulAccount *)account;
- (void)show;
- (IBAction)setLocation:(id)sender;

@end
