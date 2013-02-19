MODULE = Archive::Npk::API       PACKAGE = Archive::Npk::API::Package

: for $scaned -> $func {

Archive::Npk::API::Package
<: $func.mapped_name :>(class<:
    $func.var_list ? ", " ~ join(", ", $func.var_list) : ""
:>)
    char *class
:  for $func.parm_list_xs -> $parm {
    <: $parm :>
: }
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = <: $func.name :>(<: join(", ", $func.var_list) :>);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL

: }
