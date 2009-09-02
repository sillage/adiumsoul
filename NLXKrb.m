//
//  NLXKrb.m
//  AdiumSoul
//
//  Created by Pierre Monod-Broca on 22/01/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NLXKrb.h"
#import "NSData+Base64.h"

typedef struct  _krb_msgs
{
    long        code;
	char*       msg;
}               krb_msgs;

extern krb_msgs	krb_all_msgs[];

@implementation NLXKrb

- (void)stringWithKrbError:(krb5_error_code)code
{
	int i = 0;

	if (i == 0)
    {
		for (i = 0; krb_all_msgs[i].code != 0; ++i)
		{
			if (krb_all_msgs[i].code == code)
			{
				NSLog(@"krb_error : %i >> %s", krb_all_msgs[i].code, krb_all_msgs[i].msg);
				return;
			}
		}
    }
	NSLog(@"krb_error : %i (unknown)", code);
}

- (id)init
{
    if (self = [super init])
    {
        _context = nil;
        _principal = nil;
        _ccache = nil;
        _gss_service = nil;
    }
	return (self);
}

- (void)connectWithLogin:(NSString*)login passwd:(NSString*)pwd service:(NSString*)srv realm:(NSString*)realm
{
	krb5_error_code			ret;

	_well = YES;
	(ret = krb5_init_context(&_context));// in init
	NSLog(@" result krb5_init_context():%i", ret);
	if (ret < 0L)
	{
		[self stringWithKrbError:ret];
		_well = NO;
		return;
	}
	ret = krb5_cc_default(_context, &_ccache);// in init
	NSLog(@" result krb5_cc_default():%i", ret);
	if (ret < 0L)
	{
		[self stringWithKrbError:ret];
		_well = NO;
		return;
	}
	[self setPrincipalWithLogin:login realm:realm];
	[self setService:srv];
	[self connectWithPassword:pwd];
}

- (void)setPrincipalWithLogin:(NSString*)login realm:(NSString*)realm
{
	krb5_error_code			ret;

	if (_principal != nil)
		[self unsetPrincipal];
	if (_well == YES)
	{
		(ret = krb5_parse_name(_context, [login cStringUsingEncoding:NSASCIIStringEncoding], &_principal));// in setPrincipal
		NSLog(@" result krb5_parse_name():%i", ret);
		if (ret < 0L)
		{
			[self stringWithKrbError:ret];
			return;
		}
		ret = krb5_set_principal_realm(_context, _principal, [realm cStringUsingEncoding:NSASCIIStringEncoding]);// in setPrincipal
		NSLog(@" result krb5_set_principal_realm():%i", ret);
		if (ret < 0L)
		{
			[self stringWithKrbError:ret];
			return;
		}
	}
}

- (void)unsetPrincipal
{
	krb5_free_principal(_context, _principal);  // in destroy
	_principal = nil;
}

- (void)setService:(NSString*)service
{
	OM_uint32				min;
	OM_uint32				maj;
	gss_buffer_desc			buf;
	char					*tmp;

	if (_gss_service != nil)
		[self unsetService];
	tmp = strdup([service cStringUsingEncoding:NSASCIIStringEncoding]);
	buf.value = (unsigned char *)tmp;
	buf.length = strlen((const char*)buf.value);
	maj = gss_import_name(&min, &buf, GSS_C_NT_HOSTBASED_SERVICE, &_gss_service);
	free(tmp);
	NSLog(@"gss_import_name(): 0x%x (min:%i)", maj, min);
	if (maj != GSS_S_COMPLETE)
		return;
    NSLog(@"setService: OK");
}

- (void)unsetService
{
	OM_uint32		min;

	gss_release_name(&min, &_gss_service);
	_gss_service = nil;
}

- (BOOL)connectWithPassword:(NSString*)pass
{
	krb5_get_init_creds_opt	opt;
	krb5_creds				cred;
	krb5_error_code			ret;
	char					*tmpass;

	tmpass = strdup([pass cStringUsingEncoding:NSASCIIStringEncoding]);
	krb5_get_init_creds_opt_init(&opt);
	ret = krb5_get_init_creds_password(_context, &cred, _principal, tmpass,
									   krb5_prompter_posix, NULL, 0, NULL, &opt); // in getNewCred
	free(tmpass);
	NSLog(@" result krb5_get_init_creds_password():%i", ret);
	if (ret < 0L)
	{
		[self stringWithKrbError:ret];
		return (ret);
	}
	ret = krb5_cc_initialize(_context, _ccache, _principal); // in getNewCred
	NSLog(@" result krb5_cc_initialize():%i", ret);
	if (ret < 0L)
	{
		[self stringWithKrbError:ret];
		return (ret);
	}
	ret = krb5_cc_store_cred(_context, _ccache, &cred); // in getNewCred
	NSLog(@" result krb5_cc_store_cred():%i", ret);
	if (ret < 0L)
	{
		[self stringWithKrbError:ret];
		return (ret);
	}
	krb5_free_cred_contents(_context, &cred); // in getNewCred
    NSLog(@" connectWithPassword: OK");
	//krb5_free_creds(_context, &cred); // in getNewCred
	return (YES);
}

