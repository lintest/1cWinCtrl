#include "stdafx.h"
#include "ProcMngr.h"
#include "json_ext.h"

#ifdef _WINDOWS

#define _WIN32_DCOM
#include <iostream>
#include <sstream>
#include <comdef.h>
#include <wbemidl.h>
#pragma comment(lib, "wbemuuid.lib")

class ProcessEnumerator {
private:
	HRESULT hInitialize;
	IWbemLocator* pLoc = NULL;
	IWbemServices* pSvc = NULL;
	IEnumWbemClassObject* pEnumerator = NULL;
	IWbemClassObject* pclsObj = NULL;
	JSON result;
private:
	BOOL CheckError(HRESULT hres)
	{
		if (SUCCEEDED(hres)) return false;
		result.clear();
		result["error"] = WC2MB(_com_error(hres).ErrorMessage());
		return true;
	}
public:
	ProcessEnumerator(const WCHAR* query)
	{
		hInitialize = CoInitializeEx(0, COINIT_APARTMENTTHREADED);
		if (CheckError(hInitialize)) return;

		HRESULT hres;

		hres = CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER, IID_IWbemLocator, (LPVOID*)&pLoc);
		if (CheckError(hres)) return;

		hres = pLoc->ConnectServer(
			_bstr_t(L"\\\\.\\root\\CIMV2"),      // Object path of WMI namespace
			NULL,                    // User name. NULL = current user
			NULL,                    // User password. NULL = current
			0,                       // Locale. NULL indicates current
			NULL,                    // Security flags.
			0,                       // Authority (e.g. Kerberos)
			0,                       // Context object
			&pSvc                    // pointer to IWbemServices proxy
		);
		if (CheckError(hres)) return;

		// Set security levels on the proxy -------------------------
		hres = CoSetProxyBlanket(
			pSvc,                        // Indicates the proxy to set
			RPC_C_AUTHN_WINNT,           // RPC_C_AUTHN_xxx
			RPC_C_AUTHZ_NONE,            // RPC_C_AUTHZ_xxx
			NULL,                        // Server principal name
			RPC_C_AUTHN_LEVEL_CALL,      // RPC_C_AUTHN_LEVEL_xxx
			RPC_C_IMP_LEVEL_IMPERSONATE, // RPC_C_IMP_LEVEL_xxx
			NULL,                        // client identity
			EOAC_NONE                    // proxy capabilities
		);
		if (CheckError(hres)) return;

		hres = pSvc->ExecQuery(_bstr_t(L"WQL"), _bstr_t(query),
			WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnumerator);
		if (CheckError(hres)) return;

		ULONG uReturn = 0;
		while (pEnumerator)
		{
			HRESULT hr = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
			if (0 == uReturn || CheckError(hr)) break;

			SAFEARRAY* pNames = NULL;
			pclsObj->GetNames(NULL, WBEM_FLAG_NONSYSTEM_ONLY, NULL, &pNames);

			JSON json;
			long lbound = 0, ubound = 0;
			hr = SafeArrayGetLBound(pNames, 1, &lbound);
			hr = SafeArrayGetUBound(pNames, 1, &ubound);
			for (long i = lbound; i <= ubound; ++i)
			{
				wchar_t* name = NULL;
				hr = SafeArrayGetElement(pNames, &i, &name);
				if (FAILED(hr)) continue;

				VARIANT vtProp;
				hr = pclsObj->Get(name, 0, &vtProp, 0, 0);
				if (SUCCEEDED(hr)) {
					if (wcscmp(name, L"CreationDate") == 0) {
						std::wstring str = vtProp.bstrVal;
						str = str.substr(0, 8) + L"T" + str.substr(8, 6);
						json["CreationDate"] = WC2MB(str);
					}
					else {
						switch (vtProp.vt) {
						case VT_NULL:
							break;
						case VT_BSTR:
							json[WC2MB(name)] = WC2MB(vtProp.bstrVal);
							break;
						case VT_I4:
							json[WC2MB(name)] = vtProp.intVal;
							break;
						default:
							VARIANTARG vtDest;
							hr = VariantChangeType(&vtDest, &vtProp, VARIANT_ALPHABOOL, VT_BSTR);
							if SUCCEEDED(hr) json[WC2MB(name)] = WC2MB(vtDest.bstrVal);
						}
					}
				}
				VariantClear(&vtProp);
			}
			result.push_back(json);
			pclsObj->Release();
			pclsObj = NULL;
		}
	}

	~ProcessEnumerator() {
		if (pEnumerator) pEnumerator->Release();
		if (pSvc) pSvc->Release();
		if (pLoc) pLoc->Release();
		if (SUCCEEDED(hInitialize)) CoUninitialize();
	}

	operator std::wstring() {
		return result;
	}
	JSON json() {
		return result;
	}
};

