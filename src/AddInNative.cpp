﻿#include "stdafx.h"

#ifdef _WINDOWS
#pragma setlocale("ru-RU" )
#else //_WINDOWS
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <errno.h>
#include <iconv.h>
#include <sys/time.h>
#endif //_WINDOWS

#include <stdio.h>
#include <wchar.h>
#include "AddInNative.h"
#include <string>

#define BASE_ERRNO     7

#include "ProcMngr.h"
#include "ScreenMngr.h"
#include "WindowMngr.h"

const std::vector<AddInNative::Alias> AddInNative::m_PropList{
	Alias(eActiveWindow  , 0, true, L"ActiveWindow"    , L"АктивноеОкно"),
	Alias(eProcessId     , 0, true, L"ProcessId"       , L"ИдентификаторПроцесса"),
	Alias(eWindowList    , 0, true, L"WindowList"      , L"СписокОкон"),
	Alias(eProcessList   , 0, true, L"ProcessList"     , L"СписокПроцессов"),
	Alias(eDisplayList   , 0, true, L"DisplayList"     , L"СписокДисплеев"),
	Alias(eScreenInfo    , 0, true, L"ScreenInfo"      , L"СвойстваЭкрана"),
};

const std::vector<AddInNative::Alias> AddInNative::m_MethList{
	Alias(eFindTestClient  , 1, true , L"FindTestClient"   , L"НайтиКлиентТестирования"),
	Alias(eGetProcessList  , 1, true , L"GetProcessList"   , L"ПолучитьСписокПроцессов"),
	Alias(eGetProcessInfo  , 1, true , L"GetProcessInfo"   , L"ПолучитьСвойстваПроцесса"),
	Alias(eGetDisplayList  , 1, true , L"GetDisplayList"   , L"ПолучитьСписокДисплеев"),
	Alias(eGetDisplayInfo  , 1, true , L"GetDisplayInfo"   , L"ПолучитьСвойстваДисплея"),
	Alias(eGetScreenInfo   , 0, true , L"GetScreenInfo"    , L"ПолучитьСвойстваЭкрана"),
	Alias(eGetWindowList   , 1, true , L"GetWindowList"    , L"ПолучитьСписокОкон"),
	Alias(eGetWindowInfo   , 1, true , L"GetWindowInfo"    , L"ПолучитьСвойстваОкна"),
	Alias(eGetWindowSize   , 1, true , L"GetWindowSize"    , L"ПолучитьРазмерОкна"),
	Alias(eTakeScreenshot  , 1, true , L"TakeScreenshot"   , L"ПолучитьСнимокЭкрана"),
	Alias(eCaptureWindow   , 1, true , L"CaptureWindow"    , L"ПолучитьСнимокОкна"),
	Alias(eEnableResizing  , 2, false, L"EnableResizing"   , L"РазрешитьИзменятьРазмер"),
	Alias(eSetWindowPos    , 3, false, L"SetWindowPos"     , L"УстановитьПозициюОкна"),
	Alias(eSetWindowSize   , 3, false, L"SetWindowSize"    , L"УстановитьРазмерОкна"),
	Alias(eSetWindowState  , 3, false, L"SetWindowState"   , L"УстановитьСтатусОкна"),
	Alias(eActivateWindow  , 1, false, L"ActivateWindow"   , L"АктивироватьОкно"),
	Alias(eMaximizeWindow  , 1, false, L"MaximizeWindow"   , L"РаспахнутьОкно"),
	Alias(eMinimizeWindow  , 1, false, L"MinimizeWindow"   , L"СвернутьОкно"),
	Alias(eRestoreWindow   , 1, false, L"RestoreWindow"    , L"РазвернутьОкно"),
};

static const wchar_t g_kClassNames[] = L"WindowsControl";
static IAddInDefBase* pAsyncEvent = NULL;

