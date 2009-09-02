

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "kerberos.lib.h"

#define SERVICE_NAME "host@ns-server.epitech.net"

#define NETSOUL_SERVICE_NAME "host@ns-server.epitech.net"
#define NETSOUL_REALM "EPITECH.NET"

Uchar*          retrieve_token(char* login, char* passwd)
{
    Uchar*      token;
    int         ret;

    ret = create_ticket(login, passwd);
    if (ret < 0)
    {
        return (NULL);
    }
    token = get_token();
    return (token);
}

int                 create_ticket(char* login, char* passwd)
{
    krb5_principal  principal = NULL;
    krb5_context    context = NULL;
    krb5_ccache     ccache;
    krb5_error_code error;
    char*           default_realm;
    int             ret = 0;
    
    krb5_init_context(&context);
    error = krb5_get_default_realm(context, &default_realm);
    if (error)
    {
        krb5_set_default_realm(context, NETSOUL_REALM);
        AILog(@"[AdiumSoul] No default realm set in conf file, setting it to %s", NETSOUL_REALM);
    }
    error = krb5_parse_name(context, login, &principal);
    if (error)
    {
        NSLog(@"[AdiumSoul] Error parsing name: %s", krb5_get_error_message(context, error));
        return (-1);
    }
    krb5_set_principal_realm(context, principal, NETSOUL_REALM);
    krb5_cc_default(context, &ccache);
    ret = get_new_tickets(context, principal, ccache, passwd);
    krb5_cc_close(context, ccache);
    krb5_free_principal(context, principal);
    krb5_free_context(context);
    return (ret);
}

int                         get_new_tickets(krb5_context c, krb5_principal p, krb5_ccache cc, char *pwd)
{
    krb5_error_code         ret;
    krb5_get_init_creds_opt opt;
    krb5_creds              creds;
    int                     error;
    
    memset(&creds, 0, sizeof(creds));
    krb5_get_init_creds_opt_init(&opt);
    ret = krb5_get_init_creds_password(c, &creds, p, pwd, NULL, NULL, 0, NULL, &opt);
    switch(ret)
    {
        case 0:
            error = 0;
            break;
        case KRB5KRB_AP_ERR_BAD_INTEGRITY:
        case KRB5KRB_AP_ERR_MODIFIED:
            return (-1);
        default:
            return (-1);
    }
    krb5_cc_initialize(c, cc, creds.client);
    krb5_cc_store_cred(c, cc, &creds);
    krb5_free_creds(c, &creds);
    return (error);
}

void                import_gss_name(gss_name_t *gss_name)
{
    OM_uint32       min;
    gss_buffer_desc buf;
    
    buf.value = (Uchar *)strdup(NETSOUL_SERVICE_NAME);
    buf.length = strlen(buf.value) + 1;
    gss_import_name(&min, &buf, GSS_C_NT_HOSTBASED_SERVICE, gss_name);
}

Uchar*          get_token()
{
    OM_uint32       min;
    OM_uint32       maj;
    gss_ctx_id_t    ctx = GSS_C_NO_CONTEXT;
    gss_name_t      gss_name;
    gss_buffer_t    itoken;
    gss_buffer_desc otoken;
    Uchar*          ret;
    
    itoken = GSS_C_NO_BUFFER;
    import_gss_name(&gss_name);
    maj = gss_init_sec_context(&min, GSS_C_NO_CREDENTIAL, &ctx, gss_name, GSS_C_NO_OID,
                               0, DUREE_VALID, GSS_C_NO_CHANNEL_BINDINGS, itoken,
                               NULL, &otoken, NULL, NULL);
    if (maj != GSS_S_COMPLETE)
    {
        return (NULL);
    }
    base64_encode(otoken.value, otoken.length, (char**)&ret);
    return (ret);
}

void    base64_encode(const char* src, int length, char** destination)
{
	static const char	KRBMYBASE64END = '=';
	static const char*	KRBMYBASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	int  dlength;
	int toto;
	char *titi;
	int i;
	int j;
	
	dlength = (length / 3) + (length % 3 ? 1 : 0);
	(*destination) = malloc(sizeof(**destination) * (dlength * 4 + 1));
	(*destination)[dlength * 4] = '\0';
	for (i = 0; i < dlength; ++i)
	{
		for (toto = 0, j = 0; j < 3 && (i * 3) + j < length; ++j)
		{
			toto |= (0xFF & src[3 * i + j]) << ((2 - j) * 8);
		}
		titi = ((*destination) + 4 * i);
		titi[0] = KRBMYBASE64[(toto >> 18) & 0x3F];
		titi[1] = KRBMYBASE64[((toto >> 12) & 0x3F)];
		titi[2] = (j == 1 ? KRBMYBASE64END : KRBMYBASE64[(toto >> 6) & 0x3F]);
		titi[3] = (j == 3 ? KRBMYBASE64[toto & 0x3F] : KRBMYBASE64END);
	}
}

BOOL    krb_configured_for_netsoul(void)
{
    krb5_context    context = NULL;
    char**          realms = NULL;
    BOOL            configured = NO;
    
    krb5_init_context(&context);
    krb5_get_host_realm(context, "epitech.net", &realms);
    if (realms && *realms && **realms)
    {
        configured = YES;
    }
    krb5_free_host_realm(context, realms);
    krb5_free_context(context);
    return (configured);
}
