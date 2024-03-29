#ifndef __PLAN9ISH_H__
#define __PLAN9ISH_H__

/*
 * The following symbols are defined if your operating system supports
 * functions by that name.  All Unixes I know of support them, thus they
 * are not checked by the configuration script, but are directly defined
 * here.
 */

/* HAS_IOCTL:
 *	This symbol, if defined, indicates that the ioctl() routine is
 *	available to set I/O characteristics
 */
#define	HAS_IOCTL		/**/
 
/* HAS_UTIME:
 *	This symbol, if defined, indicates that the routine utime() is
 *	available to update the access and modification times of files.
 */
#define HAS_UTIME		/**/

/* HAS_GROUP
 *	This symbol, if defined, indicates that the getgrnam(),
 *	getgrgid(), and getgrent() routines are available to 
 *	get group entries.
 */
/*#define HAS_GROUP		/**/

/* HAS_PASSWD
 *	This symbol, if defined, indicates that the getpwnam(),
 *	getpwuid(), and getpwent() routines are available to 
 *	get password entries.
 */
/*#define HAS_PASSWD		/**/

#define HAS_KILL
#define HAS_WAIT
  
/* UNLINK_ALL_VERSIONS:
 *	This symbol, if defined, indicates that the program should arrange
 *	to remove all versions of a file if unlink() is called.  This is
 *	probably only relevant for VMS.
 */
/* #define UNLINK_ALL_VERSIONS		/**/

/* PLAN9:
 *	This symbol, if defined, indicates that the program is running under
 *	Plan 9.  
 */
#ifndef PLAN9
#define PLAN9		/**/
#endif

/* USE_STAT_RDEV:
*	This symbol is defined if this system has a stat structure declaring
*	st_rdev
*/
#undef USE_STAT_RDEV		/**/

/* ACME_MESS:
 *	This symbol, if defined, indicates that error messages should be 
 *	should be generated in a format that allows the use of the Acme
 *	GUI/editor's autofind feature.
 */
#define ACME_MESS	/**/

#if !defined(NSIG) || defined(M_UNIX) || defined(M_XENIX)
# include <signal.h>
#endif

#ifndef SIGABRT
#    define SIGABRT SIGILL
#endif
#ifndef SIGILL
#    define SIGILL 6         /* blech */
#endif
#define ABORT() kill(getpid(),SIGABRT);

#define BIT_BUCKET "/dev/null"
#define PERL_SYS_INIT(c,v)

/*
 * fwrite1() should be a routine with the same calling sequence as fwrite(),
 * but which outputs all of the bytes requested as a single stream (unlike
 * fwrite() itself, which on some systems outputs several distinct records
 * if the number_of_items parameter is >1).
 */
#define fwrite1 fwrite

#define Stat(fname,bufptr) stat((fname),(bufptr))
#define Fstat(fd,bufptr)   fstat((fd),(bufptr))
#define Fflush(fp)         fflush(fp)

/* getenv related stuff */
#define my_getenv(var) getenv(var)
/* Plan 9 prefers getenv("home") to getenv("HOME")
#define HOME home

/* For use by POSIX.xs */
extern int tcsendbreak(int, int);

#endif /* __PLAN9ISH_H__ */