uint32_t convToShortWchar(WCHAR_T** Dest, const wchar_t* Source, uint32_t len = 0);
uint32_t convFromShortWchar(wchar_t** Dest, const WCHAR_T* Source, uint32_t len = 0);
uint32_t getLenShortWcharStr(const WCHAR_T* Source);
static AppCapabilities g_capabilities = eAppCapabilitiesInvalid;
static WcharWrapper s_names(g_kClassNames);
//---------------------------------------------------------------------------//
long GetClassObject(const WCHAR_T* wsName, IComponentBase** pInterface)
{
	if (!*pInterface)
	{
		*pInterface = new AddInNative;
		return (long)*pInterface;
	}
	return 0;
}
//---------------------------------------------------------------------------//
AppCapabilities SetPlatformCapabilities(const AppCapabilities capabilities)
{
	g_capabilities = capabilities;
	return eAppCapabilitiesLast;
}
//---------------------------------------------------------------------------//
long DestroyObject(IComponentBase** pIntf)
{
	if (!*pIntf)
		return -1;

	delete* pIntf;
	*pIntf = 0;
	return 0;
}
//---------------------------------------------------------------------------//
const WCHAR_T* GetClassNames()
{
	return s_names;
}
//---------------------------------------------------------------------------//
// WindowManager
//---------------------------------------------------------------------------//
AddInNative::AddInNative()
{
	m_iMemory = 0;
	m_iConnect = 0;
}
//---------------------------------------------------------------------------//
AddInNative::~AddInNative()
{
}
//---------------------------------------------------------------------------//
bool AddInNative::Init(void* pConnection)
{
	m_iConnect = (IAddInDefBase*)pConnection;
	return m_iConnect != NULL;
}
//---------------------------------------------------------------------------//
long AddInNative::GetInfo()
{
	// Component should put supported component technology version 
	// This component supports 2.0 version
	return 2000;
}
//---------------------------------------------------------------------------//
void AddInNative::Done()
{
}
//---------------------------------------------------------------------------//
long AddInNative::FindName(const std::vector<Alias>& names, const WCHAR_T* name)
{
	for (Alias alias : names) {
		for (long i = 0; i < m_AliasCount; i++) {
#ifdef __linux__
			wchar_t* str = 0;
			::convFromShortWchar(&str, name);
			bool res = (wcscasecmp(alias.Name(i), str) == 0);
			delete[] str;
			if (res) return alias.id;
#else
			if (wcsicmp(alias.Name(i), name) == 0) return alias.id;
#endif//__linux__
		}
	}
	return -1;
}
//---------------------------------------------------------------------------//
const WCHAR_T* AddInNative::GetName(const std::vector<Alias>& names, long lPropNum, long lPropAlias)
{
	if (lPropNum >= names.size()) return NULL;
	if (lPropAlias >= m_AliasCount) return NULL;
	for (Alias alias : names) {
		if (alias.id == lPropNum) {
			return W((wchar_t*)alias.Name(lPropAlias));
		}
	}
	return NULL;
}
//---------------------------------------------------------------------------//
long AddInNative::GetNParams(const std::vector<Alias>& names, const long lMethodNum)
{
	for (Alias alias : names) {
		if (alias.id == lMethodNum) return alias.np;
	}
	return 0;
}
//---------------------------------------------------------------------------//
bool AddInNative::HasRetVal(const std::vector<Alias>& names, const long lMethodNum)
{
	for (Alias alias : names) {
		if (alias.id == lMethodNum) return alias.fn;
	}
	return 0;
}

AddInNative::VarinantHelper& AddInNative::VarinantHelper::operator<<(const wchar_t* str)
{
	TV_VT(pvar) = VTYPE_PWSTR;
	pvar->pwstrVal = NULL;
	if (mm && str && wcslen(str)) {
		unsigned long size = (unsigned long)wcslen(str) + 1;
		if (mm->AllocMemory((void**)&pvar->pwstrVal, size * sizeof(WCHAR_T))) {
			::convToShortWchar((WCHAR_T**)&pvar->pwstrVal, str, size);
			TV_VT(pvar) = VTYPE_PWSTR;
			pvar->wstrLen = size;
		}
	}
	return *this;
}

AddInNative::VarinantHelper& AddInNative::VarinantHelper::operator<<(const std::wstring& str)
{
	return operator<<(str.c_str());
}

AddInNative::VarinantHelper& AddInNative::VarinantHelper::operator<<(int64_t value)
{
	TV_VT(pvar) = VTYPE_I4;
	TV_I8(pvar) = value;
	return *this;
}

