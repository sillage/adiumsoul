//
//  NSIAdiumsoulLocation.m
//  AdiumSoul
//
//  Created by Naixn on 20/04/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "NSIAdiumsoulLocation.h"
#import "NSAdiumsoulAccount.h"


@implementation NSIAdiumsoulLocation

- (id)initWithWindowNibName:(NSString *)windowNibName withAccount:(NSAdiumsoulAccount *)account
{
    if (self = [super initWithWindowNibName:windowNibName])
    {
        netsoul_account = account;
        [netsoul_account retain];
    }
    return self;
}

- (void)dealloc
{
    [netsoul_account release];
    [super dealloc];
}

- (void)show
{
    [[self window] setTitle:@"Location ?"];
    [self showWindow:nil];
    [[self window] orderFront:self];
}


- (IBAction)setLocation:(id)sender
{
    if ([[netsoul_location stringValue] length] > 0)
    {
        [[self window] orderOut:self];
        [netsoul_account performSelector:@selector(setLocation:) withObject:[netsoul_location stringValue]];
    }
}

@end
