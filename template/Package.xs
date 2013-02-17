#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "npk.h"
#include "npk_dev.h"
#include "npk_perl.h"

typedef NPK_PACKAGE  Archive__Npk__API__Package;
typedef NPK_ENTITY   Archive__Npk__API__Entity;

MODULE = Archive::Npk::API       PACKAGE = Archive::Npk::API::Package

: for $scaned -> $func {

Archive::Npk::API::Package
<: $func.function_mapped_name :>(class, <: $func.parameter_list_as_string :>)
    char *class
:  for $func.parameter_as_string -> $parm {
    <: $parm :>
: }
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = <: $func.function_name[1][1] :>(<: $func.argument_list_as_string :>);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL

: }