AddInNative::VarinantHelper& AddInNative::VarinantHelper::operator<<(int32_t value)
{
	TV_VT(pvar) = VTYPE_I4;
	TV_I4(pvar) = value;
	return *this;
}

const WCHAR_T* AddInNative::W(const wchar_t* str) const
{
	WCHAR_T* res = NULL;
	if (m_iMemory && str && wcslen(str)) {
		unsigned long size = (unsigned long)wcslen(str) + 1;
		if (m_iMemory->AllocMemory((void**)res, size * sizeof(WCHAR_T))) {
			::convToShortWchar(&res, str, size);
		}
	}
	return res;
}

/////////////////////////////////////////////////////////////////////////////
// ILanguageExtenderBase
//---------------------------------------------------------------------------//
bool AddInNative::RegisterExtensionAs(WCHAR_T** wsExtensionName)
{
	const wchar_t* wsExtension = L"WindowsControl";
	unsigned long iActualSize = (unsigned long)::wcslen(wsExtension) + 1;
	WCHAR_T* dest = 0;

	if (m_iMemory)
	{
		if (m_iMemory->AllocMemory((void**)wsExtensionName, iActualSize * sizeof(WCHAR_T)))
			::convToShortWchar(wsExtensionName, wsExtension, iActualSize);
		return true;
	}

	return false;
}
//---------------------------------------------------------------------------//
long AddInNative::GetNProps()
{
	// You may delete next lines and add your own implementation code here
	return ePropLast;
}
//---------------------------------------------------------------------------//
long AddInNative::FindProp(const WCHAR_T* wsPropName)
{
	return FindName(m_PropList, wsPropName);
}
//---------------------------------------------------------------------------//
const WCHAR_T* AddInNative::GetPropName(long lPropNum, long lPropAlias)
{
	return GetName(m_PropList, lPropNum, lPropAlias);
}
//---------------------------------------------------------------------------//
bool AddInNative::GetPropVal(const long lPropNum, tVariant* pvarPropVal)
{
	switch (lPropNum) {
	case eActiveWindow:
		return VA(pvarPropVal) << (int64_t)WindowManager::ActiveWindow();
	case eProcessList:
		return VA(pvarPropVal) << ProcessManager::GetProcessList(NULL, 0);
	case eWindowList:
		return VA(pvarPropVal) << WindowManager::GetWindowList(NULL, 0);
	case eDisplayList:
		return VA(pvarPropVal) << ScreenManager::GetDisplayList(NULL, 0);
	case eScreenInfo:
		return VA(pvarPropVal) << ScreenManager::GetScreenInfo();
	case eProcessId:
		return VA(pvarPropVal) << ProcessManager::ProcessId();
	default:
		return false;
	}
}
//---------------------------------------------------------------------------//
bool AddInNative::SetPropVal(const long lPropNum, tVariant* varPropVal)
{
	return false;
}
//---------------------------------------------------------------------------//
bool AddInNative::IsPropReadable(const long lPropNum)
{
	return true;
}
//---------------------------------------------------------------------------//
bool AddInNative::IsPropWritable(const long lPropNum)
{
	return false;
}
//---------------------------------------------------------------------------//
long AddInNative::GetNMethods()
{
	return eMethLast;
}
//---------------------------------------------------------------------------//
long AddInNative::FindMethod(const WCHAR_T* wsMethodName)
{
	return FindName(m_MethList, wsMethodName);
}
//---------------------------------------------------------------------------//
const WCHAR_T* AddInNative::GetMethodName(const long lMethodNum, const long lMethodAlias)
{
	return GetName(m_MethList, lMethodNum, lMethodAlias);
}
//---------------------------------------------------------------------------//
long AddInNative::GetNParams(const long lMethodNum)
{
	return GetNParams(m_MethList, lMethodNum);
}
//---------------------------------------------------------------------------//
bool AddInNative::GetParamDefValue(const long lMethodNum, const long lParamNum, tVariant* pvarParamDefValue)
{
	TV_VT(pvarParamDefValue) = VTYPE_EMPTY;
	return false;
}
//---------------------------------------------------------------------------//
bool AddInNative::HasRetVal(const long lMethodNum)
{
	return HasRetVal(m_MethList, lMethodNum);
}
//---------------------------------------------------------------------------//
bool AddInNative::CallAsProc(const long lMethodNum, tVariant* paParams, const long lSizeArray)
{
	switch (lMethodNum)
	{
	case eSetWindowPos:
		return WindowManager::SetWindowPos(paParams, lSizeArray);
	case eSetWindowSize:
		return WindowManager::SetWindowSize(paParams, lSizeArray);
	case eActivateWindow:
		return WindowManager::Activate(paParams, lSizeArray);
	case eMaximizeWindow:
		return WindowManager::Maximize(paParams, lSizeArray);
	case eMinimizeWindow:
		return WindowManager::Minimize(paParams, lSizeArray);
	case eRestoreWindow:
		return WindowManager::Restore(paParams, lSizeArray);
	case eEnableResizing:
		return WindowManager::EnableResizing(paParams, lSizeArray);
#ifdef _WINDOWS
	case eSetWindowState:
		return WindowManager::SetWindowState(paParams, lSizeArray);
#endif
	default:
		return false;
	}
}
//---------------------------------------------------------------------------//
bool AddInNative::CallAsFunc(const long lMethodNum, tVariant* pvarRetValue, tVariant* paParams, const long lSizeArray)
{
	switch (lMethodNum) {
	case eFindTestClient:
		return VA(pvarRetValue) << ProcessManager::FindTestClient(paParams, lSizeArray);
	case eGetScreenInfo:
		return VA(pvarRetValue) << ScreenManager::GetScreenInfo();
	case eGetProcessList:
		return VA(pvarRetValue) << ProcessManager::GetProcessList(paParams, lSizeArray);
	case eGetProcessInfo:
		return VA(pvarRetValue) << ProcessManager::GetProcessInfo(paParams, lSizeArray);
	case eGetWindowList:
		return VA(pvarRetValue) << WindowManager::GetWindowList(paParams, lSizeArray);
	case eGetWindowInfo:
		return VA(pvarRetValue) << WindowManager::GetWindowInfo(paParams, lSizeArray);
	case eGetWindowSize:
		return VA(pvarRetValue) << WindowManager::GetWindowSize(paParams, lSizeArray);
	case eTakeScreenshot:
		return ScreenManager(m_iMemory).CaptureScreen(pvarRetValue, paParams, lSizeArray);
	case eCaptureWindow:
		return ScreenManager(m_iMemory).CaptureWindow(pvarRetValue, paParams, lSizeArray);
	case eGetDisplayList:
		return VA(pvarRetValue) << ScreenManager::GetDisplayList(paParams, lSizeArray);
	case eGetDisplayInfo:
		return VA(pvarRetValue) << ScreenManager::GetDisplayInfo(paParams, lSizeArray);
	default:
		return false;
	}
}

