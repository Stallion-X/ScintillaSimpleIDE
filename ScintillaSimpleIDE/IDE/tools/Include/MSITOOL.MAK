# Makefile for use with MSI to build custom actions, tests or tools.
#
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
# Copyright (C) 1997  Microsoft Corporation.  All Rights Reserved.
#
# Must define the following (unless optional or default is indicated) using one of:
#   1. command line to nmake.exe (syntax: MACRO=value) (highest precedence)
#   2. in outer makefile that !include this (typically a header section in .CPP file)
#   3. environment variable
#
#  MODULENAME=   base name of .cpp file to build .exe or .dll with same base name
#  SUBSYSTEM=    "console" or "windows" for EXE, do not define if DLL unless "RESOURCE"
#  UNICODE=1  to compile Unicode executables (default is ANSI)
#  ENTRY=     entrypoints (comma separated) for DLL or non-standard entry point for EXE
#  VERSION=  "SHIP" or "DEBUG" or "CVPACK" or "NOBSC"(no browser files, the default)

# Options to generate a version resource (recommended)
#
#  FILEVERSION=  specify MM.mm to generate version resource (=MSI to track MSI version)
#  PRODUCTVERSION=  product version for resource, defaults to FILEVERSION
#  DESCRIPTION=  description for use in version resource (if FILEVERSION defined)
#  COMPANYNAME=  company name to use in version resource (if FILEVERSION defined)

# Build options that will generally need to be set
#
#  INCLUDE=   include path for compiler, should include MSI.H, MSIQUERY.H (unless MSIPROJ set)
#  LIB=       lib path for use by linker, should include MSI.LIB (unless MSIPROJ set)

# Options that may be used in special cases, not needed for simple builds
#
#  ADDCPP=    optional comma-separated list of additional CPP files to compile
#  DEPEND=    optional list of additional make dependents, normally include files
#  LINKLIBS=  additional libraries to link, standard libraries are:
#             kernel32.lib user32.lib advapi32.lib libc.lib version.lib gdi32.lib
#  BUILDDIR=  to override default: SHIP|DEBUG|CVPACK under current dir (unless MSIPROJ set)
#  MSILIB=    full path to MSI import lib, defaults to MSI.LIB using lib path search rules
#  VCBIN=     directory of all MSVC executables, else uses MSDevDir & MSVCDir, else PATH
# Note: For VC5 use, if MSDevDir is defined, then MSVCDir must also be defined (VCVARS32.BAT)

#-----------------------------------------------------------------------------
# directory resolution
#-----------------------------------------------------------------------------

!ifndef MODULENAME
!error Must define MODULENAME to base name of .cpp file
!endif

!ifndef MODULESRC
MODULESRC = .
!endif

!ifndef VERSION
VERSION = NOBSC
!endif
!if "$(VERSION)"=="SHIP"
_subdir_ = SHIP
!else if "$(VERSION)"=="DEBUG" || "$(VERSION)"=="NOBSC"
_subdir_ = DEBUG
!else if "$(VERSION)"=="CVPACK"
_subdir_ = CVPACK
!else
!error Must define VERSION to SHIP or CVPACK, or DEBUG or NOBSC(default)
!endif

!ifdef MSIPROJ
BUILDDIR   = $(MSIPROJ)\build\$(_subdir_)
COMMONDIR  = $(MSIPROJ)\build\common
MSICPP     = -I$(COMMONDIR)
!else
!ifndef BUILDDIR
BUILDDIR   = $(MODULESRC)\$(_subdir_)
!endif
!endif

OBJDIR = $(BUILDDIR)\OBJECT

#-----------------------------------------------------------------------------
# build model processing
#-----------------------------------------------------------------------------

!ifdef PROCESSOR_ARCHITECTURE
PLATFORM = $(PROCESSOR_ARCHITECTURE)
!else
PLATFORM = x86
!endif
!if "$(PLATFORM)" == "x86" || "$(PLATFORM)" == "X86"
_machine_ = /MACHINE:IX86
!else if "$(PLATFORM)" == "alpha" || "$(PLATFORM)" == "ALPHA"
_machine_ = /MACHINE:ALPHA
!else
!error Must define PLATFORM to x86 or ALPHA
!endif

ALIGN = -align:0x1000

