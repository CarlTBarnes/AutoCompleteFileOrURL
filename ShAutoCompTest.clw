!Example by Carl Barnes for CIDC 2019. 
!SHAutoComplete works for Clarion ENTRY, COMBO and TEXT,SINGLE to provide a handy popup list of files, Dirs, URLs
!This uses ShLwAutoComp.LIB to link in SHAutoComplete() from ShLwAPI.DLL the Shell Light Weight API
!Could LoadLibrary so no Static Link, but the ShLW DLL is always loaded 
!
!Auto Complete Drop List With 1 call to SHAutoComplete(Control{PROP:Handle}, Flags)

  PROGRAM
  INCLUDE('ShAutoComp_Global_INC.CLW'),ONCE  !The ShAuto MAP and Equates
    
  MAP
SHAutoCompleteTest  PROCEDURE()    
  END

  CODE
  !IF START(SHAutoCompleteTest).      !Test thread 2 also
  SHAutoCompleteTest() ; return
  
SHAutoCompleteTest  PROCEDURE() 
PathName   STRING(255)       
FileName   STRING(255)       
FileSystm  STRING(255)       
AnyAuto    STRING(255)       
UrlHist    STRING(255)       
UrlMRU     STRING(255)       
VirtNS     STRING(255)       
NotAuto    STRING(255)
ComboAuto  STRING(255)
EntryAuto  STRING(255)                     
EntryAuto2  STRING(255)                     
FlagTest2  STRING(255)                     
FlagTest3  STRING(255)                     
FlagTest4  STRING(255)                     
FlagTest5  STRING(255)                     
FlagTest6  STRING(255)                     
FlagTest7  STRING(255)                     
FlagTest8  STRING(255)                     
Text2Line   STRING(255)                     
Window WINDOW('SHAutoCompleteTest - Auto Complete Works with Clarion ENTRY, TEXT, COMBO using SHAutoComplete() in ShLwAPI.DLL'),AT(,,500,307),CENTER,GRAY,SYSTEM,ICON(ICON:Thumbnail),FONT('Segoe UI',9),DOUBLE
        STRING('xxx'),AT(6,2),HIDE
        STRING('TEXT,SINGLE Controls    -    Type C:\Windows\...      or for URL Type: www...        and see Drop List'),AT(49,2)
        PROMPT('Path Name:'),AT(6,15),USE(?PROMPT1)
        TEXT,AT(49,15,161,10),USE(PathName),SINGLE
        PROMPT('File Name:'),AT(6,28),USE(?PROMPT1:2)
        TEXT,AT(49,28,161,10),USE(FileName),SINGLE
        PROMPT('File System:'),AT(6,41),USE(?PROMPT1:2:fs)
        TEXT,AT(49,41,161,10),USE(FileSystm),SINGLE
        PROMPT('Default AC:'),AT(6,53),USE(?PROMPT1:3)
        TEXT,AT(49,53,161,10),USE(AnyAuto),SINGLE
        PROMPT('URL History:'),AT(6,66),USE(?PROMPT1:4)
        TEXT,AT(49,66,161,10),USE(UrlHist),SINGLE
        PROMPT('URL MRU'),AT(6,79),USE(?PROMPT1:5)
        TEXT,AT(49,79,161,10),USE(UrlMRU),SINGLE
        PROMPT('Virt NS+FS'),AT(6,92),USE(?PROMPT1:6)
        TEXT,AT(49,92,161,10),USE(VirtNS),SINGLE
        PROMPT('Not Auto:'),AT(6,105),USE(?PROMPT1:8)
        TEXT,AT(49,105,161,10),USE(NotAuto),SINGLE
        STRING('COMBO'),AT(50,119,103,10),USE(?STRING3)
        PROMPT('Path Name:'),AT(5,129),USE(?PROMPT1:Combo)
        COMBO(@s255),AT(50,129,161,10),USE(ComboAuto),DROP(9),FROM('From1|From2|From3')
        
        STRING('ENTRY(@s255)'),AT(50,146)
        PROMPT('Path Name:'),AT(6,155),USE(?PROMPT1:7)
        ENTRY(@s255),AT(50,155,161,10),USE(EntryAuto)
        ENTRY(@s255),AT(50,167,161,10),USE(EntryAuto2)
        STRING('TEXT,SINGLE Controls with Features. Does not work with ENTRY'),AT(49,184)
        PROMPT('Path Name:'),AT(6,195),USE(?PROMPT1:72)
        TEXT,AT(50,195,161,10),USE(FlagTest2),SINGLE
        PROMPT('Path Name:'),AT(6,206),USE(?PROMPT1:73)
        TEXT,AT(50,206,161,10),USE(FlagTest3),SINGLE
        PROMPT('Path Name:'),AT(6,218),USE(?PROMPT1:74)
        TEXT,AT(50,218,161,10),USE(FlagTest4),SINGLE
        PROMPT('Path Name:'),AT(6,230),USE(?PROMPT1:75)
        TEXT,AT(50,230,161,10),USE(FlagTest5),SINGLE
        PROMPT('Path Name:'),AT(6,242),USE(?PROMPT1:76)
        TEXT,AT(50,242,161,10),USE(FlagTest6),SINGLE
        PROMPT('Path Name:'),AT(6,254),USE(?PROMPT1:77)
        TEXT,AT(50,254,161,10),USE(FlagTest7),SINGLE
        PROMPT('Path Name:'),AT(6,266),USE(?PROMPT1:78)
        TEXT,AT(50,266,161,10),USE(FlagTest8),SINGLE
        PROMPT('Text 2:'),AT(6,280),USE(?PROMPT1:Text2)
        TEXT,AT(50,280,161,20),USE(Text2Line)
    END
 
