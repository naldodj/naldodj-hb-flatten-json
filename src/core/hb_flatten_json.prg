/*
  __  _         _    _                   _
 / _|| |  __ _ | |_ | |_   ___  _ __    (_) ___   ___   _ __
| |_ | | / _` || __|| __| / _ \| '_ \   | |/ __| / _ \ | '_ \
|  _|| || (_| || |_ | |_ |  __/| | | |  | |\__ \| (_) || | | |
|_|  |_| \__,_| \__| \__| \___||_| |_| _/ ||___/ \___/ |_| |_|
                                      |__/

    Released to Public Domain.
    --------------------------------------------------------------------------------------
*/

#include "hbclass.ch"

class FlattenJSON

#ifndef __ALT_D__
    HIDDEN:
#endif
    data hFlatten as hash init {=>}

    EXPORTED:
    method Flatten(hJSON as hash,cPrefix as character) as hash
    method UnFlatten(hFlatten as hash) as hash

endclass

method Flatten(hJSON as hash,cPrefix as character) class FlattenJSON

    local cKey as character
    local cType as character
    local cNewKey as character
    local cIndexKey as character

    local lHasPrefix as logical:=(!Empty(cPrefix))

    local nIndex as numeric

    local uValue as anytype

    for each cKey in hb_HKeys(hJSON)

        uValue:=hJSON[cKey]

        // Nova chave concatenada
        if (lHasPrefix)
            cNewKey:=(cPrefix+"."+cKey)
        else
            cNewKey:=cKey
        endif

        // Se for um hash,chamada recursiva
        cType:=ValType(uValue)
        if (cType=="H")
            self:hFlatten[cNewKey]:="__$O:"+hb_NTOC(Len(uValue))
            hb_HMerge(self:hFlatten,FlattenJSON():Flatten(uValue,cNewKey))
        // Se for um array,processa cada item com índice
        elseif (cType=="A")
            self:hFlatten[cNewKey]:="__$A:"+hb_NTOC(Len(uValue))
            for nIndex:=1 to Len(uValue)
                cIndexKey:=cNewKey+"["+hb_NToC(nIndex-1)+"]"
                if (valType(uValue[nIndex])=="H")
                    self:hFlatten[cIndexKey]:="__$O:"+hb_NTOC(Len(uValue[nIndex]))
                    hb_HMerge(self:hFlatten,FlattenJSON():Flatten(uValue[nIndex],cIndexKey))
                else
                     self:hFlatten[cIndexKey]:=uValue[nIndex]
                endif
            next nIndex
        else
            self:hFlatten[cNewKey]:=uValue
        endif

    next each //cKey

    return(self:hFlatten) as hash

