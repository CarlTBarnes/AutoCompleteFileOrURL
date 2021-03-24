!Example by Carl Barnes for CIDC 2019. 
!SHAutoComplete works for Clarion ENTRY, COMBO and TEXT,SINGLE to provide a handy popup list of Files, Dirs, URLs
!Call SHAutoComplete(?Feq{PROP:Handle},Flags)
!Carl's class
  PROGRAM
  Include('CBAutoCompAPI.inc'),ONCE
  MAP
SHAutoCompleteTest  PROCEDURE()    
  END

  CODE
  SHAutoCompleteTest() 
  return
  
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
Window WINDOW('SHAutoCompleteTest - CBAutoCompAPI Class - Auto Complete Works with Clarion ENTRY, TEXT, COMBO !!!'),AT(,,473,249),GRAY,SYSTEM, |
            ICON(ICON:Thumbnail),FONT('Segoe UI',9),DOUBLE
        STRING('xxx'),AT(6,2),HIDE
        STRING('TEXT,SINGLE Controls'),AT(49,2)
        STRING('Class sets AutoSuggest ON (except Default) in case user turns off'),AT(167,2),USE(?STRING6)
        BUTTON('New Thread'),AT(420,2,49),USE(?NewThreadBtn),SKIP
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
        PROMPT('Path Name:'),AT(6,208),USE(?PROMPT1:73)
        TEXT,AT(50,208,161,10),USE(FlagTest3),SINGLE
        PROMPT('Text 2 line:'),AT(6,222),USE(?PROMPT1:Text2)
        TEXT,AT(50,222,161,20),USE(Text2Line)
    END
 
HR          LONG   
SHAutoCls   CLASS
Init                PROCEDURE()
ShAutoComp1         PROCEDURE(LONG pFEQ,  LONG pFlags, STRING pFlagsString) 
CreString           PROCEDURE(LONG pFEQ, STRING pFlagsString)
CreString2          PROCEDURE(LONG pFEQ, STRING pFlagsString)
            END
CBAuC       CBAutoCompClass
    CODE
    OPEN(Window)
    IF THREAD()>1 THEN 0{PROP:Text}='Thread ' & THREAD()  &' - '& 0{PROP:Text}.
    !CBAuC.Init(1) !Shows some debug
    SHAutoCls.Init()   !Works here also but must have done CoInit() which is done in Constructor of CBAuC.  
    ACCEPT
        CASE EVENT()
        OF EVENT:OpenWindow     ;  !SHAutoCls.Init()   !Works here also
        END 
        CASE ACCEPTED()
        OF ?NewThreadBtn        ; START(SHAutoCompleteTest)
        OF ?FileName        ; IF CBAuC.IsDirectory(FileName) THEN Message('That''s a Folder','IsDirectory').
        END 
    END
    RETURN                 