_objects_ = $(OBJDIR)\$(MODULENAME).obj
!ifdef SUBSYSTEM
!if defined(ENTRY)
ENTRY = /ENTRY:$(ENTRY)
!else if "$(SUBSYSTEM)" == "console" || "$(SUBSYSTEM)" == "CONSOLE"
!ifdef UNICODE
ENTRY = /ENTRY:wmainCRTStartup
!elseџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ<џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџIёЮЋc=НМёВIG|WџрПxіМб/    В>щќkЪЋ+EжЊQБїП<>[СzEњKГ"YкxWдЕЏxzиЈeuџ \и:ЫSГЌДy
rrG#ИЉOs^ЂЯ*Єu*OЈl#цЙXYнмяй"Ы АоѕЭрбб^ѕЬщ$K8Јк#щRhњj	b'cђи5љ>qЅF}=5xО!вОбlь(фњЕбъ6sјѓHлІ<юЈъkЦУIГ*ЈгёмёlHvЃеcgЧ)ДuЏ%ёnЇ,mхЋнЭkуxЏПЁюхpКЙЫШІHР$Ї­TИЛkDyДgмћWЧAsI#шцвмУІЏ<;aЌO!цљЅЌбф.GђЎ7Wёњэдvc9lЄ`ЋєЏГРSt ЋяM%HPлЧ<мЅ[еu}OH}AQт K|}@я_[тф ЯFкіЊnя%cцrxнUЭчЪx8яоПdЫщrSGPЇwxЭчоГonМБЩ$њgЅzi3Qд[?AXЗли5IиRЄкСљeђ8єЊбы$FљЈ3ЧZЛУЕўФDџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ  џџ   џџџџ  џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџw­ІљќхШ`zѓ2щrЮчЯчqцв>§БmЕmЩг[-ЂУ%Њhх c#5СќOУ_зєэoJвЃбЏ-мJV8Тч8 pkшЋтyщк,јшб[Йшv_ЕХЅИ3щv[vх'Н^mуЯ:ФXУzцц9еђбvэ^цЉa9щeЯкѓoХЏј_IK9oѕaЊн2[s'їw
ђWсЇЄk]_^къ:\и0<D0ЧПЁЎ<LTсЬїЙKф&[=*Ъ+HbэJФ4@oШєЏ"ёп-5k7:ЖкЏpьUёc_7&у+Г & y |M` s   Ў  З n j k oЛI ­ ) w * x     z  r m=   ,     l +  Ж Ё Ѕ Ј  Ћ Ѓ  В } Г  Є   u  Фb G ~ф { І H 8V Љ p с Й и р А  Л   И t  Е ф ч №  С б Ђ Х Ц Ч Ш Щ Ъ Ь § џ Н Я  ќ :<  ж к i й ё л м н о з  пE в\ ѕ ђ ъ Р У ы ш ь э ю щ ц М є П ѓ ў я і ј њ ћ а -; љ Ю 	
 е !"#$%&'()*+,-./012345678ђFH 1IЫяѓєіїјљњћќ§ўџ 	
 ?ЊДr :zJГ kgmu s_qi{Іv?ЗЁ~ЂfnшЏdЕЩаОП ;ьUг BХЧЄ^Бл}еpБЎxЖВбиЅЌМКм ТнРN дщыцC№в>ЪШЙЭЮ ЭУчЋкдЯжA ЇГтDйопёсНухэ .wюъЦзАt| ЌТ !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijkЄЅЇЈЉЋЌЎЏАЖИYИ / 0Ф 3lmnopqrstuvwxyz{ 2|}~P  6ROQр­ D 5 B ElЈ 7 <o@SС ѕy[ЁЂЃІ 9 Њ 4 > F C ­ =ВЬЗЕK @        ПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя№ёђѓєѕіїјљњћќ§ўџ 	
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ЁЂЃЄЅІЇЈЉЊЋЌ­ЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШ3ЩЪЫЬЭЮЯабвгдежзийклмнопрстуфхцчшщъыьэюя№ёђѓєѕіїјљњћќ§ўџ 	
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefgџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџWUPGFED7  џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџbђRЄfowzНd_й~љя|узД@ьgюѓЗЂFѕ(ЏqЪifѓЇРмН9%tзСЅщ[	"gД 6­ CyЉyЉy CЉ CЉ CЉ CЉФДy C Fy@ѕЉФД AДЙКЉЛМНОіЯY:KЬrЋНщє{9сPњЁдaд.ќїЗFДAlЦДшMыЅрсБ+г%ы=џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ     
  !    6xklо&ж'јeЏ§^џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ џџџџ џџџџџџ  џџџџLДWКњј^їэ
ЃќџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџWџџџџGџџџџџџ7џџџџoSЂU^rгяњЌыџ~ћџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ }< 2ЏЧ= Ї ѕР4ѕN+UхМѓE.йП­џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ 6џџџџ  џџџџџџ   џџџџo:еРseT№бyy§џџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџў -џџк  џџџџлџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџКтwН^вqѕu!{p9Ъо<PЋ[МЊоТ<{УЩЌMвЛхШ)є<ЖLЇ6;iYКежр{_Ћ "   $    ' %             ! $    % &     	      #          
  "  $  %  ' &        #  I@Д 6­ CyЉyЉy CЉ CЉ CЉ CЉФДy C Fy@ѕЉФД AДЙКЉЛМНО О Ы г т у х ї9GLTWXZ]acehjЃџџЮР       	  	=)	      и ' ' 2"H@A   A        ј=,Щ2Wо`&`ёqfЕюsзъqmЙbцГG&ВZилpЈгыђџdаuдЂ~pбзvюг)ЪW#C#km1Д0yаPѓЉQИdЕSф)(Yёmї+ИТЙјo<М$W6ц8phДђппB?ЉЇtЈФ­ќј§|[ЫЭуќОЛО№ђAЃG$fШ$d№3Ю?Л1Pщ.иTR+ YоулC\иЮQ9Йp  з   ' } *џџ  ЋW        ДOОYD8вuV1ТKX*ЕІ!Іh N      kPњюMi§Біњ)                                                                                                                                                                                                                                        ІЅ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ы8ПфдЛёDЅьп%l>бZћ=K[Ѓs=@PтЈйnqq%эўШЗ	cI гт КэЬCЅ:&|к~wєњєmк%[АW\;0<lЉЉхnЃ78FWсВXбIЉBн№ 