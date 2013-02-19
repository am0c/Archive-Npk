#ifndef NPK_PERL_H
#define NPK_PERL_H

#include "npk.h"

#define npk_perl_croak()  croak("%s", npk_error_to_str(g_npkError))

typedef NPK_PACKAGE  Archive__Npk__API__Package;
typedef NPK_ENTITY   Archive__Npk__API__Entity;

#endif  /* ifndef NPK_PERL_H */
