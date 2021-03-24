!CBAutoCompClass by Carl Barnes. (c) 2019 by Carl Barnes for CIDC 2019 - Released under MIT LICENSE
!Easy way to call Shell SHAutoComplete() so an ENTRY can have Popup of Files, Folders, URLs
!This does LoadLibrary on SwLwAPI.dll so does not Require link of LIB
!
!Example:
!AutoCmpCls   CBAutoCompClass  !Do NOT &CBAuto and NEW() to be sure Destructed after windows is closed
!   CODE
!   OPEN(Window)
!   AutoCmpCls.AC_FileSys_Dirs(?PathName)   !Only directories


!--------------------------------------------------------------------------------
CBAutoCompClass CLASS,Type,Module('CBAutoCompAPI.Clw'),DLL(0),Link('CBAutoCompAPI.Clw',1)
ConstructFailed LONG!,PROTECTED  !Must load ShLwApi.DLL  0=Worked, else 1=DLL Prob
LoadError       LONG!,PROTECTED
CONSTRUCT       PROCEDURE()    !Load Library. Also calls CoInitialize().
DESTRUCT        PROCEDURE()    !Calls CoUnInitialize().
Init            PROCEDURE(BYTE pShowDebug=0)   !Does nothing, but can show debug message
FunWithFlags    PROCEDURE(LONG FEQ, LONG SHACF_Flags),LONG,PROC,VIRTUAL  !Pass Control and Flags, Returns HResult

AC_Default      PROCEDURE(LONG FEQ),LONG,PROC                        !Default FILESYSTEM + URLALL, No other flags
AC_FileSys_Only PROCEDURE(LONG FEQ, BYTE PlusVirtualNS=0),LONG,PROC  !File system only. Files and Dirs.
AC_FileSys_Dirs PROCEDURE(LONG FEQ, BYTE PlusVirtualNS=0),LONG,PROC  !Only directories, UNC servers, and UNC server shares. No files.
AC_FileSystem   PROCEDURE(LONG FEQ, BYTE PlusVirtualNS=0),LONG,PROC  !File system and the rest of the Shell (Desktop, Computer, and Control Panel
AC_UrlHistory   PROCEDURE(LONG FEQ ),LONG,PROC                      !URLs in the user's History list.
AC_UrlMRU       PROCEDURE(LONG FEQ ),LONG,PROC                      !URLs in the user's Recently Used list.
AC_UrlALL       PROCEDURE(LONG FEQ ),LONG,PROC                      !URLs in the user's History and MRU

ACFlag_AutoAppend  PROCEDURE(BYTE Force_OnOffOmit_123)    !SHACF_AUTOSUGGEST_FORCE_ 1=ON 2=OFF 3=Omit
ACFlag_AutoSuggest PROCEDURE(BYTE Force_OnOffOmit_123)    !SHACF_AUTOAPPEND_FORCE_  1=ON 2=OFF 3=Omit
ACFlag_UseTab      PROCEDURE(BYTE OnOff12)                !1=CBAC_SHACF_USETAB did not seem to work
ACFlags            PROCEDURE(<BYTE Append>, <BYTE Suggest>, <BYTE UseTab>),VIRTUAL  !Set all 3 flags 1=ForceOn 2=ForceOff 3=Omit Setting

Worker4AC       PROCEDURE(LONG pFEQ, LONG pFlags, BYTE pPlusVirtualNS=0),LONG,PROTECTED,VIRTUAL     !For AC_xxx call ShAuto
ACLastFlags     LONG                !Last Flags used by Worker4AC
ACFlgAppend     LONG,PROTECTED
ACFlgSuggest    LONG,PROTECTED
ACFlgUseTab     LONG,PROTECTED
CoInitCount     SHORT!,PROTECTED    !Count CoInitialize been called so Destruct can CoUnInit. Set to zero to Prevent

IsDirectory     PROCEDURE(STRING pDirName),BOOL  !True if Directory, else False if File or not exists
IsFile          PROCEDURE(STRING pFileName),BOOL !True if File, else False if Directory or not exists
GetAttributes   PROCEDURE(STRING pFileOrDir, *LONG OutAttribs),BOOL,PROC !False if File does not exist (and Attrib=-1)
             End !Class


!Fun with Flags

CBAC_SHACF_DEFAULT       EQUATE(00000000h)  !Equivalent to _FILESYSTEM | _URLALL. _DEFAULT cannot be combined with any other flags.

CBAC_SHACF_FILESYS_ONLY  EQUATE(00000010h)  !Include the file system only. Files and Dirs.
CBAC_SHACF_FILESYS_DIRS  EQUATE(00000020h)  !Include the only directories, UNC servers, and UNC server shares. No files.
CBAC_SHACF_FILESYSTEM    EQUATE(00000001h)  !Include the file system and the rest of the Shell (Desktop, Computer, and Control Panel, for example).

CBAC_SHACF_URLHISTORY    EQUATE(00000002h)  !Include the URLs in the user's History list.
CBAC_SHACF_URLMRU        EQUATE(00000004h)  !Include the URLs in the user's Recently Used list.

CBAC_SHACF_VIRTUAL_NAMESPACE EQUATE(00000040h) !VISTA - Include the Shell Virtual NameSpace of nonfile system virtual objects

CBAC_SHACF_USETAB                 EQUATE(00000008h)  !Use the tab to move thru the autocomplete possibilities instead of to the next dialog/window control.
! Allow the user to select from the autosuggest list by pressing the TAB key.
! If this flag is not set, pressing the TAB key will shift focus to the next
! control and close the autosuggest list.
! If SHACF_USETAB is set, pressing the TAB key will select the first item
! in the list. Pressing TAB again will select the next item in the list,
! and so on. When the user reaches the end of the list, the next TAB key
! press will cycle the focus back to the edit control.

!VISTA - These flags ignore the registry default and force the feature on or off.
!These flags only worked with a TEXT,SINGLE for me, not for ENTRY (except SHACF_AUTOAPPEND_FORCE_OFF)
CBAC_SHACF_AUTOSUGGEST_FORCE_ON   EQUATE(10000000h)  !Force AutoSuggest On
CBAC_SHACF_AUTOSUGGEST_FORCE_OFF  EQUATE(20000000h)  !Force AutoSuggest Off
CBAC_SHACF_AUTOAPPEND_FORCE_ON    EQUATE(40000000h)  !Force AutoAppend  On   (Also know as AutoComplete)
CBAC_SHACF_AUTOAPPEND_FORCE_OFF   EQUATE(80000000h)  !Force AutoAppend  Off  This turns it OFF. Only way yo turn Off on a control you turned on.

!AutoSuggest means that the control displays a list of matching items and the
!            user can select one of these using either the mouse or the up/down arrow keys.
!
!AutoAppend means that the control automatically appends the first matching
!           item to the user input and selects it, so that it gets overwritten
!           if the user continues typing. The user can use TAB to switch focus
!           to the next control in which case he will accept the suggestion.

