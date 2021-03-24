!Prototypes and Equates to Call SHAutoComplete
!Located in ShLwAPI.DLL so you'll need to link in ShLwAutoCompLIB, or LoadLibrary and GetProcAddress 
!This DLL was shipped with IE 6 which is XP. Improvements in IE 7 with Vista. 
!Tested to work with ENTRY and TEXT,SINGLE. 
!Worked with TEXT multi-line but could NOT Tab out of control, had to use mouse.
!
! How to Use
! E.g. to allow a AutoComplete of Directories:
!       SHAutoComplete( ?DirName{PROP:Handle}, SHACF_FILESYS_DIRS)

  MAP 
    module('win32')
         !https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-shautocomplete
         SHAutoComplete(SIGNED hwndEdit, LONG dwFlags ),PASCAL,DLL(1),LONG,PROC  !Returns HResult < 0 if failed
  
         !MSDN: "WARNING: Caller needs to have called CoInitialize() or OleInitialize()".
         !Must do if calling SHAutoComplete() before Event:OpenWindow (probably RTL calls by then) 
         !Mustbe called once per thread
         !Renamed "ShoAuto_Xxx" to not conflict with any other includes
         SHAuto_CoInitialize(long = 0),PASCAL,DLL(1),LONG,PROC,NAME('CoInitialize')

    end    
  END

SHACF_DEFAULT       EQUATE(00000000h)  !Equivalent to SHACF_FILESYSTEM | SHACF_URLALL. SHACF_DEFAULT cannot be combined with any other flags.

SHACF_FILESYS_ONLY  EQUATE(00000010h)  !Include the file system only. Files and Dirs.
SHACF_FILESYS_DIRS  EQUATE(00000020h)  !Include the only directories, UNC servers, and UNC server shares. No files.
SHACF_FILESYSTEM    EQUATE(00000001h)  !Include the file system and the rest of the Shell (Desktop, Computer, and Control Panel, for example).

SHACF_URLHISTORY    EQUATE(00000002h)  !Include the URLs in the user's History list.
SHACF_URLMRU        EQUATE(00000004h)  !Include the URLs in the user's Recently Used list.

SHACF_VIRTUAL_NAMESPACE EQUATE(00000040h) !VISTA - Include the Shell Virtual NameSpace of nonfile system virtual objects 

SHACF_USETAB                 EQUATE(00000008h)  !Use the tab to move thru the autocomplete possibilities instead of to the next dialog/window control.
! Allow the user to select from the autosuggest list by pressing the TAB key.
! If this flag is not set, pressing the TAB key will shift focus to the next 
! control and close the autosuggest list.
! If SHACF_USETAB is set, pressing the TAB key will select the first item
! in the list. Pressing TAB again will select the next item in the list,
! and so on. When the user reaches the end of the list, the next TAB key
! press will cycle the focus back to the edit control.

!VISTA - These flags ignore the registry default and force the feature on or off. 
!These flags only worked with a TEXT,SINGLE for me, not for ENTRY (except SHACF_AUTOAPPEND_FORCE_OFF)
SHACF_AUTOSUGGEST_FORCE_ON   EQUATE(10000000h)  !Force AutoSuggest On 
SHACF_AUTOSUGGEST_FORCE_OFF  EQUATE(20000000h)  !Force AutoSuggest Off
SHACF_AUTOAPPEND_FORCE_ON    EQUATE(40000000h)  !Force AutoAppend  On   (Also know as AutoComplete)
SHACF_AUTOAPPEND_FORCE_OFF   EQUATE(80000000h)  !Force AutoAppend  Off  This turns it OFF. Only way yo turn Off on a control you turned on.  

!AutoSuggest means that the control displays a list of matching items and the 
!            user can select one of these using either the mouse or the up/down arrow keys.
!
!AutoAppend means that the control automatically appends the first matching 
!           item to the user input and selects it, so that it gets overwritten 
!           if the user continues typing. The user can use TAB to switch focus 
!           to the next control in which case he will accept the suggestion.