SHAutoCls.Init   PROCEDURE()
    CODE
    CBAuC.AC_Filesys_Dirs(?PathName) ; SHAutoCls.CreString2(?PathName,'AC_Filesys_Dirs - Dirs Only')
    CBAuC.AC_FileSys_Only(?FileName) ; SHAutoCls.CreString2(?FileName,'AC_FileSys_Only - Files and Dirs.')
    CBAuC.AC_FileSystem(?FileSystm)  ; SHAutoCls.CreString2(?FileSystm,'AC_FileSystem')
    CBAuC.AC_Default(?AnyAuto)       ; SHAutoCls.CreString2(?AnyAuto,'AC_Default')
    CBAuC.AC_UrlHistory(?UrlHist)    ; SHAutoCls.CreString2(?UrlHist,'AC_UrlHistory')
    CBAuC.AC_UrlMRU(?UrlMRU)         ; SHAutoCls.CreString2(?UrlMRU,'AC_UrlMRU')
    
    CBAuC.AC_FileSystem(?VirtNS,1)   ; SHAutoCls.CreString2(?VirtNS,'AC_FileSystem(,VirtNS)')
    CBAuC.AC_Filesys_Dirs(?ComboAuto)   ; SHAutoCls.CreString2(?ComboAuto,'AC_Filesys_Dirs')
    CBAuC.AC_Filesys_Dirs(?EntryAuto)   ; SHAutoCls.CreString2(?EntryAuto,'AC_Filesys_Dirs')
    CBAuC.ACFlag_AutoAppend(1)
    CBAuC.AC_Filesys_Dirs(?EntryAuto2)  ; SHAutoCls.CreString2(?EntryAuto2,'AC_Filesys_Dirs w/AutoApnd') 
    CBAuC.ACFlag_AutoAppend(0)

    CBAuC.ACFlag_UseTab(1)
    CBAuC.AC_Filesys_Dirs(?FlagTest2)  ; SHAutoCls.CreString2(?FlagTest2,'AC_Filesys_Dirs w/UseTab (no diff)') 
    CBAuC.ACFlags(1,,0)    !Function sets all 3 (Append,Suggest,UseTab)
    CBAuC.AC_Filesys_Dirs(?FlagTest3)  ; SHAutoCls.CreString2(?FlagTest3,'AC_Filesys_Dirs AppendON')
    CBAuC.ACFlags(0)

    CBAuC.AC_UrlMRU(?Text2Line)         ; SHAutoCls.CreString2(?Text2Line,'AC_UrlMRU  (Cannot Tab out of Multiline Text, press Enter)')
    CBAuc.ACFlag_AutoSuggest(2)  !SHACF_AUTOSUGGEST_FORCE_OFF  why would you do this, unless the user wanted it that way
    CBAuC.AC_UrlMRU(?NotAuto)         ; SHAutoCls.CreString2(?NotAuto,'AC_UrlMRU  Suggest Force OFF so no AutoComp')
    CBAuc.ACFlag_AutoSuggest(1)  !SHACF_AUTOSUGGEST_FORCE_ON

    RETURN

SHAutoCls.ShAutoComp1   PROCEDURE(LONG pFEQ,  LONG pFlags, STRING pFlagsString)   !, LONG pFEQString
    CODE
     HR=CBAuC.FunWithFlags(pFEQ, pFlags ) 
     IF HR < 0 THEN  
        MESSAGE('FEQ ' & pFEQ & '|Flag ' & pFlags & |
                '||SHAutoComplete  HResult=' & HR)
     END
     SELF.CreString(pFEQ, 'Flags ' & CLIP(pFlagsString) & ' = ' & pFlags )
     RETURN
SHAutoCls.CreString   PROCEDURE(LONG pFEQ, STRING pFlagsString)
X    LONG,AUTO
Y    LONG,AUTO
W    LONG,AUTO
H    LONG,AUTO
SEQ  LONG,AUTO
   CODE
    GETPOSITION(pFEQ,X,Y,W,H)
    SEQ=CREATE(0,CREATE:String) 
    SETPOSITION(SEQ,X+W+10,Y)
    SEQ{PROP:Text}=pFlagsString
    UNHIDE(SEQ)
    RETURN
SHAutoCls.CreString2   PROCEDURE(LONG pFEQ, STRING pFlagsString)
    CODE
    SELF.CreString(pFEQ, pFlagsString &' [' & CBAuC.ACLastFlags & ']' )
    RETURN

    OMIT('!-- dephi example AC ----') 
https://blog.dummzeuch.de/2014/06/09/autocomplete-for-tedits/

Autosuggest means that the control displays a list of matching items and the user can select one of these using 
either the mouse or the up/down arrow keys. OFF mens it does NOT work.

Autoappend means that the control automatically appends the first matching item to the user input and selects it, 
so that it gets overwritten if the user continues typing. The user can use TAB to switch focus to the next control 
in which case he will accept the suggestion.
    
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