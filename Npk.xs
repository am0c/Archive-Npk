#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "npk.h"
#include "npk_dev.h"
#include "npk_perl.h"


MODULE = Archive::Npk::API       PACKAGE = Archive::Npk::API::Package


Archive::Npk::API::Package
open(class, filename, teakey)
    char *class
    NPK_CSTR filename
    NPK_TEAKEY *teakey
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_open(filename, teakey);
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


Archive::Npk::API::Package
close(class, package)
    char *class
    NPK_PACKAGE package
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_close(package);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
get_entity(class, package, entityname)
    char *class
    NPK_PACKAGE package
    NPK_CSTR entityname
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_get_entity(package, entityname);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
get_first_entity(class, package)
    char *class
    NPK_PACKAGE package
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_get_first_entity(package);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
alloc(class, lpPackage, teakey)
    char *class
    NPK_PACKAGE* lpPackage
    NPK_TEAKEY *teakey
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_alloc(lpPackage, teakey);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
init(class, package)
    char *class
    NPK_PACKAGE package
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_init(package);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
save(class, package, filename, forceOverwrite)
    char *class
    NPK_PACKAGE package
    NPK_CSTR filename
    int forceOverwrite
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_save(package, filename, forceOverwrite);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
clear(class, package)
    char *class
    NPK_PACKAGE package
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_clear(package);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
add_file(class, package, filename, entityname, lpEntity)
    char *class
    NPK_PACKAGE package
    NPK_CSTR filename
    NPK_CSTR entityname
    NPK_ENTITY* lpEntity
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_add_file(package, filename, entityname, lpEntity);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
add_entity(class, package, entity)
    char *class
    NPK_PACKAGE package
    NPK_ENTITY entity
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_add_entity(package, entity);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
remove_entity(class, package, entity)
    char *class
    NPK_PACKAGE package
    NPK_ENTITY entity
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_remove_entity(package, entity);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
detach_entity(class, package, entity)
    char *class
    NPK_PACKAGE package
    NPK_ENTITY entity
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_detach_entity(package, entity);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
remove_all_entity(class, package)
    char *class
    NPK_PACKAGE package
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_remove_all_entity(package);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL


Archive::Npk::API::Package
detach_all_entity(class, package)
    char *class
    NPK_PACKAGE package
CODE:
{
    Newx(RETVAL, 1, NPK_PACKAGE);
    RETVAL = npk_package_detach_all_entity(package);
    if (RETVAL == NULL) {
        npk_perl_croak();
    }
}
OUTPUT:
    RETVAL