- (void)encode64Data:(const char*)src length:(int)length to:(char **)dest
{
	static const char	KRBMYBASE64END = '=';
	static const char*	KRBMYBASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	int  dlength;
	int toto;
	char *titi;
	// Uchar test[4];
	int i;
	int j;
	
	dlength = (length / 3) + (length % 3 ? 1 : 0);
	(*dest) = malloc(sizeof(**dest) * (dlength * 4 + 1));
	(*dest)[dlength * 4] = '\0';
	for (i = 0; i < dlength; ++i)
	{
		for (toto = 0, j = 0; j < 3 && (i*3) + j < length; ++j)
		{
			toto |= (0xFF & src[3 * i + j]) << ((2 - j)*8);
		}
		titi = ((*dest) + 4 * i);
		titi[0] = KRBMYBASE64[(toto >> 18) & 0x3F];
		titi[1] = KRBMYBASE64[((toto >> 12) & 0x3F)];
		titi[2] = (j == 1 ? KRBMYBASE64END : KRBMYBASE64[(toto >> 6) & 0x3F]);
		titi[3] = (j == 3 ? KRBMYBASE64[toto & 0x3F] : KRBMYBASE64END);
	}
}

- (NSString*)token;
{
	OM_uint32				min;
	OM_uint32				maj;
	gss_ctx_id_t			ctx = GSS_C_NO_CONTEXT;
	gss_buffer_t			itoken = GSS_C_NO_BUFFER;
	gss_buffer_desc			otoken;

	otoken.length = 0;

	maj = gss_init_sec_context(&(min), GSS_C_NO_CREDENTIAL, &ctx,
							   _gss_service, GSS_C_NO_OID, 0, 3600 * 24,
							   GSS_C_NO_CHANNEL_BINDINGS, itoken,
							   NULL, &(otoken), NULL, NULL); // in getToken
	NSLog(@"gss_init_sec_context(): 0x%x (min:%i)", maj, min);
	if (maj != GSS_S_COMPLETE)
		return (nil);
    NSData* data = [NSData dataWithBytes:otoken.value length:otoken.length];
    NSString* encodedToken = [data encodeBase64];
    NSLog(@"token fetched\n%@\n", encodedToken);
    return encodedToken;
}

- (void)release
{
	[self unsetPrincipal];
	[self unsetService];
	krb5_cc_close(_context, _ccache);
	krb5_free_context(_context);
}

@end

