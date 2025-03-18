/*
  __  _         _    _                   _                     _         _
 / _|| |  __ _ | |_ | |_   ___  _ __    (_) ___   ___   _ __  | |_  ___ | |_
| |_ | | / _` || __|| __| / _ \| '_ \   | |/ __| / _ \ | '_ \ | __|/ __|| __|
|  _|| || (_| || |_ | |_ |  __/| | | |  | |\__ \| (_) || | | || |_ \__ \| |_
|_|  |_| \__,_| \__| \__| \___||_| |_| _/ ||___/ \___/ |_| |_| \__||___/ \__|
                                      |__/

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/

#require "hbct"

#include "directry.ch"

// Exemplo de uso
REQUEST HB_CODEPAGE_UTF8EX

procedure Main()

    CLS

    hb_cdpSelect("UTF8")
    hb_cdpSelect("UTF8EX")

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    Execute()

return

static procedure Execute()

    local aJSON as array

    local cKey as character
    local cJSON as character
    local cFile as character
    local cKeyAT as character
    local cJSONPath as character
    local cFileName as character
    local cJSONFlattened as character
    local cFileFlattened as character
    local cJSONFlattenedPath as character

    local hJSON as hash:={ => }
    local hFlattened as hash
    local hUnFlattened as hash

    #ifdef __ALT_D__    // Compile with -b -D__ALT_D__
        AltD(1)         // Enables the debugger. Press F5 to continue.
        AltD()          // Invokes the debugger
    #endif

    cJSONFlattenedPath:=hb_PathRelativize(".",hb_DirSepAdd("jsonflattened"),.T.)
    hb_DirCreate(cJSONFlattenedPath)
    cJSONPath:=hb_PathRelativize(".",hb_DirSepAdd("json"),.T.)
    for each aJSON IN Directory(cJSONPath+"*.json")
        cFile:=cJSONPath+aJSON[F_NAME]
        cJSON:=hb_MemoRead(cFile)
        hb_JSONDecode(cJSON,@hJSON)
        hFlattened:=FlattenJSON():Flatten(hJSON)
        cJSONFlattened:=hb_JSONEncode(hFlattened,.T.)
        cFileName:=hb_FNameName(cFile)
        cFileFlattened:=hb_StrReplace(cFile,{cJSONPath=>cJSONFlattenedPath,cFileName=>cFileName+"_flattened"})
        hb_MemoWrit(cFileFlattened,cJSONFlattened)
        // Exibir resultado
        for each cKey in hb_HKeys(hFlattened)
            TokenInit(@cKey,".")
            cKeyAT:=SubStr(cKey,TokenAT(.F.,TokenNum()))
            ? SubStr(cKey,1,Len(cKey)-Len(cKeyAT))+cKeyAT+" : "+hb_JSONEncode(hFlattened[cKey])
        next each
        ? "",Replicate("=",80),""
        hUnFlattened:=FlattenJSON():UnFlatten(hFlattened)
        ? hb_JSONEncode(hUnFlattened)
        ? "",Replicate("=",80),""
        if (hb_JSONEncode(hJSON)==hb_JSONEncode(hUnFlattened))
            SetColor("g+/n")
            QOut("Result: OK! File: "+cFile)
            SetColor("")
        else
            SetColor("r+/n")
            QOut("Result: Not OK. Errors found! File: "+cFile)
            SetColor("")
        endif
        ? "",Replicate("=",80),""

    next each //aJSON

    return