int64_t ProcessManager::ProcessId()
{
	return(GetCurrentProcessId());
}

std::wstring ProcessManager::GetProcessList(tVariant* paParams, const long lSizeArray)
{
	std::wstring query;
	query.append(L"SELECT ProcessId,CreationDate,CommandLine");
	query.append(L" FROM Win32_Process ");
	if (lSizeArray > 0 && paParams->vt == VTYPE_BOOL && paParams->intVal) {
		query.append(L" WHERE Name LIKE '1cv8%'");
	}
	return ProcessEnumerator(query.c_str());
}

std::wstring ProcessManager::GetProcessInfo(tVariant* paParams, const long lSizeArray)
{
	if (lSizeArray < 1) return {};
	std::wstring query;
	query.append(L"SELECT * FROM Win32_Process WHERE ProcessId=");
	query.append(std::to_wstring(VarToInt(paParams)));
	JSON json = ProcessEnumerator(query.c_str()).json();
	if (json.is_array() && json.size() == 1) {
		return MB2WC(json[0].dump());
	}
	return {};
}

std::wstring ProcessManager::FindProcess(tVariant* paParams, const long lSizeArray)
{
	if (lSizeArray < 1) return {};
	if (paParams->vt != VTYPE_PWSTR) return {};
	if (paParams->pwstrVal == NULL) return {};
	return ProcessEnumerator(paParams->pwstrVal);
}

std::wstring ProcessManager::FindTestClient(tVariant* paParams, const long lSizeArray)
{
	if (lSizeArray < 1) return NULL;
	std::wstring query;
	query.append(L"SELECT ProcessId,CreationDate,CommandLine");
	query.append(L" FROM Win32_Process ");
	query.append(L" WHERE Name LIKE '1cv8%' ");
	query.append(L" AND CommandLine LIKE '% /TESTCLIENT %'");
	query.append(L" AND CommandLine LIKE '% -TPort ");
	query.append(std::to_wstring(VarToInt(paParams))).append(L" %'");
	JSON json = ProcessEnumerator(query.c_str()).json();
	if (!json.is_array() || json.empty()) return {};

	std::pair<HWND, DWORD> params = { 0, (DWORD)json[0]["ProcessId"] };
	// Enumerate the windows using a lambda to process each window
	BOOL bResult = ::EnumWindows([](HWND hWnd, LPARAM lParam) -> BOOL
		{
			auto pParams = (std::pair<HWND, DWORD>*)(lParam);
			wchar_t buffer[256];
			DWORD pid;
			if (IsWindowVisible(hWnd)
				&& ::GetWindowThreadProcessId(hWnd, &pid)
				&& pid == pParams->second
				&& ::GetClassName(hWnd, buffer, 256)
				&& wcscmp(L"V8TopLevelFrameSDI", buffer) == 0
				) {
				// Stop enumerating
				SetLastError(-1);
				pParams->first = hWnd;
				return FALSE;
			}
			// Continue enumerating
			return TRUE;
		}, (LPARAM)&params);

	HWND hWnd = params.first;
	if (!bResult && GetLastError() == -1 && hWnd)
	{
		nlohmann::json j = json[0];
		j["Window"] = (UINT64)hWnd;
		const int length = GetWindowTextLength(hWnd);
		if (length != 0) {
			std::wstring text;
			text.resize(length);
			::GetWindowText(hWnd, &text[0], length + 1);
			j["Title"] = WC2MB(text);
		}
		return MB2WC(j.dump());
	}
	return {};
}