//---------------------------------------------------------------------------//
void AddInNative::SetLocale(const WCHAR_T* loc)
{
#if !defined( __linux__ ) && !defined(__APPLE__)
	_wsetlocale(LC_ALL, loc);
#else
	//We convert in char* char_locale
	//also we establish locale
	//setlocale(LC_ALL, char_locale);
#endif
}
/////////////////////////////////////////////////////////////////////////////
// LocaleBase
//---------------------------------------------------------------------------//
bool AddInNative::setMemManager(void* mem)
{
	m_iMemory = (IMemoryManager*)mem;
	return m_iMemory != 0;
}
//---------------------------------------------------------------------------//
void AddInNative::addError(uint32_t wcode, const wchar_t* source,
	const wchar_t* descriptor, long code)
{
	if (m_iConnect)
	{
		WCHAR_T* err = 0;
		WCHAR_T* descr = 0;

		::convToShortWchar(&err, source);
		::convToShortWchar(&descr, descriptor);

		m_iConnect->AddError(wcode, err, descr, code);
		delete[] err;
		delete[] descr;
	}
}
//---------------------------------------------------------------------------//
uint32_t convToShortWchar(WCHAR_T** Dest, const wchar_t* Source, uint32_t len)
{
	if (!len)
		len = (uint32_t)::wcslen(Source) + 1;

	if (!*Dest)
		*Dest = new WCHAR_T[len];

	WCHAR_T* tmpShort = *Dest;
	wchar_t* tmpWChar = (wchar_t*)Source;
	uint32_t res = 0;

	::memset(*Dest, 0, len * sizeof(WCHAR_T));
#ifdef __linux__
	size_t succeed = (size_t)-1;
	size_t f = len * sizeof(wchar_t), t = len * sizeof(WCHAR_T);
	const char* fromCode = sizeof(wchar_t) == 2 ? "UTF-16" : "UTF-32";
	iconv_t cd = iconv_open("UTF-16LE", fromCode);
	if (cd != (iconv_t)-1)
	{
		succeed = iconv(cd, (char**)&tmpWChar, &f, (char**)&tmpShort, &t);
		iconv_close(cd);
		if (succeed != (size_t)-1)
			return (uint32_t)succeed;
	}
#endif //__linux__
	for (; len; --len, ++res, ++tmpWChar, ++tmpShort)
	{
		*tmpShort = (WCHAR_T)*tmpWChar;
	}

	return res;
}
//---------------------------------------------------------------------------//
uint32_t convFromShortWchar(wchar_t** Dest, const WCHAR_T* Source, uint32_t len)
{
	if (!len)
		len = getLenShortWcharStr(Source) + 1;

	if (!*Dest)
		*Dest = new wchar_t[len];

	wchar_t* tmpWChar = *Dest;
	WCHAR_T* tmpShort = (WCHAR_T*)Source;
	uint32_t res = 0;

	::memset(*Dest, 0, len * sizeof(wchar_t));
#ifdef __linux__
	size_t succeed = (size_t)-1;
	const char* fromCode = sizeof(wchar_t) == 2 ? "UTF-16" : "UTF-32";
	size_t f = len * sizeof(WCHAR_T), t = len * sizeof(wchar_t);
	iconv_t cd = iconv_open("UTF-32LE", fromCode);
	if (cd != (iconv_t)-1)
	{
		succeed = iconv(cd, (char**)&tmpShort, &f, (char**)&tmpWChar, &t);
		iconv_close(cd);
		if (succeed != (size_t)-1)
			return (uint32_t)succeed;
	}
#endif //__linux__
	for (; len; --len, ++res, ++tmpWChar, ++tmpShort)
	{
		*tmpWChar = (wchar_t)*tmpShort;
	}

	return res;
}
//---------------------------------------------------------------------------//
uint32_t getLenShortWcharStr(const WCHAR_T* Source)
{
	uint32_t res = 0;
	WCHAR_T* tmpShort = (WCHAR_T*)Source;

	while (*tmpShort++)
		++res;

	return res;
}
//---------------------------------------------------------------------------//

