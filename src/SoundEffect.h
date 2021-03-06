#pragma once

#ifdef _WINDOWS
#include <windows.h>

#undef PlaySound

class AddInNative;

class SoundEffect {
public:
	static std::wstring MediaCommand(const std::wstring& command);
	static BOOL PlaySound(const std::wstring& filename, bool async);
	static void PlayMedia(AddInNative& addin, const std::wstring& filename, const std::wstring& uuid);
	static bool PlayingMedia(const std::wstring& uuid);
	static void StopMedia(const std::wstring& uuid);
};

#endif //_WINDOWS
