APE=/sys/src/ape
< $APE/config
<plan9/buildinfo
sourcedir = /sys/src/cmd/perl/$p9pvers
archname = plan9_$objtype
privlib=/sys/lib/perl
sitelib = $privlib/site_perl
sitearch = /$objtype/lib/perl/site_perl
archlib = /$objtype/lib/perl/$p9pvers

CFLAGS =  -B  -D_POSIX_SOURCE -D_BSD_EXTENSION
LDFLAGS = -B 

CCCMD = $CC  -c $CFLAGS 

perllib = $archlib/CORE/libperl.a

perlshr = $archlib/CORE/libperlshr.a

installman1dir = /sys/man/1
installman3dir = /sys/man/2

podnames = perl perlbook perlbot perlcall perldata perldebug perldiag perldsc perlembed perlform perlfunc perlguts perlipc perllol perlmod perlobj perlop perlovl perlpod perlre perlref perlrun perlsec perlstyle perlsub perlsyn perltie perltoc perltrap perlvar perlxs perlxstut

libpods = ${podnames:%=pod/%.pod}

perlpods = $libpods

extensions = Socket Safe DynaLoader Fcntl FileHandle POSIX
ext_xs = Socket.xs Safe.xs  dl_none.xs Fcntl.xs FileHandle.xs POSIX.xs
ext_c = ${ext_xs:%.xs=%.c}
ext_obj = ${ext_xs:%.xs=%.$O}

obj = gv.$O toke.$O perly.$O op.$O regcomp.$O dump.$O util.$O mg.$O  hv.$O av.$O run.$O pp_hot.$O sv.$O pp.$O scope.$O pp_ctl.$O pp_sys.$O doop.$O doio.$O regexec.$O taint.$O deb.$O globals.$O plan9.$O

OBJS = perl.$O $obj

testlist = base/*.t comp/*.t cmd/*.t io/*.t op/*.t

install:V:	perl preplibrary 
		cp perl /$objtype/bin/perl
		cp plan9/aperl /bin/perl
		
perl:		config.h miniperl $archlib/Config.pm perlmain.$O $perlshr 
		$LD $CFLAGS -o perl perlmain.$O $perllib $perlshr
		
miniperl:	config.h $perllib miniperlmain.$O 
		$LD  $CFLAGS -o miniperl miniperlmain.$O  $perllib 

preplibrary:V:	miniperl $archlib/Config.pm
			cd $privlib
			for (file in *.pm */*.pm) $sourcedir/miniperl  -e 'use AutoSplit; autosplit(@ARGV)' $file $privlib/auto
	
$perllib(%):N:	%
$perllib: ${OBJS:%=$perllib(%)}
		ar rv $perllib $OBJS
		$RANLIB $perllib
			
miniperlmain.$O:	config.h miniperlmain.c
				$CCCMD miniperlmain.c

perlmain.$O:	config.h perlmain.c
			$CCCMD perlmain.c

perlmain.c:	miniperl vms/writemain.pl
			./miniperl vms/writemain.pl $extensions

config.h:		config.plan9 plan9/fndvers
			plan9/fndvers config.h 
			cp config.h $archlib/CORE

$perlshr(%):N:	%
$perlshr:  ${ext_obj:%=$perlshr(%)}
		ar rv $perlshr $ext_obj
		$RANLIB $perlshr

Socket.$O:	config.h Socket.c
			$CCCMD -I plan9 Socket.c

Socket.c:		miniperl ext/Socket/Socket.xs
			./miniperl $privlib/ExtUtils/xsubpp -noprototypes -typemap $privlib/ExtUtils/typemap ext/Socket/Socket.xs > $target
			cp ext/Socket/Socket.pm $privlib

Safe.c:		miniperl ext/Safe/Safe.xs
			./miniperl $privlib/ExtUtils/xsubpp -noprototypes -typemap $privlib/ExtUtils/typemap ext/Safe/Safe.xs > $target
			cp ext/Safe/Safe.pm $privlib

Fcntl.c:		miniperl ext/Fcntl/Fcntl.xs
			./miniperl $privlib/ExtUtils/xsubpp -noprototypes -typemap $privlib/ExtUtils/typemap ext/Fcntl/Fcntl.xs > $target
			cp ext/Fcntl/Fcntl.pm $privlib

FileHandle.c:		miniperl ext/FileHandle/FileHandle.xs
			./miniperl $privlib/ExtUtils/xsubpp -noprototypes -typemap $privlib/ExtUtils/typemap ext/FileHandle/FileHandle.xs > $target
			cp ext/FileHandle/FileHandle.pm $privlib

POSIX.c:		miniperl ext/POSIX/POSIX.xs
			./miniperl $privlib/ExtUtils/xsubpp -noprototypes -typemap $privlib/ExtUtils/typemap ext/POSIX/POSIX.xs > $target
			cp ext/POSIX/POSIX.pm $privlib

dl_none.c:	miniperl ext/DynaLoader/dl_none.xs
			./miniperl $privlib/ExtUtils/xsubpp -noprototypes -typemap $privlib/ExtUtils/typemap ext/DynaLoader/dl_none.xs > $target
			cp ext/DynaLoader/DynaLoader.pm $privlib

test:V:		
			{cd $privlib; tar c .} | {cd $sourcedir/lib; tar x}
			cp $archlib/Config.pm $sourcedir/lib
			cd $sourcedir/t
			rm -f perl
			cp /$objtype/bin/perl perl
			perl TEST `{ ls */*.t | comm -23 - ../plan9/exclude }
			{ cd $sourcedir/lib ; rm -r * }

plan9.$O:	config.h ./plan9/plan9.c
			cp ./plan9/plan9.c ./plan9.c
			$CCCMD plan9.c

%.$O:	config.h %.c
		$CCCMD $stem.c

$archlib/Config.pm:		miniperl config.sh
				./miniperl configpm $archlib/Config.pm

config.sh:	miniperl ./plan9/config.plan9
		./miniperl ./plan9/genconfig.pl

installall:V:	
			for (objtype in 386 mips 68020 sparc) mk install

man:V:		$perlpods pod/pod2man.PL perl
			perl pod/pod2man.PL
			for (i in $podnames) pod/pod2man pod/$i.pod > $installman3dir/$i
			pod/pod2man plan9/perlplan9.pod > $installman3dir/perlplan9
			
nuke:V:	
		rm -f *.$O   $extensions^.pm config.sh $perllib config.h $perlshr perlmain.c perl miniperl $archlib/Config.pm $ext_c
		
clean:V:
		rm -f *.$O config.sh  miniperl  t/perl

deleteman:V:
			rm -f $installman1dir/perl* $installman3dir/perl*
