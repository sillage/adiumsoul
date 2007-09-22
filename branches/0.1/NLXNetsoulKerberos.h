/*
 *  NLXNetsoulKerberos.h
 *  AdiumSoul
 *
 *  Created by Pierre Monod-Broca on 22/09/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include <Kerberos.h>
#include "base64.h"

#define SERVICE_NAME "host@ns-server.epita.fr"
#define SERVICE_SRV	 "ns-server.epita.fr"
#define SERVICE_PORT  4242
#define BUFF_LEN      4096
#define DUREE_VALID   (8 * 3600)

typedef unsigned char Uchar;

typedef struct		s_pln
{
  OM_uint32		min;
  OM_uint32		maj;
  OM_uint32		flags;
  OM_uint32		time_rec;
  gss_ctx_id_t		ctx;
  gss_name_t		name;
  gss_OID		mech_type;
  gss_buffer_t		itoken;
  gss_buffer_desc	otoken;
}			t_pln;

typedef struct	s_user
{
  char		*login;
  int		l_len;
  char		*passwd;
  int		p_len;
  char		*group;
}		t_user;

typedef struct s_krb5
{
  krb5_deltat start_time;
  krb5_creds cred;
  int error;
  int ret;
  krb5_get_init_creds_opt opt;
}     t_krb5;

Uchar   *retrieve_token(char *login, char *passwd, gss_ctx_id_t *ctx);
void    import_name(gss_name_t *gss_name);
Uchar   *init_context(gss_name_t gss_name, gss_ctx_id_t *ctx);
int     get_new_tickets(krb5_context c, krb5_principal p, krb5_ccache cc, char *pwd);
int     create_ticket(char *login, char *passwd);