HR          LONG   
SHAutoCls   CLASS
Init                PROCEDURE()
ShAutoComp1         PROCEDURE(LONG pFEQ,  LONG pFlags, STRING pFlagsString)
            END
    CODE
    OPEN(Window)
    SHAutoCls.Init()   !Works here but MUST call CoInitialize()
    ACCEPT
        CASE EVENT()
        OF EVENT:OpenWindow 
           !SHAutoCls.Init()   !Works here w/o CoInit call
        END 
        CASE ACCEPTED()

        END 
    END
    RETURN                 

SHAutoCls.Init   PROCEDURE()
    CODE
    SHAuto_CoInitialize()  !MSDN says must call CoInitialize once. It works without because probably RTL calls it
    SHAutoCls.ShAutoComp1(?PathName , SHACF_FILESYS_DIRS                         , 'SHACF_FILESYS_DIRS                        ')
    SHAutoCls.ShAutoComp1(?FileName , SHACF_FILESYS_ONLY                         , 'SHACF_FILESYS_ONLY                        ')
    SHAutoCls.ShAutoComp1(?FileSystm, SHACF_FILESYSTEM                           , 'SHACF_FILESYSTEM                        ')
    SHAutoCls.ShAutoComp1(?UrlHist  , SHACF_URLHISTORY                           , 'SHACF_URLHISTORY                          ')
    SHAutoCls.ShAutoComp1(?UrlMRU   , SHACF_URLMRU + SHACF_AUTOAPPEND_FORCE_ON   , 'SHACF_URLMRU + SHACF_AUTOAPPEND_FORCE_ON  ')
    SHAutoCls.ShAutoComp1(?VirtNS   , SHACF_VIRTUAL_NAMESPACE + SHACF_FILESYSTEM , 'SHACF_VIRTUAL_NAMESPACE + SHACF_FILESYSTEM')
    SHAutoCls.ShAutoComp1(?AnyAuto  , SHACF_DEFAULT                              , 'SHACF_DEFAULT                             ')
    SHAutoCls.ShAutoComp1(?ComboAuto, SHACF_FILESYS_DIRS  , 'SHACF_FILESYS_DIRS  ') !Would have thouhgt need to use FEQ of ENTRY part of COMBO 
    SHAutoCls.ShAutoComp1(?EntryAuto, SHACF_FILESYS_DIRS                         , 'SHACF_FILESYS_DIRS  ')  
    SHAutoCls.ShAutoComp1(?EntryAuto2, SHACF_FILESYS_DIRS + SHACF_AUTOAPPEND_FORCE_ON , 'SHACF_FILESYS_DIRS + SHACF_AUTOAPPEND_FORCE_ON ')  
    SHAutoCls.ShAutoComp1(?FlagTest2, SHACF_FILESYS_DIRS + SHACF_USETAB           , 'SHACF_FILESYS_DIRS + SHACF_USETAB')  
    SHAutoCls.ShAutoComp1(?FlagTest3, SHACF_FILESYS_DIRS + SHACF_AUTOSUGGEST_FORCE_ON  , 'SHACF_FILESYS_DIRS + SHACF_AUTOSUGGEST_FORCE_ON ')  
    SHAutoCls.ShAutoComp1(?FlagTest4, SHACF_FILESYS_DIRS + SHACF_AUTOSUGGEST_FORCE_OFF , 'SHACF_FILESYS_DIRS + SHACF_AUTOSUGGEST_FORCE_OFF')  
    SHAutoCls.ShAutoComp1(?FlagTest5, SHACF_FILESYS_DIRS + SHACF_AUTOAPPEND_FORCE_ON   , 'SHACF_FILESYS_DIRS + SHACF_AUTOAPPEND_FORCE_ON  ')  
    SHAutoCls.ShAutoComp1(?FlagTest6, SHACF_FILESYS_DIRS + SHACF_AUTOAPPEND_FORCE_OFF  , 'SHACF_FILESYS_DIRS + SHACF_AUTOAPPEND_FORCE_OFF ')  
    SHAutoCls.ShAutoComp1(?FlagTest7, SHACF_FILESYS_DIRS + SHACF_AUTOSUGGEST_FORCE_ON + SHACF_AUTOAPPEND_FORCE_ON , 'FILESYS_DIRS + AUTOSUGGEST_FORCE_ON + AUTOAPPEND_FORCE_ON')  
    SHAutoCls.ShAutoComp1(?FlagTest8, SHACF_FILESYS_DIRS + SHACF_AUTOSUGGEST_FORCE_OFF+ SHACF_AUTOAPPEND_FORCE_OFF, 'FILESYS_DIRS + AUTOSUGGEST_FORCE_OFF + AUTOAPPEND_FORCE_OFF')  
    SHAutoCls.ShAutoComp1(?Text2Line, SHACF_URLMRU , 'SHACF_URLMRU (Cannot tab out of Multiline Text)')  

    SHAutoCls.ShAutoComp1(?NotAuto, SHACF_URLMRU , 'SHACF_URLMRU')  
    SHAutoCls.ShAutoComp1(?NotAuto, SHACF_URLMRU , 'Turn Off with SHACF_AUTOSUGGEST_FORCE_OFF')  

