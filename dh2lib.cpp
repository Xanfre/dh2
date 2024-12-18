/******************************************************************************
 *  dh2lib.cpp
 *
 *  This file is part of Dark Hook 2
 *  Copyright (C) 2005-2011 Tom N Harris <telliamed@whoopdedo.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *****************************************************************************/
#define INITGUID 1
#include "darkhook.h"
#include <windows.h>

#include <lg/interface.h>
#include <lg/scrservices.h>

/* OSL sorts next to OSM nicely,
 * And will be copied by DarkLoader.
 */
#define DH2_MODULENAME "DH2.OSL"
#define DH2_INITPROCNAME "_DH2Init"

typedef Bool (__cdecl *DHInitProc)(IScriptMan* pScriptMan, IMalloc* pMalloc);

HANDLE DarkHookLoadLibrary(IScriptMan* pSM)
{
	Bool bFound = false;
	cScrStr path;
	path.MakeNull();
	try
	{
		SService<IEngineSrv> pES(pSM);
		bFound = pES->FindFileInPath("script_module_path", DH2_MODULENAME, path);
	}
	catch (no_interface&)
	{
	}

	HMODULE hDH2 = ::GetModuleHandleA(bFound ? path : DH2_MODULENAME);
	if (!hDH2)
		hDH2 = ::LoadLibraryA(bFound ? path : DH2_MODULENAME);
	path.Free();
	return reinterpret_cast<HANDLE>(hDH2);
}

Bool DarkHookInitializeService(IScriptMan* pSM, IMalloc* pMalloc)
{
	HMODULE hDH2 = reinterpret_cast<HMODULE>(DarkHookLoadLibrary(pSM));
	if (!hDH2)
		return FALSE;

#if __GNUC__ >= 8
/* Using GetProcAddress properly here will emit this warning on GCC 8 and
 * above, so explicitly ignore it.
 */
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wcast-function-type"
#endif
	DHInitProc pfnDHInit = reinterpret_cast<DHInitProc>(::GetProcAddress(hDH2, DH2_INITPROCNAME));
#if __GNUC__ >= 8
#pragma GCC diagnostic pop
#endif
	if (!pfnDHInit)
		return FALSE;

	return pfnDHInit(pSM, pMalloc);
}