krb_msgs	krb_all_msgs[] = 
{
	{KRB5KDC_ERR_NONE, "KRB5KDC_ERR_NONE"},
	{KRB5KDC_ERR_NAME_EXP, "KRB5KDC_ERR_NAME_EXP"},
	{KRB5KDC_ERR_SERVICE_EXP, "KRB5KDC_ERR_SERVICE_EXP"},
	{KRB5KDC_ERR_BAD_PVNO, "KRB5KDC_ERR_BAD_PVNO"},
	{KRB5KDC_ERR_C_OLD_MAST_KVNO, "KRB5KDC_ERR_C_OLD_MAST_KVNO"},
	{KRB5KDC_ERR_S_OLD_MAST_KVNO, "KRB5KDC_ERR_S_OLD_MAST_KVNO"},
	{KRB5KDC_ERR_C_PRINCIPAL_UNKNOWN, "KRB5KDC_ERR_C_PRINCIPAL_UNKNOWN"},
	{KRB5KDC_ERR_S_PRINCIPAL_UNKNOWN, "KRB5KDC_ERR_S_PRINCIPAL_UNKNOWN"},
	{KRB5KDC_ERR_PRINCIPAL_NOT_UNIQUE, "KRB5KDC_ERR_PRINCIPAL_NOT_UNIQUE"},
	{KRB5KDC_ERR_NULL_KEY, "KRB5KDC_ERR_NULL_KEY"},
	{KRB5KDC_ERR_CANNOT_POSTDATE, "KRB5KDC_ERR_CANNOT_POSTDATE"},
	{KRB5KDC_ERR_NEVER_VALID, "KRB5KDC_ERR_NEVER_VALID"},
	{KRB5KDC_ERR_POLICY, "KRB5KDC_ERR_POLICY"},
	{KRB5KDC_ERR_BADOPTION, "KRB5KDC_ERR_BADOPTION"},
	{KRB5KDC_ERR_ETYPE_NOSUPP, "KRB5KDC_ERR_ETYPE_NOSUPP"},
	{KRB5KDC_ERR_SUMTYPE_NOSUPP, "KRB5KDC_ERR_SUMTYPE_NOSUPP"},
	{KRB5KDC_ERR_PADATA_TYPE_NOSUPP, "KRB5KDC_ERR_PADATA_TYPE_NOSUPP"},
	{KRB5KDC_ERR_TRTYPE_NOSUPP, "KRB5KDC_ERR_TRTYPE_NOSUPP"},
	{KRB5KDC_ERR_CLIENT_REVOKED, "KRB5KDC_ERR_CLIENT_REVOKED"},
	{KRB5KDC_ERR_SERVICE_REVOKED, "KRB5KDC_ERR_SERVICE_REVOKED"},
	{KRB5KDC_ERR_TGT_REVOKED, "KRB5KDC_ERR_TGT_REVOKED"},
	{KRB5KDC_ERR_CLIENT_NOTYET, "KRB5KDC_ERR_CLIENT_NOTYET"},
	{KRB5KDC_ERR_SERVICE_NOTYET, "KRB5KDC_ERR_SERVICE_NOTYET"},
	{KRB5KDC_ERR_KEY_EXP, "KRB5KDC_ERR_KEY_EXP"},
	{KRB5KDC_ERR_PREAUTH_FAILED, "KRB5KDC_ERR_PREAUTH_FAILED"},
	{KRB5KDC_ERR_PREAUTH_REQUIRED, "KRB5KDC_ERR_PREAUTH_REQUIRED"},
	{KRB5KDC_ERR_SERVER_NOMATCH, "KRB5KDC_ERR_SERVER_NOMATCH"},
	{KRB5PLACEHOLD_27, "KRB5PLACEHOLD_27"},
	{KRB5PLACEHOLD_28, "KRB5PLACEHOLD_28"},
	{KRB5PLACEHOLD_29, "KRB5PLACEHOLD_29"},
	{KRB5PLACEHOLD_30, "KRB5PLACEHOLD_30"},
	{KRB5KRB_AP_ERR_BAD_INTEGRITY, "KRB5KRB_AP_ERR_BAD_INTEGRITY"},
	{KRB5KRB_AP_ERR_TKT_EXPIRED, "KRB5KRB_AP_ERR_TKT_EXPIRED"},
	{KRB5KRB_AP_ERR_TKT_NYV, "KRB5KRB_AP_ERR_TKT_NYV"},
	{KRB5KRB_AP_ERR_REPEAT, "KRB5KRB_AP_ERR_REPEAT"},
	{KRB5KRB_AP_ERR_NOT_US, "KRB5KRB_AP_ERR_NOT_US"},
	{KRB5KRB_AP_ERR_BADMATCH, "KRB5KRB_AP_ERR_BADMATCH"},
	{KRB5KRB_AP_ERR_SKEW, "KRB5KRB_AP_ERR_SKEW"},
	{KRB5KRB_AP_ERR_BADADDR, "KRB5KRB_AP_ERR_BADADDR"},
	{KRB5KRB_AP_ERR_BADVERSION, "KRB5KRB_AP_ERR_BADVERSION"},
	{KRB5KRB_AP_ERR_MSG_TYPE, "KRB5KRB_AP_ERR_MSG_TYPE"},
	{KRB5KRB_AP_ERR_MODIFIED, "KRB5KRB_AP_ERR_MODIFIED"},
	{KRB5KRB_AP_ERR_BADORDER, "KRB5KRB_AP_ERR_BADORDER"},
	{KRB5KRB_AP_ERR_ILL_CR_TKT, "KRB5KRB_AP_ERR_ILL_CR_TKT"},
	{KRB5KRB_AP_ERR_BADKEYVER, "KRB5KRB_AP_ERR_BADKEYVER"},
	{KRB5KRB_AP_ERR_NOKEY, "KRB5KRB_AP_ERR_NOKEY"},
	{KRB5KRB_AP_ERR_MUT_FAIL, "KRB5KRB_AP_ERR_MUT_FAIL"},
	{KRB5KRB_AP_ERR_BADDIRECTION, "KRB5KRB_AP_ERR_BADDIRECTION"},
	{KRB5KRB_AP_ERR_METHOD, "KRB5KRB_AP_ERR_METHOD"},
	{KRB5KRB_AP_ERR_BADSEQ, "KRB5KRB_AP_ERR_BADSEQ"},
	{KRB5KRB_AP_ERR_INAPP_CKSUM, "KRB5KRB_AP_ERR_INAPP_CKSUM"},
	{KRB5KRB_AP_PATH_NOT_ACCEPTED, "KRB5KRB_AP_PATH_NOT_ACCEPTED"},
	{KRB5KRB_ERR_RESPONSE_TOO_BIG, "KRB5KRB_ERR_RESPONSE_TOO_BIG"},
	{KRB5PLACEHOLD_53, "KRB5PLACEHOLD_53"},
	{KRB5PLACEHOLD_54, "KRB5PLACEHOLD_54"},
	{KRB5PLACEHOLD_55, "KRB5PLACEHOLD_55"},
	{KRB5PLACEHOLD_56, "KRB5PLACEHOLD_56"},
	{KRB5PLACEHOLD_57, "KRB5PLACEHOLD_57"},
	{KRB5PLACEHOLD_58, "KRB5PLACEHOLD_58"},
	{KRB5PLACEHOLD_59, "KRB5PLACEHOLD_59"},
	{KRB5KRB_ERR_GENERIC, "KRB5KRB_ERR_GENERIC"},
	{KRB5KRB_ERR_FIELD_TOOLONG, "KRB5KRB_ERR_FIELD_TOOLONG"},
//	{KRB5KDC_ERR_CLIENT_NOT_TRUSTED, "KRB5KDC_ERR_CLIENT_NOT_TRUSTED"},
//	{KRB5KDC_ERR_KDC_NOT_TRUSTED, "KRB5KDC_ERR_KDC_NOT_TRUSTED"},
//	{KRB5KDC_ERR_INVALID_SIG, "KRB5KDC_ERR_INVALID_SIG"},
//	{KRB5KDC_ERR_DH_KEY_PARAMETERS_NOT_ACCEPTED, "KRB5KDC_ERR_DH_KEY_PARAMETERS_NOT_ACCEPTED"},
//	{KRB5KDC_ERR_CERTIFICATE_MISMATCH, "KRB5KDC_ERR_CERTIFICATE_MISMATCH"},
	{KRB5PLACEHOLD_67, "KRB5PLACEHOLD_67"},
	{KRB5PLACEHOLD_68, "KRB5PLACEHOLD_68"},
	{KRB5PLACEHOLD_69, "KRB5PLACEHOLD_69"},
//	{KRB5KDC_ERR_CANT_VERIFY_CERTIFICATE, "KRB5KDC_ERR_CANT_VERIFY_CERTIFICATE"},
//	{KRB5KDC_ERR_INVALID_CERTIFICATE, "KRB5KDC_ERR_INVALID_CERTIFICATE"},
//	{KRB5KDC_ERR_REVOKED_CERTIFICATE, "KRB5KDC_ERR_REVOKED_CERTIFICATE"},
//	{KRB5KDC_ERR_REVOCATION_STATUS_UNKNOWN, "KRB5KDC_ERR_REVOCATION_STATUS_UNKNOWN"},
//	{KRB5KDC_ERR_REVOCATION_STATUS_UNAVAILABLE, "KRB5KDC_ERR_REVOCATION_STATUS_UNAVAILABLE"},
//	{KRB5KDC_ERR_CLIENT_NAME_MISMATCH, "KRB5KDC_ERR_CLIENT_NAME_MISMATCH"},
//	{KRB5KDC_ERR_KDC_NAME_MISMATCH, "KRB5KDC_ERR_KDC_NAME_MISMATCH"},
//	{KRB5KDC_ERR_INCONSISTENT_KEY_PURPOSE, "KRB5KDC_ERR_INCONSISTENT_KEY_PURPOSE"},
//	{KRB5KDC_ERR_DIGEST_IN_CERT_NOT_ACCEPTED, "KRB5KDC_ERR_DIGEST_IN_CERT_NOT_ACCEPTED"},
//	{KRB5KDC_ERR_PA_CHECKSUM_MUST_BE_INCLUDED, "KRB5KDC_ERR_PA_CHECKSUM_MUST_BE_INCLUDED"},
//	{KRB5KDC_ERR_DIGEST_IN_SIGNED_DATA_NOT_ACCEPTED, "KRB5KDC_ERR_DIGEST_IN_SIGNED_DATA_NOT_ACCEPTED"},
//	{KRB5KDC_ERR_PUBLIC_KEY_ENCRYPTION_NOT_SUPPORTED, "KRB5KDC_ERR_PUBLIC_KEY_ENCRYPTION_NOT_SUPPORTED"},
	{KRB5PLACEHOLD_82, "KRB5PLACEHOLD_82"},
	{KRB5PLACEHOLD_83, "KRB5PLACEHOLD_83"},
	{KRB5PLACEHOLD_84, "KRB5PLACEHOLD_84"},
	{KRB5PLACEHOLD_85, "KRB5PLACEHOLD_85"},
	{KRB5PLACEHOLD_86, "KRB5PLACEHOLD_86"},
	{KRB5PLACEHOLD_87, "KRB5PLACEHOLD_87"},
	{KRB5PLACEHOLD_88, "KRB5PLACEHOLD_88"},
	{KRB5PLACEHOLD_89, "KRB5PLACEHOLD_89"},
	{KRB5PLACEHOLD_90, "KRB5PLACEHOLD_90"},
	{KRB5PLACEHOLD_91, "KRB5PLACEHOLD_91"},
	{KRB5PLACEHOLD_92, "KRB5PLACEHOLD_92"},
	{KRB5PLACEHOLD_93, "KRB5PLACEHOLD_93"},
	{KRB5PLACEHOLD_94, "KRB5PLACEHOLD_94"},
	{KRB5PLACEHOLD_95, "KRB5PLACEHOLD_95"},
	{KRB5PLACEHOLD_96, "KRB5PLACEHOLD_96"},
	{KRB5PLACEHOLD_97, "KRB5PLACEHOLD_97"},
	{KRB5PLACEHOLD_98, "KRB5PLACEHOLD_98"},
	{KRB5PLACEHOLD_99, "KRB5PLACEHOLD_99"},
	{KRB5PLACEHOLD_100, "KRB5PLACEHOLD_100"},
	{KRB5PLACEHOLD_101, "KRB5PLACEHOLD_101"},
	{KRB5PLACEHOLD_102, "KRB5PLACEHOLD_102"},
	{KRB5PLACEHOLD_103, "KRB5PLACEHOLD_103"},
	{KRB5PLACEHOLD_104, "KRB5PLACEHOLD_104"},
	{KRB5PLACEHOLD_105, "KRB5PLACEHOLD_105"},
	{KRB5PLACEHOLD_106, "KRB5PLACEHOLD_106"},
	{KRB5PLACEHOLD_107, "KRB5PLACEHOLD_107"},
	{KRB5PLACEHOLD_108, "KRB5PLACEHOLD_108"},
	{KRB5PLACEHOLD_109, "KRB5PLACEHOLD_109"},
	{KRB5PLACEHOLD_110, "KRB5PLACEHOLD_110"},
	{KRB5PLACEHOLD_111, "KRB5PLACEHOLD_111"},
	{KRB5PLACEHOLD_112, "KRB5PLACEHOLD_112"},
	{KRB5PLACEHOLD_113, "KRB5PLACEHOLD_113"},
	{KRB5PLACEHOLD_114, "KRB5PLACEHOLD_114"},
	{KRB5PLACEHOLD_115, "KRB5PLACEHOLD_115"},
	{KRB5PLACEHOLD_116, "KRB5PLACEHOLD_116"},
	{KRB5PLACEHOLD_117, "KRB5PLACEHOLD_117"},
	{KRB5PLACEHOLD_118, "KRB5PLACEHOLD_118"},
	{KRB5PLACEHOLD_119, "KRB5PLACEHOLD_119"},
	{KRB5PLACEHOLD_120, "KRB5PLACEHOLD_120"},
	{KRB5PLACEHOLD_121, "KRB5PLACEHOLD_121"},
	{KRB5PLACEHOLD_122, "KRB5PLACEHOLD_122"},
	{KRB5PLACEHOLD_123, "KRB5PLACEHOLD_123"},
	{KRB5PLACEHOLD_124, "KRB5PLACEHOLD_124"},
	{KRB5PLACEHOLD_125, "KRB5PLACEHOLD_125"},
	{KRB5PLACEHOLD_126, "KRB5PLACEHOLD_126"},
	{KRB5PLACEHOLD_127, "KRB5PLACEHOLD_127"},
	{KRB5_ERR_RCSID, "KRB5_ERR_RCSID"},
	{KRB5_LIBOS_BADLOCKFLAG, "KRB5_LIBOS_BADLOCKFLAG"},
	{KRB5_LIBOS_CANTREADPWD, "KRB5_LIBOS_CANTREADPWD"},
	{KRB5_LIBOS_BADPWDMATCH, "KRB5_LIBOS_BADPWDMATCH"},
	{KRB5_LIBOS_PWDINTR, "KRB5_LIBOS_PWDINTR"},
	{KRB5_PARSE_ILLCHAR, "KRB5_PARSE_ILLCHAR"},
	{KRB5_PARSE_MALFORMED, "KRB5_PARSE_MALFORMED"},
	{KRB5_CONFIG_CANTOPEN, "KRB5_CONFIG_CANTOPEN"},
	{KRB5_CONFIG_BADFORMAT, "KRB5_CONFIG_BADFORMAT"},
	{KRB5_CONFIG_NOTENUFSPACE, "KRB5_CONFIG_NOTENUFSPACE"},
	{KRB5_BADMSGTYPE, "KRB5_BADMSGTYPE"},
	{KRB5_CC_BADNAME, "KRB5_CC_BADNAME"},
	{KRB5_CC_UNKNOWN_TYPE, "KRB5_CC_UNKNOWN_TYPE"},
	{KRB5_CC_NOTFOUND, "KRB5_CC_NOTFOUND"},
	{KRB5_CC_END, "KRB5_CC_END"},
	{KRB5_NO_TKT_SUPPLIED, "KRB5_NO_TKT_SUPPLIED"},
	{KRB5KRB_AP_WRONG_PRINC, "KRB5KRB_AP_WRONG_PRINC"},
	{KRB5KRB_AP_ERR_TKT_INVALID, "KRB5KRB_AP_ERR_TKT_INVALID"},
	{KRB5_PRINC_NOMATCH, "KRB5_PRINC_NOMATCH"},
	{KRB5_KDCREP_MODIFIED, "KRB5_KDCREP_MODIFIED"},
	{KRB5_KDCREP_SKEW, "KRB5_KDCREP_SKEW"},
	{KRB5_IN_TKT_REALM_MISMATCH, "KRB5_IN_TKT_REALM_MISMATCH"},
	{KRB5_PROG_ETYPE_NOSUPP, "KRB5_PROG_ETYPE_NOSUPP"},
	{KRB5_PROG_KEYTYPE_NOSUPP, "KRB5_PROG_KEYTYPE_NOSUPP"},
	{KRB5_WRONG_ETYPE, "KRB5_WRONG_ETYPE"},
	{KRB5_PROG_SUMTYPE_NOSUPP, "KRB5_PROG_SUMTYPE_NOSUPP"},
	{KRB5_REALM_UNKNOWN, "KRB5_REALM_UNKNOWN"},
	{KRB5_SERVICE_UNKNOWN, "KRB5_SERVICE_UNKNOWN"},
	{KRB5_KDC_UNREACH, "KRB5_KDC_UNREACH"},
	{KRB5_NO_LOCALNAME, "KRB5_NO_LOCALNAME"},
	{KRB5_MUTUAL_FAILED, "KRB5_MUTUAL_FAILED"},
	{KRB5_RC_TYPE_EXISTS, "KRB5_RC_TYPE_EXISTS"},
	{KRB5_RC_MALLOC, "KRB5_RC_MALLOC"},
	{KRB5_RC_TYPE_NOTFOUND, "KRB5_RC_TYPE_NOTFOUND"},
	{KRB5_RC_UNKNOWN, "KRB5_RC_UNKNOWN"},
	{KRB5_RC_REPLAY, "KRB5_RC_REPLAY"},
	{KRB5_RC_IO, "KRB5_RC_IO"},
	{KRB5_RC_NOIO, "KRB5_RC_NOIO"},
	{KRB5_RC_PARSE, "KRB5_RC_PARSE"},
	{KRB5_RC_IO_EOF, "KRB5_RC_IO_EOF"},
	{KRB5_RC_IO_MALLOC, "KRB5_RC_IO_MALLOC"},
	{KRB5_RC_IO_PERM, "KRB5_RC_IO_PERM"},
	{KRB5_RC_IO_IO, "KRB5_RC_IO_IO"},
	{KRB5_RC_IO_UNKNOWN, "KRB5_RC_IO_UNKNOWN"},
	{KRB5_RC_IO_SPACE, "KRB5_RC_IO_SPACE"},
	{KRB5_TRANS_CANTOPEN, "KRB5_TRANS_CANTOPEN"},
	{KRB5_TRANS_BADFORMAT, "KRB5_TRANS_BADFORMAT"},
	{KRB5_LNAME_CANTOPEN, "KRB5_LNAME_CANTOPEN"},
	{KRB5_LNAME_NOTRANS, "KRB5_LNAME_NOTRANS"},
	{KRB5_LNAME_BADFORMAT, "KRB5_LNAME_BADFORMAT"},
	{KRB5_CRYPTO_INTERNAL, "KRB5_CRYPTO_INTERNAL"},
	{KRB5_KT_BADNAME, "KRB5_KT_BADNAME"},
	{KRB5_KT_UNKNOWN_TYPE, "KRB5_KT_UNKNOWN_TYPE"},
	{KRB5_KT_NOTFOUND, "KRB5_KT_NOTFOUND"},
	{KRB5_KT_END, "KRB5_KT_END"},
	{KRB5_KT_NOWRITE, "KRB5_KT_NOWRITE"},
	{KRB5_KT_IOERR, "KRB5_KT_IOERR"},
	{KRB5_NO_TKT_IN_RLM, "KRB5_NO_TKT_IN_RLM"},
	{KRB5DES_BAD_KEYPAR, "KRB5DES_BAD_KEYPAR"},
	{KRB5DES_WEAK_KEY, "KRB5DES_WEAK_KEY"},
	{KRB5_BAD_ENCTYPE, "KRB5_BAD_ENCTYPE"},
	{KRB5_BAD_KEYSIZE, "KRB5_BAD_KEYSIZE"},
	{KRB5_BAD_MSIZE, "KRB5_BAD_MSIZE"},
	{KRB5_CC_TYPE_EXISTS, "KRB5_CC_TYPE_EXISTS"},
	{KRB5_KT_TYPE_EXISTS, "KRB5_KT_TYPE_EXISTS"},
	{KRB5_CC_IO, "KRB5_CC_IO"},
	{KRB5_FCC_PERM, "KRB5_FCC_PERM"},
	{KRB5_FCC_NOFILE, "KRB5_FCC_NOFILE"},
	{KRB5_FCC_INTERNAL, "KRB5_FCC_INTERNAL"},
	{KRB5_CC_WRITE, "KRB5_CC_WRITE"},
	{KRB5_CC_NOMEM, "KRB5_CC_NOMEM"},
	{KRB5_CC_FORMAT, "KRB5_CC_FORMAT"},
	{KRB5_CC_NOT_KTYPE, "KRB5_CC_NOT_KTYPE"},
	{KRB5_INVALID_FLAGS, "KRB5_INVALID_FLAGS"},
	{KRB5_NO_2ND_TKT, "KRB5_NO_2ND_TKT"},
	{KRB5_NOCREDS_SUPPLIED, "KRB5_NOCREDS_SUPPLIED"},
	{KRB5_SENDAUTH_BADAUTHVERS, "KRB5_SENDAUTH_BADAUTHVERS"},
	{KRB5_SENDAUTH_BADAPPLVERS, "KRB5_SENDAUTH_BADAPPLVERS"},
	{KRB5_SENDAUTH_BADRESPONSE, "KRB5_SENDAUTH_BADRESPONSE"},
	{KRB5_SENDAUTH_REJECTED, "KRB5_SENDAUTH_REJECTED"},
	{KRB5_PREAUTH_BAD_TYPE, "KRB5_PREAUTH_BAD_TYPE"},
	{KRB5_PREAUTH_NO_KEY, "KRB5_PREAUTH_NO_KEY"},
	{KRB5_PREAUTH_FAILED, "KRB5_PREAUTH_FAILED"},
	{KRB5_RCACHE_BADVNO, "KRB5_RCACHE_BADVNO"},
	{KRB5_CCACHE_BADVNO, "KRB5_CCACHE_BADVNO"},
	{KRB5_KEYTAB_BADVNO, "KRB5_KEYTAB_BADVNO"},
	{KRB5_PROG_ATYPE_NOSUPP, "KRB5_PROG_ATYPE_NOSUPP"},
	{KRB5_RC_REQUIRED, "KRB5_RC_REQUIRED"},
	{KRB5_ERR_BAD_HOSTNAME, "KRB5_ERR_BAD_HOSTNAME"},
	{KRB5_ERR_HOST_REALM_UNKNOWN, "KRB5_ERR_HOST_REALM_UNKNOWN"},
	{KRB5_SNAME_UNSUPP_NAMETYPE, "KRB5_SNAME_UNSUPP_NAMETYPE"},
	{KRB5KRB_AP_ERR_V4_REPLY, "KRB5KRB_AP_ERR_V4_REPLY"},
	{KRB5_REALM_CANT_RESOLVE, "KRB5_REALM_CANT_RESOLVE"},
	{KRB5_TKT_NOT_FORWARDABLE, "KRB5_TKT_NOT_FORWARDABLE"},
	{KRB5_FWD_BAD_PRINCIPAL, "KRB5_FWD_BAD_PRINCIPAL"},
	{KRB5_GET_IN_TKT_LOOP, "KRB5_GET_IN_TKT_LOOP"},
	{KRB5_CONFIG_NODEFREALM, "KRB5_CONFIG_NODEFREALM"},
	{KRB5_SAM_UNSUPPORTED, "KRB5_SAM_UNSUPPORTED"},
	{KRB5_SAM_INVALID_ETYPE, "KRB5_SAM_INVALID_ETYPE"},
	{KRB5_SAM_NO_CHECKSUM, "KRB5_SAM_NO_CHECKSUM"},
	{KRB5_SAM_BAD_CHECKSUM, "KRB5_SAM_BAD_CHECKSUM"},
	{KRB5_KT_NAME_TOOLONG, "KRB5_KT_NAME_TOOLONG"},
	{KRB5_KT_KVNONOTFOUND, "KRB5_KT_KVNONOTFOUND"},
	{KRB5_APPL_EXPIRED, "KRB5_APPL_EXPIRED"},
	{KRB5_LIB_EXPIRED, "KRB5_LIB_EXPIRED"},
	{KRB5_CHPW_PWDNULL, "KRB5_CHPW_PWDNULL"},
	{KRB5_CHPW_FAIL, "KRB5_CHPW_FAIL"},
	{KRB5_KT_FORMAT, "KRB5_KT_FORMAT"},
	{KRB5_NOPERM_ETYPE, "KRB5_NOPERM_ETYPE"},
	{KRB5_CONFIG_ETYPE_NOSUPP, "KRB5_CONFIG_ETYPE_NOSUPP"},
	{KRB5_OBSOLETE_FN, "KRB5_OBSOLETE_FN"},
	{KRB5_EAI_FAIL, "KRB5_EAI_FAIL"},
	{KRB5_EAI_NODATA, "KRB5_EAI_NODATA"},
	{KRB5_EAI_NONAME, "KRB5_EAI_NONAME"},
	{KRB5_EAI_SERVICE, "KRB5_EAI_SERVICE"},
	{KRB5_ERR_NUMERIC_REALM, "KRB5_ERR_NUMERIC_REALM"},
	{KRB5_ERR_BAD_S2K_PARAMS, "KRB5_ERR_BAD_S2K_PARAMS"},
	{KRB5_ERR_NO_SERVICE, "KRB5_ERR_NO_SERVICE"},
	{KRB5_CC_READONLY, "KRB5_CC_READONLY"},
	{KRB5_CC_NOSUPP, "KRB5_CC_NOSUPP"},
	{KRB5_DELTAT_BADFORMAT, "KRB5_DELTAT_BADFORMAT"},
//	{KRB5_PLUGIN_NO_HANDLE, "KRB5_PLUGIN_NO_HANDLE"},
//	{KRB5_PLUGIN_OP_NOTSUPP, "KRB5_PLUGIN_OP_NOTSUPP"},
	{ERROR_TABLE_BASE_krb5, "ERROR_TABLE_BASE_krb5"},
	{ 0, nil}
};

