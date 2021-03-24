! CBAutoCompClass by Carl Barnes. (c) 2019 by Carl Barnes for CIDC 2019 - Released under MIT LICENSE

    MEMBER()
    MAP
DynamicLoader  FUNCTION(STRING DllName, *UNSIGNED InOutDllHandle, STRING ProcName, *Long OutProcPointer, *long OutOSError, Byte Verbose=0),SIGNED,PROC 
       MODULE('win32')
         !MSDN: "WARNING: Caller needs to have called CoInitialize() or OleInitialize()". WOMM w/o call, probably RTL calls.  
         !Renamed "ShoAuto_Xxx" to not conflict with any other includes
         CoInitialize(long = 0),PASCAL,DLL(1),LONG
         CoUnInitialize(),PASCAL,DLL(1)            !CoInit calls should be matched with CoUnInit
        
         GetLastError(),LONG,PASCAL,Dll(1)
         OutputDebugString(*CString), raw, pascal, name('OutputDebugStringA'),Dll(1)

         LoadLibrary(*CSTRING pszModuleFileName),UNSIGNED,PASCAL,RAW,NAME('LoadLibraryA'),DLL(1)
         ! FreeLibrary(UNSIGNED hModule), LONG, PASCAL, PROC,DLL(1)
         ! GetModuleHandle(*CSTRING pszModuleName), UNSIGNED, PASCAL, RAW, NAME('GetModuleHandleA'),DLL(1)
         GetProcAddress(UNSIGNED hModule, *CSTRING pszProcName),LONG,PASCAL,RAW,DLL(1)          
         GetFileAttributes(*CSTRING FileName),LONG,PASCAL,DLL(1),RAW,NAME('GetFileAttributesA')
       END
    END ! map

ShLwAPI_DLL_Name     EQUATE('ShLwAPI.dll')  !Shell Light Weight API DLL
ShLwAPI_DLL_Handle   LONG                   !LoadLibrary handle to this DLL
SHAutoComplete_Name  EQUATE('SHAutoComplete')
SHAutoComplete_FP    LONG,NAME('SHAutoComplete')

    MAP
        MODULE('ShLwAPI.dll')    !Dynamically Loaded. IMO it is no problem to link to ShLwAPI. The Tracker PDF DLLs do.
         !https://docs.microsoft.com/en-us/windows/desktop/api/shlwapi/nf-shlwapi-shautocomplete
         !SHAutoComplete(SIGNED hwndEdit, LONG dwFlags ),PASCAL,DLL(1),LONG,PROC  !Returns HResult < 0 if failed
         SHAutoComplete(SIGNED hwndEdit, LONG dwFlags ),PASCAL,DLL(_fp_),LONG,PROC
        END
    END
    Include('CBAutoCompAPI.inc'),ONCE

!-------------------------------------------------------------------------------------------------- 
CBAutoCompClass.CONSTRUCT     PROCEDURE()
    CODE
    IF ShLwAPI_DLL_Handle=0 AND SHAutoComplete_FP=0 THEN 
       SELF.ConstructFailed = DynamicLoader(ShLwAPI_DLL_Name,    ShLwAPI_DLL_Handle, |
                                            SHAutoComplete_Name, SHAutoComplete_FP,  |
                                            SELF.LoadError, 0)  !0/1=Verbose

    ELSE
    END
    IF CoInitialize() >= 0 THEN SELF.CoInitCount += 1.      !Needs to be done if ShAuto called before Event:OpenWindow. Done once per thread
    SELF.ACFlgSuggest = CBAC_SHACF_AUTOSUGGEST_FORCE_ON     !Force ON AutoSuggest incase User turned off in IE
    RETURN
!----------------------------------------
CBAutoCompClass.DESTRUCT     PROCEDURE()
    CODE
    LOOP SELF.CoInitCount TIMES ; CoUnInitialize() ; END
    SELF.CoInitCount = 0
    RETURN
!--------------------------------------------------------------------------------------------------
CBAutoCompClass.Init    PROCEDURE  (BYTE pShowDebug=0)
  CODE
  IF pShowDebug
    Message(' |ConstructFailed=' & SELF.ConstructFailed & ' |LoadError=' & SELF.LoadError & |
                '|' & ShLwAPI_DLL_Name &' Handle=' & ShLwAPI_DLL_Handle & |
                '|' & SHAutoComplete_Name &' FP=' & SHAutoComplete_FP, 'CBAutoCompClass Init')
  END
  RETURN