!    !?NotAuto left alone
    RETURN

SHAutoCls.ShAutoComp1   PROCEDURE(LONG pFEQ,  LONG pFlags, STRING pFlagsString)   !, LONG pFEQString
X    LONG,AUTO
Y    LONG,AUTO
W    LONG,AUTO
H    LONG,AUTO
SEQ  LONG,AUTO
    CODE
    !  SHAutoComplete(SIGNED hwndEdit, LONG dwFlags ),PASCAL,DLL(1),RAW,LONG,PROC !,name('ChildWindowFromPointA')
     HR=SHAutoComplete(pFEQ{PROP:Handle}, pFlags ) 
     IF HR < 0 THEN  
        MESSAGE('FEQ ' & pFEQ & '|Flag ' & pFlags & |
                '||SHAutoComplete  HResult=' & HR)
     END
     GETPOSITION(pFEQ,X,Y,W,H)
     SEQ=CREATE(0,CREATE:String) 
     SETPOSITION(SEQ,X+W+10,Y)
     SEQ{PROP:Text}=CLIP(pFlagsString) & ' = ' & pFlags 
     UNHIDE(SEQ)
     RETURN
     
    OMIT('!-- dephi example AC ----') 
https://blog.dummzeuch.de/2014/06/09/autocomplete-for-tedits/

Autosuggest means that the control displays a list of matching items and the user can select one of these using either the mouse or the up/down arrow keys.

Autoappend means that the control automatically appends the first matching item to the user input and selects it, so that it gets overwritten if the user continues typing. The user can use TAB to switch focus to the next control in which case he will accept the suggestion.
    
  // Ignore the registry default and force the AutoAppend feature off.
  // This flag must be used in combination with one or more of the
  // SHACF_FILESYS* or SHACF_URL* flags.
  SHACF_AUTOAPPEND_FORCE_OFF = $80000000;

  // Ignore the registry value and force the AutoAppend feature on. The completed string will be
  // displayed in the edit box with the added characters highlighted.
  // This flag must be used in combination with one or more of the
  // SHACF_FILESYS* or SHACF_URL* flags.
  SHACF_AUTOAPPEND_FORCE_ON = $40000000;

  // Ignore the registry default and force the AutoSuggest feature off.
  // This flag must be used in combination with one or more of the
  // SHACF_FILESYS* or SHACF_URL* flags.
  SHACF_AUTOSUGGEST_FORCE_OFF = $20000000;

  // Ignore the registry value and force the AutoSuggest feature on.
  // A selection of possible completed strings will be displayed as a
  // drop-down list, below the edit box. This flag must be used in
  // combination with one or more of the
  // SHACF_FILESYS* or SHACF_URL* flags.
  SHACF_AUTOSUGGEST_FORCE_ON = $10000000;

  // The default setting, equivalent to
  // SHACF_FILESYSTEM | SHACF_URLALL.
  // SHACF_DEFAULT cannot be combined with any other flags.
  SHACF_DEFAULT = $00000000;

  // Include the file system only.
  SHACF_FILESYS_ONLY = $00000010;

  // Include the file system and directories, UNC servers, and UNC server shares.
  SHACF_FILESYS_DIRS = $00000020;

  // Include the file system and the rest of the Shell (Desktop, Computer, and Control Panel, for example).
  SHACF_FILESYSTEM = $00000001;

  // Include the URLs in the user's History list.
  SHACF_URLHISTORY = $00000002;

  // Include the URLs in the user's Recently Used list.
  SHACF_URLMRU = $00000004;

  // Include the URLs in the users History and Recently Used lists. Equivalent to
  // SHACF_URLHISTORY | SHACF_URLMRU.
  SHACF_URLALL = SHACF_URLHISTORY or SHACF_URLMRU;

  // Allow the user to select from the autosuggest list by pressing the TAB key.
  // If this flag is not set, pressing the TAB key will shift focus to the next
  // control and close the autosuggest list.
  // If SHACF_USETAB is set, pressing the TAB key will select the first item
  // in the list. Pressing TAB again will select the next item in the list,
  // and so on. When the user reaches the end of the list, the next TAB key
  // press will cycle the focus back to the edit control.
  // This flag must be used in combination with one or more of the
  // SHACF_FILESYS* or SHACF_URL*
  // flags
  SHACF_USETAB = $00000008;

  SHACF_VIRTUAL_NAMESPACE = $00000040;    
    !end OMIT('!-- dephi example AC ----')
    
!========================================================================== 