DWORD ProcessManager::ParentProcessId(DWORD pid)
{
	std::wstring query;
	query.append(L"SELECT ParentProcessId");
	query.append(L" FROM Win32_Process ");
	query.append(L" WHERE ProcessId=");
	query.append(std::to_wstring(pid));
	JSON json = ProcessEnumerator(query.c_str()).json();
	if (json.is_array() && json.size() == 1) {
		return json[0]["ParentProcessId"];
	}
	return 0;
}

bool ProcessManager::ConsoleOut(tVariant* paParams, const long lSizeArray)
{
	std::wstring text = VarToStr(paParams);
	auto pid = ::GetCurrentProcessId();
	while (true) {
		pid = ParentProcessId(pid);
		if (pid == 0) return false;
		if (AttachConsole(pid)) break;
	}
	SetConsoleOutputCP(1251);
	SetConsoleCP(1251);
	FILE* fDummy;
	freopen_s(&fDummy, "CONOUT$", "w", stdout);
	auto hConOut = CreateFile(L"CONOUT$", GENERIC_WRITE, FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	SetStdHandle(STD_OUTPUT_HANDLE, hConOut);
	std::wcout << text;
	FreeConsole();
	return true;
}

bool ProcessManager::Sleep(tVariant* paParams, const long lSizeArray)
{
	::Sleep(VarToInt(paParams));
	return true;
}

#else //_WINDOWS

#include <unistd.h>
#include <sys/stat.h>
#include "XWinBase.h"

static std::string file2str(const std::string& filepath) {
	std::ifstream file(filepath);
	std::string text;
	if (file) std::getline(file, text);
	return text;
}

class ProcessEnumerator : public WindowEnumerator
{
private:
	const std::string proc = "/proc/";

protected:
	std::string GetProcessName(unsigned long pid, bool original = false) {
		std::string filepath = proc + to_string(pid) + "/comm";
		return file2str(filepath);
	}

	std::string GetCommandLine(unsigned long pid, bool original = false) {
		std::string filepath = proc + to_string(pid) + "/cmdline";
		std::string line = file2str(filepath);
		if (original) return line;
		for (std::string::iterator it = line.begin(); it != line.end(); ++it) {
			if (*it == 0) *it = ' ';
		}
		return line;
	}

	std::string GetCreationDate(unsigned long pid) {
		struct stat st;
		std::string filepath = proc + to_string(pid);
		stat(filepath.c_str(), &st);
		time_t t = st.st_mtime;
		struct tm lt;
		localtime_r(&t, &lt);
		char buffer[80];
		strftime(buffer, sizeof(buffer), "%FT%T", &lt);
		return buffer;
	}

};

class ClientFinder : public ProcessEnumerator
{
private:
	int m_port;

protected:
	virtual bool EnumWindow(Window window) {
		std::string str = GetWindowClass(window);
		if (str.substr(0, 4) != "1cv8") return true;
		unsigned long pid = GetWindowPid(window);
		if (NotFound(pid)) return true;
		json["Name"] = GetProcessName(pid);
		json["Window"] = (unsigned long)window;
		json["Title"] = GetWindowTitle(window);
		json["CommandLine"] = GetCommandLine(pid);
		json["CreationDate"] = GetCreationDate(pid);
		json["ProcessId"] = pid;
		return false;
	}

public:
	ClientFinder(int port) : m_port(port) {}

private:
	bool NotFound(unsigned long pid) {
		std::string line = GetCommandLine(pid, true);
		std::string port = to_string(m_port);
		char* first = NULL;
		char* second = &line[0];
		for (int i = 0; i < line.size() - 1; i++) {
			if (line[i] != 0) continue;
			first = second;
			second = &line[0] + i + 1;
			if (strcmp(first, "-TPort") == 0
				&& strcmp(port.c_str(), second) == 0)
				return false;
		}
		return true;
	}
};

class ProcessList : public ProcessEnumerator
{
private:
	bool m_filter = false;
	vector<unsigned long> v;
protected:
	virtual bool EnumWindow(Window window) {
		std::string str = GetWindowClass(window);
		if (str.substr(0, 4) != "1cv8") return true;
		unsigned long pid = GetWindowPid(window);
		if (std::find(v.begin(), v.end(), pid) != v.end()) return true;
		v.push_back(pid);
		JSON j;
		j["Name"] = GetProcessName(pid);
		j["Window"] = (unsigned long)window;
		j["Title"] = GetWindowTitle(window);
		j["CommandLine"] = GetCommandLine(pid);
		j["CreationDate"] = GetCreationDate(pid);
		j["ProcessId"] = pid;
		json.push_back(j);
		return true;
	}
public:
	ProcessList(bool filter) : m_filter(filter) {}
};

class ProcessInfo : public ProcessEnumerator
{
protected:
	virtual bool EnumWindow(Window window) { return false; } 
public:
	ProcessInfo(unsigned long pid) {
		json["Name"] = GetProcessName(pid);
		json["CommandLine"] = GetCommandLine(pid);
		json["CreationDate"] = GetCreationDate(pid);
		json["ProcessId"] = pid;
	}
};

int64_t ProcessManager::ProcessId()
{
	return getpid();
}

std::wstring ProcessManager::FindTestClient(tVariant* paParams, const long lSizeArray)
{
	if (lSizeArray < 1) return 0;
	int port = VarToInt(paParams);
	return ClientFinder(port).Enumerate();
}

std::wstring ProcessManager::GetProcessList(tVariant* paParams, const long lSizeArray)
{
	bool filter = false;
	if (lSizeArray > 0) filter = VarToInt(paParams);
	return ProcessList(filter).Enumerate();
}

std::wstring ProcessManager::GetProcessInfo(tVariant* paParams, const long lSizeArray)
{
	if (lSizeArray < 1) return 0;
	unsigned long pid = VarToInt(paParams);
	return ProcessInfo(pid);
}

bool ProcessManager::ConsoleOut(tVariant* paParams, const long lSizeArray)
{
	std::wstring text = VarToStr(paParams);
	std::wcout << text;
	return true;
}

bool ProcessManager::Sleep(tVariant* paParams, const long lSizeArray)
{
	unsigned long ms = VarToInt(paParams);
	::usleep(ms * 1000);
	return true;
}

std::wstring OpenWebSocket(WebSocketBase** ws, tVariant* paParams, const long lSizeArray) { return {}; }
std::wstring SendWebSocket(WebSocketBase* ws, tVariant* paParams, const long lSizeArray) { return {}; }
std::wstring WebSocket(tVariant* paParams, const long lSizeArray) { return {}; }

#endif //_WINDOWS

#ifdef _WINDOWS

#include "WebSocket.h"

static std::wstring SocketError(std::string message)
{
	nlohmann::json json, j;
	j["message"] = message;
	json["error"] = j;
	return MB2WC(json.dump());
}

std::wstring ProcessManager::WebSocket(tVariant* paParams, const long lSizeArray)
{
	if (lSizeArray < 2) return {};
	std::string url = WC2MB(VarToStr(paParams));
	std::string msg = WC2MB(VarToStr(paParams + 1));
	try {
		msg = nlohmann::json::parse(msg).dump();
	}
	catch (nlohmann::json::parse_error e) {
		return SocketError("JSON parse error");
	}

	std::string res;
	if (doWebSocket(url, msg, res)) {
		return MB2WC(res);
	}
	else {
		return SocketError(res);
	}
}

std::wstring ProcessManager::OpenWebSocket(WebSocketBase** ws, tVariant* paParams, const long lSizeArray)
{
	std::string res, url = WC2MB(VarToStr(paParams));
	WebSocketBase* socket = WebSocketBase::create();
	if (socket && socket->open(url, res)) {
		if (*ws) delete (*ws);
		*ws = socket;
		return MB2WC(res);
	}
	else {
		delete socket;
		return SocketError(res);
	}
	return {};
}

std::wstring ProcessManager::SendWebSocket(WebSocketBase* ws, tVariant* paParams, const long lSizeArray)
{
	if (!ws) return SocketError("Error: WebSocket closed");

	std::string res, msg = WC2MB(VarToStr(paParams));
	try {
		msg = nlohmann::json::parse(msg).dump();
	}
	catch (nlohmann::json::parse_error e) {
		return SocketError("JSON parse error");
	}

	return ws->send(msg, res) ? MB2WC(res) : SocketError(res);
}

#endif //_WINDOWS