method UnFlatten(hFlatten as hash) class FlattenJSON

    local aPath as array

    local cKey as character
    local cMarker as character
    local cComponent as character
    local cPartialKey as character
    local cElementKey as character
    local cNextComponent as character
    local cLastComponent as character

    local hUnFlattened as hash:={=>}

    local n as numeric
    local nSize as numeric
    local nIndex as numeric

    local uValue as anytype
    local uMarker as anytype
    local uCurrent as anytype

    begin sequence

        // Itera sobre todas as chaves do hash achatado
        for each cKey in hb_HKeys(hFlatten)
            uValue:=hFlatten[cKey]
            // Verifica se o valor é um marcador; se for,pula se não for vazio.
            if (ValType(uValue)=="C")
                cMarker:=Left(uValue,5)
                if ((cMarker=="__$O:").or.(cMarker=="__$A:").and.(IsDigit(SubStr(uValue,6))))
                    if (SubStr(uValue,6)!="0")
                        loop
                    else
                        uValue:=if((cMarker=="__$O:"),{=>},{})
                    endif
                endif
            endif
            // Processa chaves com valores folha (não marcadores)
            aPath:=SplitKey(cKey) // Divide a chave em componentes
            uCurrent:=hUnFlattened
            // Navega ou cria a estrutura para todos os componentes exceto o último
            for n:=1 to Len(aPath)-1
                cComponent:=aPath[n]
                if (Left(cComponent,1)=="[") // Componente é um índice de array
                    nIndex:=Val(hb_StrReplace(cComponent,{"["=>"","]"=>""}))+1
                    // Verifica se o próximo componente existe e seu tipo
                    if (n < Len(aPath))
                        cNextComponent:=aPath[n+1]
                        if (Left(cNextComponent,1)=="[") // Próximo é array
                            // Garantir que uCurrent seja um array
                            if (ValType(uCurrent)!="A")
                                // Erro: esperado array
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                            // Garantir que o elemento no índice seja um array
                            if (nIndex>Len(uCurrent))
                                // Erro: índice fora dos limites
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                            if (uCurrent[nIndex]==NIL)
                                cElementKey:=BuildPartialKey(aPath,1,n)+cNextComponent
                                uMarker:=hFlatten[cElementKey]
                                if (ValType(uMarker)=="C").and.(Left(uMarker,5)=="__$A:")
                                    nSize:=Val(SubStr(uMarker,6))
                                    uCurrent[nIndex]:=Array(nSize)
                                else
                                    // Erro: marcador esperado não encontrado
                                    hUnFlattened:={=>}
                                    //Abandona
                                    break
                                endif
                            elseif (ValType(uCurrent[nIndex])!="A")
                                // Erro: esperado array
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                        else // Próximo é chave de objeto
                            // Garantir que uCurrent seja um array
                            if (ValType(uCurrent)!="A")
                                // Erro: esperado array
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                            // Garantir que o elemento no índice seja um hash
                            if (nIndex>Len(uCurrent))
                                // Erro: índice fora dos limites
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                            if (uCurrent[nIndex]==NIL)
                                cElementKey:=BuildPartialKey(aPath,1,n)
                                uMarker:=hFlatten[cElementKey]
                                if (ValType(uMarker)=="C").and.(Left(uMarker,5)=="__$O:")
                                    uCurrent[nIndex]:={=>}
                                else
                                    // Erro: marcador esperado não encontrado
                                    hUnFlattened:={=>}
                                    //Abandona
                                break
                                endif
                            elseif (ValType(uCurrent[nIndex])!="H")
                                // Erro: esperado hash
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                        endif
                    else
                        // Último componente antes do valor
                        if (ValType(uCurrent)!="A")
                            // Erro: esperado array
                            hUnFlattened:={=>}
                            //Abandona
                            break
                        endif
                        if (nIndex>Len(uCurrent))
                            // Erro: índice fora dos limites
                            hUnFlattened:={=>}
                            //Abandona
                            break
                        endif
                    endif
                    uCurrent:=uCurrent[nIndex]
                else  // Componente é uma chave de hash
                    if (!hb_HHasKey(uCurrent,cComponent))
                        cPartialKey:=BuildPartialKey(aPath,1,n)
                        uMarker:=hFlatten[cPartialKey]
                        if (ValType(uMarker)=="C")
                            if (Left(uMarker,5)=="__$O:")
                                uCurrent[cComponent]:={=>}
                            elseif (Left(uMarker,5)=="__$A:")
                                nSize:=Val(SubStr(uMarker,6))
                                uCurrent[cComponent]:=Array(nSize)
                            else
                                // Erro: marcador inválido
                                hUnFlattened:={=>}
                                //Abandona
                                break
                            endif
                        else
                            // Erro: marcador esperado não encontrado
                            hUnFlattened:={=>}
                            //Abandona
                            break
                        endif
                    endif
                    uCurrent:=uCurrent[cComponent]
                endif
            next n
            // Define o valor folha
            cLastComponent:=aPath[Len(aPath)]
            if (Left(cLastComponent,1)=="[") // Último componente é índice de array
                nIndex:=Val(hb_StrReplace(cLastComponent,{"["=>"","]"=>""}))+1
                if (ValType(uCurrent)!="A").or.(nIndex>Len(uCurrent))
                    // Erro: array esperado ou índice fora dos limites
                    hUnFlattened:={=>}
                    //Abandona
                    break
                endif
                uCurrent[nIndex]:=uValue
            else  // Último componente é chave de hash
                if (ValType(uCurrent)!="H")
                    // Erro: esperado hash
                    hUnFlattened:={=>}
                    //Abandona
                    break
                endif
                uCurrent[cLastComponent]:=uValue
            endif
        next each //cKey

    end sequence

    return(hUnFlattened) as hash

// Função auxiliar para dividir a chave em componentes
static function SplitKey(cKey as character)

    local aPath as array:={}
    local cChar as character
    local cBuffer as character:=""

    local lInBracket as logical:=.F.
    local lInPattern as logical:=.F.

    local nPos as numeric:=1
    local nLen as numeric:=Len(cKey)
    local nPathLen as numeric

    while (nPos<=nLen)
        cChar:=SubStr(cKey,nPos,1)
        if (lInPattern)
            // Se estamos após "patternProperties",acumula até o próximo ponto
            if (cChar==".")
                aAdd(aPath,cBuffer)
                cBuffer:=""
                lInPattern:=.F.
            else
                cBuffer+=cChar
            endif
        elseif ((cChar=="[").and.(!lInBracket))
            // Início de um índice de array
            if (!Empty(cBuffer))
                aAdd(aPath,cBuffer)
                cBuffer:=""
            endif
            lInBracket:=.T.
            cBuffer+=cChar
        elseif ((cChar=="]").and.(lInBracket))
            // Fim de um índice de array
            cBuffer+=cChar
            aAdd(aPath,cBuffer)
            cBuffer:=""
            lInBracket:=.F.
        elseif ((cChar==".").and.(!lInBracket))
            // Separador de componentes
            if (!Empty(cBuffer))
                aAdd(aPath,cBuffer)
                cBuffer:=""
            endif
            // Verifica se o último componente é "patternProperties"
            nPathLen:=Len(aPath)
            if ((nPathLen>0).and.(aPath[nPathLen]=="patternProperties"))
                lInPattern:=.T.
            endif
        else
            cBuffer+=cChar
        endif
        nPos++
    end while

    // Adiciona o último componente,se houver
    if (!Empty(cBuffer))
        aAdd(aPath,cBuffer)
    endif

    return(aPath) as array

// Função auxiliar para construir chave parcial
static function BuildPartialKey(aPath as array,nStart as numeric,nEnd as numeric)
    local cKey as character:=""
    local n as numeric
    if (nEnd<nStart)
        return("")
    endif
    cKey:=aPath[nStart]
    for n:=nStart+1 to nEnd
        if (Left(aPath[n],1)=="[")
            cKey+=aPath[n]
        else
            cKey+="."+aPath[n]
        endif
    next n
    return(cKey) as character
