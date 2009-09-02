
#ifndef _KERBEROS_H_
# define _KERBEROS_H_

#import <Kerberos/Kerberos.h>


# define DUREE_VALID    (8 * 3600)
# define Uchar          unsigned char

Uchar*  retrieve_token(char *login, char *passwd);
void    import_gss_name(gss_name_t *gss_name);
Uchar*  get_token();
int     get_new_tickets(krb5_context c, krb5_principal p, krb5_ccache cc, char *pwd);
int     create_ticket(char *login, char *passwd);
void    base64_encode(const char* src, int length, char** destination);
BOOL    krb_configured_for_netsoul(void);

#endif
