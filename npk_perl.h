#ifndef NPK_PERL_H
#define NPK_PERL_H

#include "npk.h"

#define npk_perl_croak()  croak(npk_error_to_str(g_npkError))

#endif  /* ifndef NPK_PERL_H */
