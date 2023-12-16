#include <Windows.h>
#include "resource.h"
#include "atlstr.h"
#include "tlhelp32.h"
#include <fstream>
#include <string>
#include <iostream>
#include "Scintilla.h"
#include "SciLexer.h"
using namespace std;
HMENU hMenu;
BOOL CALLBACK DlgProc(HWND, UINT, WPARAM, LPARAM);
int WriteFile(char *fileName, char *content);
void WcharToChar(const wchar_t* wp, char *& m_char);
int isSuc();
void DisplayError(char *errorFile);
int RunBatchFile(int cktp);
void CompileLinkRunCpp(HWND);
void CompileRunJava(HWND hWnd);
string errfl();
WNDPROC wpOrigEditProc;
WNDPROC wpOrigEditProc2;
HWND hwndScintilla = NULL;
HINSTANCE hin = NULL;
LRESULT SendEditor(UINT Msg, WPARAM wParam = 0L, LPARAM lParam = 0L)
{
	return ::SendMessage(hwndScintilla, Msg, wParam, lParam);
}
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
	hin = hInstance;
	LoadLibrary(L"..\\ScintillaSimpleIDE\\include\\SciLexer.dll");
	hMenu = LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENU1));
	DialogBox(hInstance, MAKEINTRESOURCE(IDD_DIALOG1), NULL, DlgProc);
	return 0;
}
void WcharToChar(const wchar_t* wp, char *& m_char)
{
	CString str;
	int len = WideCharToMultiByte(CP_ACP, 0, wp, wcslen(wp), NULL, 0, NULL, NULL);
	m_char = new char[len + 1];
	WideCharToMultiByte(CP_ACP, 0, wp, wcslen(wp), m_char, len, NULL, NULL);
	m_char[len] = '\0';
	str = m_char;
}
int WriteFile(char *fileName, char *content)
{
	DeleteFileA(fileName);
	fstream of;
	of.open(fileName, ios_base::out);
	of.write(content, strlen(content));
	of.close();
	return 1;
}
int RunBatchFile(int cktp)
{
	SHELLEXECUTEINFO sei;
	memset(&sei, 0, sizeof(SHELLEXECUTEINFO));
	sei.cbSize = sizeof(SHELLEXECUTEINFO);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS;
	sei.lpVerb = _T("open");
	sei.lpFile = _T("make.bat");
	if (cktp == 2)
		sei.nShow = SW_SHOWDEFAULT;
	else
		sei.nShow = SW_HIDE;
	ShellExecuteEx(&sei);
	WaitForSingleObject(sei.hProcess, INFINITE);
	CloseHandle(sei.hProcess);
	return 0;
}
void DisplayError(char *errorFile)
{
	char commandStr[1024];
	sprintf_s(commandStr, "notepad %s", errorFile);
	char s1[] = "make.bat";
	WriteFile(s1, commandStr);
	RunBatchFile(2);
}
int isSuc()
{
	char errfl[20] = "error.txt";
	FILE *fp;
	fopen_s(&fp, errfl, "r");
	char tmp[102300] = "";
	char ch;
	int i = 0;
	if (fp)
	{
		while (fread(&ch, 1, 1, fp) == 1)
		{
			tmp[i++] = ch;
		}
	}
	fclose(fp);
	if (strstr(tmp, "error"))
	{
		return 0;
	}
	else if (strstr(tmp, "错误"))
	{
		return 0;
	}
	else
	{
		return 1;
	}

}
void CompileLinkRunCpp(HWND hWnd)
{
	HWND hEdit = hwndScintilla;
	wchar_t lsDir[300], lsOldDir[200];
	wchar_t wcharBuf[10000];
	//int len = GetWindowTextW(hEdit, wcharBuf, 10000);
	int len = SendEditor(SCI_GETLENGTH);
	GetCurrentDirectory(200, lsOldDir);
	wsprintf(lsDir, L"%s\\IDE", lsOldDir);
	SetCurrentDirectory(lsDir);
	if (len > 0)
	{
		char *pBuf = new char[len];
		//WcharToChar(wcharBuf, pBuf);
		SendEditor(SCI_GETTEXT,len + 1, (LPARAM)pBuf);
		char f1[] = "test.cpp";
		char f2[] = "test.obj";
		char f3[] = "error.txt";
		char f4[] = "make.bat";
		WriteFile(f1, pBuf);
		if (pBuf)
		{
			//delete[] pBuf;
		}
		DeleteFileA(f2);
		DeleteFileA(f3);
		char compileStr[] = ".\\tools\\cl test.cpp /MD /0x /0t /W3 /c /EHsc /I\".\\tools\\Include\" > error.txt";
		WriteFile(f4, compileStr);
		RunBatchFile(1);
		int rec = 0;
		if (rec = isSuc())
		{
			DeleteFileA("text.exe");
			DeleteFileA("error.txt");
			char linkStr[] = ".\\tools\\link test.obj /LIBPATH:\".\\tools\\lib\" /OUT:test.exe > error.txt";
			WriteFile(f4, linkStr);
			RunBatchFile(1);
			if (rec = isSuc())
			{
				char runStr[] = "test.exe \n pause";
				WriteFile(f4, runStr);
				RunBatchFile(2);
			}
		}
		if (rec == 0)
		{
			//DisplayError(f3);
		}
	}
	SetCurrentDirectory(lsOldDir);
}
void CompileRunJava(HWND hWnd)
{
	HWND hEdit = hwndScintilla;
	wchar_t lsDir[300], lsOldDir[200];
	wchar_t wcharBuf[10000];
	//int len = GetWindowTextW(hEdit, wcharBuf, 10000);
	int len = SendEditor(SCI_GETLENGTH);
	GetCurrentDirectory(200, lsOldDir);
	wsprintf(lsDir, L"%s\\IDE", lsOldDir);
	SetCurrentDirectory(lsDir);
	if (len > 0)
	{
		char *pBuf = new char[len];
		//WcharToChar(wcharBuf, pBuf);
		SendEditor(SCI_GETTEXT, len + 1, (LPARAM)pBuf);
		char f1[] = "Test.java";
		char f2[] = "Test.class";
		char f3[] = "error.txt";
		char f4[] = "make.bat";
		WriteFile(f1, pBuf);
		if (pBuf)
		{
			//delete[] pBuf;
		}
		DeleteFileA(f2);
		DeleteFileA(f3);
		char compileStr[] = "javac -cp . Test.java 2> error.txt";
		WriteFile(f4, compileStr);
		RunBatchFile(1);
		int rec = 0;
		if (rec = isSuc())
		{
			char runStr[] = "java Test \n pause";
			WriteFile(f4, runStr);
			RunBatchFile(2);
		}
		if (rec == 0)
		{
			//DisplayError(f3);
		}
	}
	SetCurrentDirectory(lsOldDir);
}
string errfl()
{
	wchar_t lsDir[300], lsOldDir[200];
	GetCurrentDirectory(200, lsOldDir);
	wsprintf(lsDir, L"%s\\IDE", lsOldDir);
	SetCurrentDirectory(lsDir);
	string str = "";
	ifstream in("error.txt");
	string filename;
	string line = "";

	if (in)
	{
		while (getline(in, line))
		{
			str += line;
			str += "\r\n";
		}
	}

	return str;

}
BOOL CALLBACK EditSubClassProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	if (uMsg == WM_GETDLGCODE)
		return DLGC_WANTALLKEYS;
	return CallWindowProc(wpOrigEditProc, hWnd, uMsg, wParam, lParam);
}
BOOL CALLBACK DlgProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	const char* szKeywords1 =
		"asm auto break case catch class const "
		"const_cast continue default delete do double "
		"dynamic_cast else enum explicit extern false "
		"for friend goto if inline mutable "
		"namespace new operator private protected public "
		"register reinterpret_cast return signed "
		"sizeof static static_cast struct switch template "
		"this throw true try typedef typeid typename "
		"union unsigned using virtual volatile while";
	const char* szKeywords2 =
		"bool char float int long short void wchar_t";
	const char* szKeywords3 =
		"HWND UINT WPARAM LPARAM HINSTANCE PSTR";
	HWND hEdit, hEdit2;

	TCHAR e1[10000];
	CString CppDefault = CString(L"//初始化一个C++程序\r\n");
	CppDefault += L"#include <stdio.h>\r\n";
	CppDefault += L"int main(void)\r\n";
	CppDefault += L"{\r\n";
	CppDefault += L"\tprintf(\"Hello World!\");\r\n";
	CppDefault += L"\treturn 0;\r\n";
	CppDefault += L"}\r\n";
	CString JavaDefault = CString(L"//初始化一个Java程序\r\n");
	JavaDefault += L"public class Test {\r\n";
	JavaDefault += L"\tpublic static void main(String[] args) {\r\n";
	JavaDefault += L"\tSystem.out.println(\"Hello World!\");\r\n";
	JavaDefault += L"\t}\r\n}\r\n";
	int len = WideCharToMultiByte(CP_ACP, 0, CppDefault, -1, NULL, 0, NULL, NULL);
	char *buf = new char[len + 1];
	WideCharToMultiByte(CP_ACP, 0, CppDefault, -1, buf, len, NULL, NULL);
	int len1 = WideCharToMultiByte(CP_ACP, 0, JavaDefault, -1, NULL, 0, NULL, NULL);
	char *buf1 = new char[len1 + 1];
	WideCharToMultiByte(CP_ACP, 0, JavaDefault, -1, buf1, len1, NULL, NULL);
	switch (msg)
	{
	case WM_INITDIALOG:
		SetMenu(hWnd, hMenu);
		hEdit = hwndScintilla;
		hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);
		//wpOrigEditProc = (WNDPROC)SetWindowLong(hEdit, GWL_WNDPROC, (LONG)EditSubClassProc);
		//wpOrigEditProc2 = (WNDPROC)SetWindowLong(hEdit2, GWL_WNDPROC, (LONG)EditSubClassProc);
		hwndScintilla = CreateWindowEx(0, L"Scintilla", L"", WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_CLIPCHILDREN, 0, 40, 980, 300, hWnd, NULL, hin, NULL);
		ShowWindow(hwndScintilla, SW_SHOW);
		UpdateWindow(hwndScintilla);

		// 设置全局风格
		SendEditor(SCI_STYLESETFONT, STYLE_DEFAULT, (sptr_t)"Courier New");
		SendEditor(SCI_STYLESETSIZE, STYLE_DEFAULT, 10);
		SendEditor(SCI_STYLECLEARALL);
		//C++语法解析
		SendEditor(SCI_SETLEXER, SCLEX_CPP);
		SendEditor(SCI_SETKEYWORDS, 0, (sptr_t)szKeywords1);//设置关键字
		SendEditor(SCI_SETKEYWORDS, 1, (sptr_t)szKeywords2);//设置关键字
		SendEditor(SCI_SETKEYWORDS, 2, (sptr_t)szKeywords3);//设置关键字
		// 下面设置各种语法元素风格
		SendEditor(SCI_STYLESETFORE, SCE_C_WORD, 0x00FF0000);   //关键字
		SendEditor(SCI_STYLESETFORE, SCE_C_WORD2, 0x00800080);   //关键字
		SendEditor(SCI_STYLESETBOLD, SCE_C_WORD2, TRUE);   //关键字
		SendEditor(SCI_STYLESETFORE, SCE_C_STRING, 0x001515A3); //字符串
		SendEditor(SCI_STYLESETFORE, SCE_C_CHARACTER, 0x001515A3); //字符
		SendEditor(SCI_STYLESETFORE, SCE_C_PREPROCESSOR, 0x00808080);//预编译开关
		SendEditor(SCI_STYLESETFORE, SCE_C_COMMENT, 0x00008000);//块注释
		SendEditor(SCI_STYLESETFORE, SCE_C_COMMENTLINE, 0x00008000);//行注释
		SendEditor(SCI_STYLESETFORE, SCE_C_COMMENTDOC, 0x00008000);//文档注释（/**开头）

		SendEditor(SCI_SETCARETLINEVISIBLE, TRUE);
		SendEditor(SCI_SETCARETLINEBACK, 0xb0ffff);
		SendEditor(SCI_SETTABWIDTH, 4);
		SendEditor(SCI_SETMARGINTYPEN, 1, SC_MARGIN_NUMBER);
		SendEditor(SCI_SETMARGINWIDTHN, 1, 30);
		return TRUE;
	case WM_COMMAND:
		switch (wParam)
		{
		case IDC_BUTTON1:
			hEdit = hwndScintilla;
			hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);	
			SendEditor(SCI_SETTEXT, 0, (LPARAM)buf);
			break;
		case IDC_BUTTON2:
			hEdit = hwndScintilla;
			hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);
			SendEditor(SCI_SETTEXT, 0, (LPARAM)buf1);
			break;
		case IDC_CPP:
			CompileLinkRunCpp(hWnd);
			hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);
			MultiByteToWideChar(CP_ACP, 0, errfl().c_str(), -1, e1, 10000);
			SetWindowText(hEdit2, e1);
			break;
		case IDC_JAVA:
			CompileRunJava(hWnd);
			hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);
			MultiByteToWideChar(CP_ACP, 0, errfl().c_str(), -1, e1, 10000);
			SetWindowText(hEdit2, e1);
			break;
		case ID_COMPILE_C:
			CompileLinkRunCpp(hWnd);
			hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);
			MultiByteToWideChar(CP_ACP, 0, errfl().c_str(), -1, e1, 10000);
			SetWindowText(hEdit2, e1);
			break;
		case ID_COMPILE_JAVA:
			CompileRunJava(hWnd);
			hEdit2 = GetDlgItem(hWnd, IDC_EDIT1);
			MultiByteToWideChar(CP_ACP, 0, errfl().c_str(), -1, e1, 10000);
			SetWindowText(hEdit2, e1);
			break;
		case ID_FILE_EXIT:
			EndDialog(hWnd, 0);
			return TRUE;
		case ID_HELP_ABOUT:
			MessageBox(NULL, TEXT("样例作者：Stallion-X\n2022/4/3 09:35"), TEXT("关于"), MB_ICONINFORMATION);
			break;
		}
		return TRUE;
	case WM_CLOSE:
		EndDialog(hWnd, 0);
		return TRUE;
	}
	return FALSE;
}
