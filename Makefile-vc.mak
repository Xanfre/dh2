###############################################################################
##  Makefile-vc
##
##  This file is part of Dark Hook 2
##  Copyright (C) 2005-2011 Tom N Harris <telliamed@whoopdedo.org>
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program. If not, see <http://www.gnu.org/licenses/>.
##
###############################################################################

CPU=i386
APPVER=4.0
!include <win32.mak>

srcdir = .
LGDIR = ..\lg

DEFINES = -DWINVER=0x0400 -D_WIN32_WINNT=0x0400 -DWIN32_LEAN_AND_MEAN -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS -D_NEWDARK
INCLUDES = -I. -I$(LGDIR)
LIBS = uuid.lib $(baselibs)
LDFLAGS = -nologo $(dlllflags) -base:0x12200000 -def:dh2dll.def
LIBDIRS =
CFLAGS = $(cflags) -nologo -W3
CXXFLAGS = $(CFLAGS) -TP -EHsc
LIBFLAGS = -nologo
!ifdef DEBUG
CDEBUG = -MDd -Od -DDEBUG=1
LDDEBUG = -DEBUG
LGLIB = $(LGDIR)\lg-d.lib
!else
CDEBUG = -MD -Ox -DNDEBUG
LDDEBUG = -RELEASE
LGLIB = $(LGDIR)\lg.lib
!endif

ALL = dh2.osl dh2.lib

DLLSRCS = dh2.cpp dh2dll.cpp dh2lib.cpp
DLLOBJS = dh2.obj dh2dll.obj
DLLRES = dh2.res

LIBSRCS = dh2lib.cpp
LIBOBJS = dh2lib.obj

.c.obj:
	$(cc) $(CFLAGS) $(CDEBUG) $(DEFINES) $(INCLUDES) -c $<

.cpp.obj:
	$(cc) $(CXXFLAGS) $(CDEBUG) $(DEFINES) $(INCLUDES) -c $<

.rc.res:
	$(rc) $(rcflags) $<

all:	$(ALL)

clean:
	del /q $(ALL) $(DLLOBJS) $(DLLRES) $(LIBOBJS) *.exp *.manifest

dh2.osl: $(DLLOBJS) $(DLLRES)
	$(link) $(LDFLAGS) $(LDDEBUG) $(LIBDIRS) -out:$@ $** $(LGLIB) $(LIBS)
	mt -nologo -manifest dh2.osl.manifest -outputresource:dh2.osl;#1

dh2.lib: $(LIBOBJS)
	$(implib) $(libflags) -out:$@ $?


dh2.obj: dh2.cpp dh2.h darkhook.h objprop.h

dh2dll.obj: dh2dll.cpp dh2.h darkhook.h

dh2lib.obj: dh2lib.cpp darkhook.h

