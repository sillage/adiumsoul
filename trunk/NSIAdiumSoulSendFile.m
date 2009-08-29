//
//  NSIAdiumSoulSendFile.m
//  AdiumSoul
//
//  Created by Naixn on 11/05/08.
//  Copyright 2008 Epitech. All rights reserved.
//

#import "NSIAdiumSoulSendFile.h"
#import "NSAdiumsoulAccount.h"
#import "NSAdiumsoulContact.h"


@interface NSIAdiumSoulSendFile (Private)
- (void)configureLocationMenu;
- (void)configureContactPhoto;
- (void)windowOrderFront;
@end

@implementation NSIAdiumSoulSendFile

+ (void)promptSendLocationForTransfer:(ESFileTransfer *)inFileTransfer onAccount:(NSAdiumsoulAccount *)inAccount;
{
    NSIAdiumSoulSendFile*   sendLocationWindow;

    sendLocationWindow = [[self alloc] initWithWindowNibName:@"NSIAdiumSoulSendFile"
                                                 forTransfer:inFileTransfer
                                                   onAccount:inAccount];
    [sendLocationWindow showWindow:nil];
    [[sendLocationWindow window] makeKeyAndOrderFront:sendLocationWindow];
    [NSTimer timerWithTimeInterval:1 target:sendLocationWindow selector:@selector(windowOrderFront) userInfo:nil repeats:NO];
}

- (id)initWithWindowNibName:(NSString *)windowNibName forTransfer:(ESFileTransfer *)inFileTransfer onAccount:(NSAdiumsoulAccount *)inAccount;
{
    if ((self = [super initWithWindowNibName:windowNibName]))
    {
        account = [inAccount retain];
        fileTransfer = [inFileTransfer retain];
    }
    return self;
}

- (void)dealloc
{
    [account release];
    [fileTransfer release];
    [locationArray release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [label_login setStringValue:[[fileTransfer contact] UID]];
    [self configureLocationMenu];
    [self configureContactPhoto];
}

- (IBAction)changePreference:(id)sender
{
    if (sender == matrix_sendMethod)
    {
        [popUp_sendLocation setEnabled:([[matrix_sendMethod selectedCell] tag] == NSISendMethodOneLocation)];
    }
}

- (IBAction)sendFile:(id)sender
{
    if ([[matrix_sendMethod selectedCell] tag] == NSISendMethodAllLocation)
    {
        [account performSelector:@selector(sendFileForTransfer:onSocket:)
                      withObject:fileTransfer
                      withObject:nil];
    }
    else
    {
        [account performSelector:@selector(sendFileForTransfer:onSocket:)
                      withObject:fileTransfer
                      withObject:[[locationArray objectAtIndex:[[popUp_sendLocation selectedCell] tag]] objectForKey:@"socket"]];
    }
    [self closeWindow:nil];
}

- (IBAction)cancel:(id)sender
{
    [account performSelector:@selector(cancelledSendLocationChoice:) withObject:fileTransfer];
    [self closeWindow:nil];
}

@end

@implementation NSIAdiumSoulSendFile (Private)

- (void)configureLocationMenu
{
    NSMenu*         choicesMenu = [[[NSMenu allocWithZone:[NSMenu menuZone]] init] autorelease];
    NSMenuItem*     menuItem;
    NSEnumerator*   en;
    NSDictionary*   dic;
    int             i = 0;

    locationArray = [[[[fileTransfer contact] statusObjectForKey:NETSOUL_CONTACT] informationArray] retain];
    en = [locationArray objectEnumerator];
    while ((dic = [en nextObject]))
    {
        menuItem = [[[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[NSString stringWithFormat:@"%@ (%@, %@)",
                                                                                 [dic objectForKey:NETSOUL_CONTACT_LOCATION],
                                                                                 [dic objectForKey:NETSOUL_CONTACT_IP],
                                                                                 [dic objectForKey:NETSOUL_CONTACT_USER_DATA]]
                                                                         action:NULL
                                                                  keyEquivalent:@""] autorelease];
        [menuItem setTag:i++];
        [choicesMenu addItem:menuItem];
    }
    [popUp_sendLocation setMenu:choicesMenu];
}

- (void)configureContactPhoto
{
    [imageView_contactIcon setImage:[[[NSImage alloc] initWithData:[account serversideIconDataForContact:[fileTransfer contact]]] autorelease]];
}

- (void)windowOrderFront
{
    [[self window] makeKeyAndOrderFront:self];
}

@end