#ifdef LINUX_OR_MACOS
WcharWrapper::WcharWrapper(const WCHAR_T* str) : m_str_WCHAR(NULL),
m_str_wchar(NULL)
{
	if (str)
	{
		int len = getLenShortWcharStr(str);
		m_str_WCHAR = new WCHAR_T[len + 1];
		memset(m_str_WCHAR, 0, sizeof(WCHAR_T) * (len + 1));
		memcpy(m_str_WCHAR, str, sizeof(WCHAR_T) * len);
		::convFromShortWchar(&m_str_wchar, m_str_WCHAR);
	}
}
#endif
//---------------------------------------------------------------------------//
WcharWrapper::WcharWrapper(const wchar_t* str) :
#ifdef LINUX_OR_MACOS
	m_str_WCHAR(NULL),
#endif 
	m_str_wchar(NULL)
{
	if (str)
	{
		size_t len = wcslen(str);
		m_str_wchar = new wchar_t[len + 1];
		memset(m_str_wchar, 0, sizeof(wchar_t) * (len + 1));
		memcpy(m_str_wchar, str, sizeof(wchar_t) * len);
#ifdef LINUX_OR_MACOS
		::convToShortWchar(&m_str_WCHAR, m_str_wchar);
#endif
	}

}
//---------------------------------------------------------------------------//
WcharWrapper::~WcharWrapper()
{
#ifdef LINUX_OR_MACOS
	if (m_str_WCHAR)
	{
		delete[] m_str_WCHAR;
		m_str_WCHAR = NULL;
	}
#endif
	if (m_str_wchar)
	{
		delete[] m_str_wchar;
		m_str_wchar = NULL;
	}
}
//---------------------------------------------------------------------------//
