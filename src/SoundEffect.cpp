﻿#ifdef _WINDOWS

#include "stdafx.h"
#include "windows.h"
#include "SoundEffect.h"
#include "AddInNative.h"

#include <wbemidl.h>
#pragma comment(lib, "rpcrt4.lib")
#pragma comment(lib, "winmm.lib")

const LPCWSTR wsSoundName = L"VanessaSoundEffect";

#define WM_SOUND_STOP (WM_USER + 2)

BOOL SoundEffect::PlaySound(const std::wstring& filename, bool async)
{

	if (filename.empty()) return ::PlaySoundW(NULL, NULL, 0);
	DWORD fdwSound = SND_FILENAME | SND_NODEFAULT;
	if (async) fdwSound |= SND_ASYNC;
	return ::PlaySoundW(filename.c_str(), 0, fdwSound);
}

std::u16string MediaError(MCIERROR err)
{
	size_t size = 1024;
	std::wstring error;
	error.resize(size);
	mciGetErrorString(err, &error[0], (UINT)size);
	return std::u16string(error.begin(), error.end());
}

std::wstring SoundEffect::MediaCommand(const std::wstring& command)
{
	std::wstring result;
	size_t length = 1024;
	result.resize(length);
	MCIERROR err = mciSendString(command.c_str(), &result[0], (UINT)length, NULL);
	if (err) throw MediaError(err);
	return result;
}

class SoundHandler {
private:
	AddInNative& addin;
	std::wstring uuid;
	std::wstring filename;
	MCIDEVICEID device = 0;
public:
	static SoundHandler* get(HWND hWnd) {
		return (SoundHandler*)GetWindowLongPtr(hWnd, GWLP_USERDATA);
	}
	SoundHandler(AddInNative& addin, const std::wstring& uuid, const std::wstring& filename)
		: addin(addin), uuid(uuid), filename(filename) {}
	bool Open();
	bool Play();
	bool Stop();
	bool Close();
};

LRESULT CALLBACK SoundWndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_SOUND_STOP:
		SoundHandler::get(hWnd)->Stop();
		return 0;
	case MM_MCINOTIFY:
		SendMessage(hWnd, WM_DESTROY, 0, 0);
		return 0;
	case WM_DESTROY:
		SoundHandler::get(hWnd)->Close();
		PostQuitMessage(0);
		return 0;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
}

bool SoundHandler::Open()
{
	MCI_OPEN_PARMS mciOpenParms = { 0 };
	mciOpenParms.lpstrDeviceType = NULL;
	mciOpenParms.lpstrElementName = filename.c_str();
	auto opReturn = mciSendCommand(NULL, MCI_OPEN, MCI_OPEN_ELEMENT, (DWORD_PTR)&mciOpenParms);
	if (opReturn != 0) return false;
	device = mciOpenParms.wDeviceID;
	return true;
}

bool SoundHandler::Play()
{
	WNDCLASS wndClass = {};
	wndClass.hInstance = hModule;
	wndClass.lpfnWndProc = SoundWndProc;
	wndClass.lpszClassName = wsSoundName;
	RegisterClass(&wndClass);

	HWND hWnd = CreateWindow(wsSoundName, uuid.c_str(), 0, 0, 0, 0, 0, HWND_MESSAGE, NULL, hModule, 0);
	SetWindowLongPtr(hWnd, GWLP_USERDATA, (LONG_PTR)this);

	MCI_PLAY_PARMS params = {};
	params.dwCallback = (DWORD_PTR)hWnd;
	return mciSendCommand(device, MCI_PLAY, MCI_NOTIFY, (DWORD_PTR)&params) == 0;
}

bool SoundHandler::Stop()
{
	return mciSendCommand(device, MCI_STOP, MCI_WAIT, 0) == 0;
}

bool SoundHandler::Close()
{
	addin.ExternalEvent(u"SOUND_FINISHED", (char16_t*)uuid.c_str());
	return mciSendCommand(device, MCI_CLOSE, MCI_WAIT, 0) == 0;
}

static DWORD WINAPI EffectThreadProc(LPVOID lpParam)
{
	std::unique_ptr<SoundHandler> params{ (SoundHandler*)lpParam };
	if (params->Open()) {
		params->Play();
		MSG msg;
		while (GetMessage(&msg, NULL, 0, 0)) {
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	return 0;
}

void SoundEffect::PlayMedia(AddInNative& addin, const std::wstring& uuid, const std::wstring& filename)
{
	HWND hWnd = FindWindowEx(NULL, NULL, wsSoundName, uuid.c_str());
	if (hWnd) SendMessage(hWnd, WM_SOUND_STOP, 0, 0);
	if (filename.empty()) return;
	auto params = new SoundHandler(addin, uuid, filename);
	CreateThread(0, NULL, EffectThreadProc, (LPVOID)params, NULL, NULL);
}

bool SoundEffect::PlayingMedia(const std::wstring& uuid)
{
	return FindWindowEx(NULL, NULL, wsSoundName, uuid.c_str());
}

#endif //_WINDOWS
