#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "npk.h"
#include "npk_dev.h"
#include "npk_perl.h"

typedef NPK_PACKAGE  Archive__Npk__API__Package;
typedef NPK_ENTITY   Archive__Npk__API__Entity;

MODULE = Archive::Npk::API       PACKAGE = Archive::Npk::API::Package

Archive::Npk::API::Package
open(class, fn, teakey)
    char *class
    char *fn
    NPK_TEAKEY *teakey
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_open(fn, teakey);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
open_with_fd(class, name, fd, offset, size, teakey)
    char *class
    NPK_CSTR name
    int fd
    long offset
    long size
    NPK_TEAKEY *teakey
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_open_with_fd(name, fd, offset, size, teakey);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


bool
close(self)
    Archive::Npk::API::Package self
CODE:
{
    RETVAL = npk_package_close(self);
    if (!RETVAL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Entity
get_entity(self, entityname)
    Archive::Npk::API::Package self
    NPK_CSTR entityname
CODE:
{
    RETVAL = npk_package_get_entity(self, entityname);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Entity
get_first_entity(self, entityname)
    Archive::Npk::API::Package self
CODE:
{
    RETVAL = npk_package_get_first_entity(self);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL
