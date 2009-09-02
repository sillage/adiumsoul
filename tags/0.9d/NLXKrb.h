//
//  NLXKrb.h
//  AdiumSoul
//
//  Created by Pierre Monod-Broca on 22/01/08.
//  Copyright 2008 NLX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Kerberos/Kerberos.h>

#define NETSOUL_SERVICE_NAME @"host@ns-server.epitech.net"
#define NETSOUL_REALM @"EPITECH.NET"


@interface NLXKrb : NSObject
{
	krb5_context			_context;
	krb5_ccache				_ccache;
	krb5_principal			_principal;
	gss_name_t				_gss_service;
	BOOL					_well;
}

- (void)connectWithLogin:(NSString*)login passwd:(NSString*)pwd service:(NSString*)srv realm:(NSString*)realm;
- (void)encode64Data:(const char*)src length:(int)length to:(char **)dest;

- (void)setPrincipalWithLogin:(NSString*)login realm:(NSString*)realm;
- (void)unsetPrincipal;
- (void)setService:(NSString*)service;
- (void)unsetService;
- (BOOL)connectWithPassword:(NSString*)pass;
- (NSString*)token;

@end