//char*	retrieve_token(char *login, char *passwd, gss_ctx_id_t *ctx)
//{
//	gss_name_t	gss_name;
//	
//	import_name(&gss_name);
//	if (create_ticket(login, passwd) < 0)
//		return (NULL);
//	return (init_context(gss_name, ctx));
//}
//
//void			import_name(gss_name_t *gss_name)
//{
//	OM_uint32		min;
//	OM_uint32		maj;
//	gss_buffer_desc	buf;
//	
//	buf.value = (Uchar *) strdup(SERVICE_NAME);
//	buf.length = strlen((const char*)buf.value) + 1;
//	maj = gss_import_name(&min, &buf, GSS_C_NT_HOSTBASED_SERVICE, gss_name);
//}
//
//int			create_ticket(char *login, char *passwd)
//{
//	krb5_context		context;
//	krb5_ccache		ccache;
//	krb5_principal	principal;
//	int			ret;
//	
//	krb5_init_context(&context);
//	krb5_parse_name(context, login, &principal);
//	krb5_cc_default(context, &ccache);
//	ret = get_new_tickets(context, principal, ccache, passwd);
//	krb5_cc_close(context, ccache);
//	krb5_free_principal(context, principal);
//	krb5_free_context(context);
//	return (ret);
//}
//
//int get_new_tickets(krb5_context c, krb5_principal p, krb5_ccache cc, char *pwd)
//{
//	t_krb5			k;
//	
//	k.start_time = 0;
//	krb5_get_init_creds_opt_init (&(k.opt));
//	//  krb5_get_init_creds_opt_set_default_flags(c, "get_krb_token",
//	//	p->realm, &(k.opt));
//	k.ret = krb5_get_init_creds_password(c, &(k.cred), p, pwd,
//										 krb5_prompter_posix, NULL,
//										 (k.start_time), NULL, &(k.opt));
//	switch(k.ret)
//    {
//		case 0:
//			k.error = 0;
//			break;
//		case KRB5KRB_AP_ERR_BAD_INTEGRITY:
//		case KRB5KRB_AP_ERR_MODIFIED:
//			return (-1);
//		default:
//			return (-1);
//    }
//	krb5_cc_initialize(c, cc, k.cred.client);
//	krb5_cc_store_cred(c, cc, &(k.cred));
//	//  krb5_free_creds_contents(c, &(k.cred));
//	return (k.error);
//}
//
//char		*init_context(gss_name_t gss_name, void *ctx)
//{
//	t_pln			var;
//	char			*ret;
//	
//	var.itoken = GSS_C_NO_BUFFER;
//	var.maj = gss_init_sec_context(&(var.min), GSS_C_NO_CREDENTIAL, (void**)ctx,
//								   gss_name, GSS_C_NO_OID, 0, DUREE_VALID,
//								   GSS_C_NO_CHANNEL_BINDINGS, var.itoken,
//								   NULL, &(var.otoken), NULL, NULL);
//	if (var.maj != GSS_S_COMPLETE)
//		return (NULL);
//	mybase64_encode(var.otoken.value, var.otoken.length, &ret);
//	return (ret);
//}
