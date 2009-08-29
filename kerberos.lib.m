

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "kerberos.lib.h"

#define SERVICE_NAME "host@ns-server.epitech.net"

#define NETSOUL_SERVICE_NAME "host@ns-server.epitech.net"
#define NETSOUL_REALM "EPITECH.NET"

Uchar*          retrieve_token(char* login, char* passwd, gss_ctx_id_t *ctx)
{
    gss_name_t  gss_name;
    Uchar*      token;
    int         ret;

    import_name(&gss_name);
    ret = create_ticket(login, passwd);
    if (ret < 0)
    {
        return (NULL);
    }
    token = init_context(gss_name, ctx);
    return (token);
}

void                import_name(gss_name_t *gss_name)
{
    OM_uint32       min;
    OM_uint32       maj;
    gss_buffer_desc buf;

    buf.value = (Uchar *)strdup(NETSOUL_SERVICE_NAME);
    buf.length = strlen(buf.value) + 1;
    maj = gss_import_name(&min, &buf, GSS_C_NT_HOSTBASED_SERVICE, gss_name);
}

void    base64_encode(const char* src, int length, char** destination)
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
	(*destination) = malloc(sizeof(**destination) * (dlength * 4 + 1));
	(*destination)[dlength * 4] = '\0';
	for (i = 0; i < dlength; ++i)
	{
		for (toto = 0, j = 0; j < 3 && (i*3) + j < length; ++j)
		{
			toto |= (0xFF & src[3 * i + j]) << ((2 - j)*8);
		}
		titi = ((*destination) + 4 * i);
		titi[0] = KRBMYBASE64[(toto >> 18) & 0x3F];
		titi[1] = KRBMYBASE64[((toto >> 12) & 0x3F)];
		titi[2] = (j == 1 ? KRBMYBASE64END : KRBMYBASE64[(toto >> 6) & 0x3F]);
		titi[3] = (j == 3 ? KRBMYBASE64[toto & 0x3F] : KRBMYBASE64END);
	}
}


Uchar*      init_context(gss_name_t gss_name, void *ctx)
{
    t_pln   var;
    Uchar*  ret;

    var.itoken = GSS_C_NO_BUFFER;
    var.maj = gss_init_sec_context(&(var.min), GSS_C_NO_CREDENTIAL, ctx,
                                   gss_name, GSS_C_NO_OID, 0, DUREE_VALID,
                                   GSS_C_NO_CHANNEL_BINDINGS, var.itoken,
                                   NULL, &(var.otoken), NULL, NULL);
    if (var.maj != GSS_S_COMPLETE)
        return (NULL);
    base64_encode(var.otoken.value, var.otoken.length, (char**)&ret);
    return (ret);
}

int         get_new_tickets(krb5_context c, krb5_principal p, krb5_ccache cc, char *pwd)
{
    t_krb5  k;

    k.start_time = 0;
    krb5_get_init_creds_opt_init(&(k.opt));
//    krb5_get_init_creds_opt_set_default_flags(c, "get_krb_token", p->realm, &(k.opt));
    k.ret = krb5_get_init_creds_password(c, &(k.cred), p, pwd,
                                         krb5_prompter_posix, NULL,
                                         (k.start_time), NULL, &(k.opt));
    switch(k.ret)
    {
        case 0:
            k.error = 0;
            break;
        case KRB5KRB_AP_ERR_BAD_INTEGRITY:
        case KRB5KRB_AP_ERR_MODIFIED:
            return (-1);
        default:
            return (-1);
    }
    krb5_cc_initialize(c, cc, k.cred.client);
    krb5_cc_store_cred(c, cc, &(k.cred));
    krb5_free_creds(c, &(k.cred));
    return (k.error);
}

int                 create_ticket(char* login, char* passwd)
{
    krb5_context    context;
    krb5_ccache     ccache;
    krb5_principal  principal;
    int             ret;

    krb5_init_context(&context);
    krb5_parse_name(context, login, &principal);
    krb5_set_principal_realm(context, principal, NETSOUL_REALM);
    krb5_cc_default(context, &ccache);
    ret = get_new_tickets(context, principal, ccache, passwd);
    krb5_cc_close(context, ccache);
    krb5_free_principal(context, principal);
    krb5_free_context(context);
    return (ret);
}