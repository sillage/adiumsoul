
#ifndef _KERBEROS_H_
# define _KERBEROS_H_

#import <Kerberos/Kerberos.h>


# define DUREE_VALID    (8 * 3600)
# define Uchar          unsigned char

typedef struct              s_krb5
{
  krb5_error_code           ret;
  krb5_get_init_creds_opt   opt;
  krb5_creds                cred;
  krb5_deltat               start_time;
  int                       error;
}                           t_krb5;

typedef struct		s_pln
{
    OM_uint32       min;
    OM_uint32       maj;
    OM_uint32       flags;
    OM_uint32       time_rec;
    gss_ctx_id_t    ctx;
    gss_name_t      name;
    gss_OID         mech_type;
    gss_buffer_t    itoken;
    gss_buffer_desc otoken;
}                   t_pln;

Uchar*  retrieve_token(char *login, char *passwd, gss_ctx_id_t *ctx);
void    import_name(gss_name_t *gss_name);
Uchar*  init_context(gss_name_t gss_name, void *ctx);
int     get_new_tickets(krb5_context c, krb5_principal p, krb5_ccache cc, char *pwd);
int     create_ticket(char *login, char *passwd);
void    base64_encode(const char* src, int length, char** destination);

#endif
