//
//  ASKrbConfinstallController.m
//  AdiumSoul
//
//  Created by naixn on 31/08/09.
//  Copyright 2009 Epitech / Apple. All rights reserved.
//

#import "ASKrbConfinstallController.h"
#import "RealmsConfiguration.h"

static NSString* gl_configFiles[] = {
    @"~/Library/Preferences/edu.mit.Kerberos", 
    @"/Library/Preferences/edu.mit.Kerberos", 
    @"/etc/krb5.conf",
    NULL
};

NSString *ASProfileInstallationDidFinishNotification = @"ASProfileInstallationDidFinishNotification";

@implementation ASKrbConfinstallController

- (id)init
{
    if (self = [super init])
    {
        lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];

    [lock release];
}

#pragma mark -

- (NSWindow *)installationWindow
{
    return installationWindow;
}

#pragma mark Installation

- (void)thread_installKrb5AtPath:(NSString *)path
{
    NSAutoreleasePool*      pool;
    RealmsConfiguration*    realmsConf;
    KerberosRealm*          krbRealm;
    KerberosServer*         krbServer;
    KerberosDomain*         krbDomain;
    
    pool = [[NSAutoreleasePool alloc] init];
    
    if ([lock tryLock])
    {
        AILog(@"[AdiumSoul] path: %@", path);
        @synchronized(label_installationText)
        {
            [label_installationText setStringValue:@"Creating config..."];
        }
        realmsConf = [[RealmsConfiguration alloc] initWithConfigurationPathString:path];
        
        krbRealm = [KerberosRealm emptyRealm];
        [krbRealm setName:@"EPITECH.NET"];
        
        krbServer = [KerberosServer emptyServer];
        [krbServer setHost:@"kdc.epitech.net"];
        [krbServer setTypeMenuIndex:kdcType];
        [krbRealm addServer:krbServer];
        
        krbDomain = [KerberosDomain emptyDomain];
        [krbDomain setName:@"epitech.net"];
        [krbRealm addDomain:krbDomain];
        
        krbDomain = [KerberosDomain emptyDomain];
        [krbDomain setName:@".epitech.net"];
        [krbRealm addDomain:krbDomain];
        
        krbDomain = [KerberosDomain emptyDomain];
        [krbDomain setName:@".epita.fr"];
        [krbRealm addDomain:krbDomain];
        
        [realmsConf addRealm:krbRealm];
        [realmsConf setDefaultRealm:[krbRealm name]];

        @synchronized(label_installationText)
        {
            [label_installationText setStringValue:@"Writing config to the file..."];
        }
        [realmsConf flush];
        
        [realmsConf release];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ASProfileInstallationDidFinishNotification object:nil];
    
    [pool drain];
}

- (void)thread_fakeInstall:(NSString *)path
{
    NSAutoreleasePool*      pool;
    
    pool = [[NSAutoreleasePool alloc] init];
    
    AILog(@"Fake install at path: %@", path);
    @synchronized(label_installationText)
    {
        [label_installationText setStringValue:@"Creating config..."];
    }
    @synchronized(label_installationText)
    {
        [label_installationText setStringValue:@"Writing config to the file..."];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ASProfileInstallationDidFinishNotification object:nil];

    [pool drain];
}

#pragma mark Install Sheet

- (IBAction)cancelKerberosInstall:(id)sender
{
    [self closeInstallationSheet];
}

- (IBAction)startKerberosInstall:(id)sender
{
    NSString*   configFile;

    // Prepare UI
    [progress_installationWheel startAnimation:nil];
    @synchronized(label_installationText)
    {
        [label_installationText setStringValue:@"Starting installation..."];
        [label_installationText setHidden:NO];
    }
    [button_cancel setEnabled:NO];
    [button_install setEnabled:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeInstallationSheet)
                                                 name:ASProfileInstallationDidFinishNotification
                                               object:nil];

    // Actually start the install process
    configFile = gl_configFiles[[[matrix_installationPath selectedCell] tag]];
//    [self closeInstallationSheet];
    [NSThread detachNewThreadSelector:@selector(thread_installKrb5AtPath:) toTarget:self withObject:configFile];
}

- (void)closeInstallationSheet
{
    [button_install setEnabled:YES];
    [button_cancel setEnabled:YES];
    @synchronized(label_installationText)
    {
        [label_installationText setStringValue:@""];
        [label_installationText setHidden:YES];
    }
    [progress_installationWheel stopAnimation:nil];
    [installationWindow orderOut:nil];
	[NSApp endSheet:installationWindow];
}

@end