!--------------------------------------------------------------------------------------------------
CBAutoCompClass.FunWithFlags  PROCEDURE(LONG pFEQ, LONG pFlags)
HR  LONG,AUTO
  CODE                                              !,LONG,PROC  !Returns HResult
  IF SELF.ConstructFailed THEN RETURN -1.
  HR = SHAutoComplete(pFEQ{PROP:Handle}, pFlags ) 
  RETURN HR
!--------------------------------------------------------------------------------------------------
!--------------------------------------------------------------------------------------------------
CBAutoCompClass.AC_Default       PROCEDURE(LONG pFEQ)!,LONG,PROC  !FILESYSTEM and URLALL
    CODE  !SHACF_DEFAULT cannot be combined with any other flags.
    SELF.ACLastFlags = CBAC_SHACF_DEFAULT
    RETURN SELF.FunWithFlags(pFEQ, CBAC_SHACF_DEFAULT)    
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.AC_Filesys_Only  PROCEDURE(LONG pFEQ, BYTE pVirtNS)!,LONG,PROC  !File system only. Files and Dirs.
    CODE
    RETURN SELF.Worker4AC(pFEQ, CBAC_SHACF_FILESYS_ONLY, pVirtNS)
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.AC_Filesys_Dirs  PROCEDURE(LONG pFEQ, BYTE pVirtNS)!,LONG,PROC  !Only directories, UNC servers, and UNC server shares. No files.
    CODE
    RETURN SELF.Worker4AC(pFEQ, CBAC_SHACF_FILESYS_DIRS, pVirtNS)
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.AC_FileSystem    PROCEDURE(LONG pFEQ, BYTE pVirtNS)!,LONG,PROC  !File system and the rest of the Shell (Desktop, Computer, and Control Panel
    CODE
    RETURN SELF.Worker4AC(pFEQ, CBAC_SHACF_FILESYSTEM, pVirtNS)
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.AC_UrlHistory    PROCEDURE(LONG pFEQ )!,LONG,PROC  !URLs in the user's History list.
    CODE
    RETURN SELF.Worker4AC(pFEQ, CBAC_SHACF_URLHISTORY)
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.AC_UrlMRU        PROCEDURE(LONG pFEQ )!,LONG,PROC   !URLs in the user's Recently Used list.
    CODE
    RETURN SELF.Worker4AC(pFEQ, CBAC_SHACF_URLMRU)
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.AC_UrlALL        PROCEDURE(LONG pFEQ )!,LONG,PROC   !URLs in the user's History and MRU
    CODE
    RETURN SELF.Worker4AC(pFEQ, BOR(CBAC_SHACF_URLHISTORY, CBAC_SHACF_URLMRU) ) 
!--------------------------------------------------------------------------------------------------  
CBAutoCompClass.Worker4AC        PROCEDURE(LONG pFEQ, LONG pFlags, BYTE pVirtNS=0)!,LONG,PROTECTED     !For AC_xxx call ShAuto
  CODE
  IF pVirtNS THEN pFlags = BOR(pFlags, CBAC_SHACF_VIRTUAL_NAMESPACE).
  pFlags = BOR(pFlags, BOR(SELF.ACFlgAppend,SELF.ACFlgSuggest))
  pFlags = BOR(pFlags, SELF.ACFlgUseTab)
  SELF.ACLastFlags = pFlags
  IF SELF.ConstructFailed THEN RETURN -1.
  RETURN SHAutoComplete(pFEQ{PROP:Handle}, pFlags ) 
!--------------------------------------------------------------------------------------------------
CBAutoCompClass.ACFlag_AutoAppend    PROCEDURE(BYTE OnOff12) 
    CODE !AutoAppend is a visual feature of showing the current pick appended in the ENTRY  1=On 2=Off Else Null
    SELF.ACFlgAppend  = CHOOSE(OnOff12, CBAC_SHACF_AUTOAPPEND_FORCE_ON, CBAC_SHACF_AUTOAPPEND_FORCE_OFF, 0)
CBAutoCompClass.ACFlag_AutoSuggest   PROCEDURE(BYTE OnOff12)
    CODE !Turning this OFF means it does NOT work. This should only be used with ON.
    SELF.ACFlgSuggest = CHOOSE(OnOff12, CBAC_SHACF_AUTOSUGGEST_FORCE_ON, CBAC_SHACF_AUTOSUGGEST_FORCE_OFF, 0)    
CBAutoCompClass.ACFlag_UseTab        PROCEDURE(BYTE OnOff12) 
    CODE
    SELF.ACFlgUseTab  = CHOOSE(OnOff12, CBAC_SHACF_USETAB, 0)
CBAutoCompClass.ACFlags PROCEDURE(<BYTE Append>, <BYTE Suggest>, <BYTE UseTab>)  
    CODE  !Set all 3 flags 1=ForceOn 2=ForceOff 3=Omit Set
    IF ~OMITTED(Append)  THEN SELF.ACFlag_AutoAppend(Append).
    IF ~OMITTED(Suggest) THEN SELF.ACFlag_AutoSuggest(Suggest).
    IF ~OMITTED(UseTab)  THEN SELF.ACFlag_UseTab(UseTab).
!--------------------------------------------------------------------------------------------------
CBAutoCompClass.IsDirectory PROCEDURE(STRING pDirName)  !,BOOL True if Directory and Not file
FA LONG
eFILE_ATTRIBUTE_DIRECTORY EQUATE(10h) !The handle that identifies a directory.
    CODE
    RETURN CHOOSE(SELF.GetAttributes(pDirName,FA) AND BAND(FA,eFILE_ATTRIBUTE_DIRECTORY) )

CBAutoCompClass.IsFile PROCEDURE(STRING pFileName)  !,BOOL True if File and Not Directory
FA LONG
eFILE_ATTRIBUTE_DIRECTORY EQUATE(10h)
    CODE
    RETURN CHOOSE(SELF.GetAttributes(pFileName,FA) AND ~BAND(FA,eFILE_ATTRIBUTE_DIRECTORY) )
  
CBAutoCompClass.GetAttributes PROCEDURE(STRING pFileOrDir, *LONG OutFA)!,BOOL !False if file doesnot exist  
cFN CSTRING(261),AUTO
eINVALID_FILE_ATTRIBUTES EQUATE(0FFFFFFFFh) !(-1) File or folder does not exist
  CODE
  cFN = CLIP(pFileOrDir)
  OutFA = GetFileAttributes(cFN)
  RETURN CHOOSE(OutFA <> eINVALID_FILE_ATTRIBUTES)
!--------------------------------------------------------------------------------------------------
DynamicLoader   FUNCTION(STRING DllName, *UNSIGNED DllHandle, STRING ProcName, *Long ProcPointer, *long OutOSError, Byte Verbose=0)!,SIGNED,PROC
Cname                       CSTRING(260),AUTO
lpProcedure                 LONG
RetReason                   LONG(0)
    CODE
    outOSError=0
    IF ~DllHandle THEN                 !Step 1 - Load DLL (if not already loaded)
       Cname = CLIP(DllName)
       DllHandle = LoadLibrary(Cname)
       IF ~DllHandle THEN
          outOSError = GetLastError()
          IF Verbose THEN Message('Failed LoadLibary "' & Cname & '"|Error: ' & outOSError & '|Path: ' &LONGPATH()& '|Path: ' &COMMAND('0'),'DynamicLoader').
          RetReason = 1
       END
    END
    IF DllHandle AND ProcName THEN     !Step 2 - Find Procedure. Pass blank Procedure name to just load the DLL
       Cname = CLIP(ProcName)
       lpProcedure = GetProcAddress(DllHandle, Cname)
       IF lpProcedure >=0 AND lpProcedure <= 0FFFFh THEN ! OR IsBadCodePtr(lpProcedure)
          outOSError = GetLastError()
          IF Verbose THEN Message('Failed GetProcAddr "' & Cname &'"|in '& DllName &'|Error: ' & outOSError,'DynamicLoader').
          RetReason = CHOOSE(~lpProcedure,2,3)
       ELSE
          ProcPointer = lpProcedure
       END
    END
    RETURN RetReason  !0=Worked, 1=DLL Load Failed, 2=Proc Not Found, 3=Proc Pointer Bad
