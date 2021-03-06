;/*
; ���� ���ᠭ�� �⥪����� �ࠣ���� � TSS
TSS_stack macro ss0,esp0,ss1,esp1,ss2,esp2
        dd      0h              ; ���� ����� �� �맮�� CALL
                                ; �� ���樠����樨 �ᥣ�� 0
        dd      offset (esp0)
        dd      (ss0)
        dd      offset (esp1)
        dd      (ss1)
        dd      offset (esp2)
        dd      (ss2)
endm

;
; ���� ���ᠭ�� �ࠣ���� cr3 � TSS
TSS_cr3   macro tcr3
        dd      (tcr3)
endm

;
; ���� ���ᠭ�� �ࠣ���� ॣ���஢ ��饣� �����祭�� � TSS
TSS_regs  macro teip,tflg,teax,tebx,tecx,tedx,tesi,tedi,tebp,tesp
        dd      offset (teip)
        dd      tflg
        dd      teax
        dd      tecx
        dd      tedx
        dd      tebx
        dd      offset (tesp)
        dd      tebp
        dd      tesi
        dd      tedi
endm

;
; ���� ���ᠭ�� �ࠣ���� ᥣ������ ॣ���஢ � TSS
TSS_seg   macro tes,tcs,tss,tds,tfs,tgs
        dd      (tes)
        dd      (tcs)
        dd      (tss)
        dd      (tds)
        dd      (tfs)
        dd      (tgs)
endm

;
; ���� ���ᠭ�� �맮�� ����ணࠬ�� �१ ���⨫� �맮��
; ��।�� �������� ⮫쪮 � ������ ᥣ���� ⮣� �� �஢�� �ਢ������
; ��� ����� �ਢ�����஢���� (���⮩ ��� ᮣ��ᮢ����)
callf   macro selector
        db      09ah            ; far call code
        dw      0h              ; ᬥ饭�� �ᥣ�� 0
        dw      (selector)      ; ᥫ���� ���⨫� �맮�� � GDT/LDT
endm

;
; ���� ���ᠭ�� ���室� �� ����ணࠬ�� �१ ���⨫� �맮��
; ��।�� �������� ⮫쪮 � ������ ᥣ���� ⮣� �� �஢�� �ਢ������
; ��� � ᮣ��ᮢ���� ᥣ����
jmpf   macro selector
        db      0eah            ; far jmp code
        dw      0h              ; ᬥ饭�� �ᥣ�� 0
        dw      (selector)      ; ᥫ���� ���⨫� �맮�� � GDT/LDT
endm

;
; ���� ���᫥��� �������� ���ᮢ � �।���� ⠡���� GDT
; �믮������ � ॠ�쭮� ०��� ������
; ��ࠬ���� : gdt      - ᥣ����� ���� ᥣ���� ⠡���� GDT
;             pgdt     - ���� FWORD ����⥫� ᥣ���� GDT
;             gdtlimit - �।�� ⠡���� GDT
build_gdtr      macro gdt,pgdt,gdtlimit
        mov     ax,(gdtlimit)           ; �।�� ᥣ���� GDT
        mov     word ptr [(pgdt)],ax    ; ��������� � ����⥫� GDT.limit
        xor     eax,eax
        mov     ax,(gdt)                ; ᥣ����� ���� ⠡���� GDT
        shl     eax,4                   ; ����稬 32-ࠧ�來� ���. ����
        mov     dword ptr [(pgdt)+2],eax; �������� � ����⥫� GDT.base
endm
;
; ���� ���᫥��� �������� ���ᮢ � �।���� ⠡���� IDT
; �믮������ � ॠ�쭮� ०��� ������
; ��ࠬ���� : idt      - ᥣ����� ���� ᥣ���� ⠡���� IDT
;             pidt     - DS:���� FWORD ����⥫� ᥣ���� IDT
;             idtlimit - �।�� ⠡���� IDT
build_idtr      macro idt,pidt,idtlimit
        mov     ax,(idtlimit)           ; �।�� ᥣ���� IDT
        mov     word ptr [(pidt)],ax    ; ��������� � ����⥫� IDT.limit
        xor     eax,eax
        mov     ax,(idt)                ; ᥣ����� ���� ⠡���� IDT
        shl     eax,4                   ; ����稬 32-ࠧ�來� ���. ����
        mov     dword ptr [(pidt)+2],eax; �������� � ����⥫� IDT.base
endm

;
; ���� ���樠����樨 ������� ���ᮢ ᥣ���⮢
; ���ਯ�஢ ⠡���� ᥣ���⮢
; ��ࠬ���� : dtseg     -  ᥣ����� ���� ᥣ���� ⠡���� ���ਯ�஢
;             dttable   -  DS:���� ⠡���� ����⥫�� �८�ࠧ������
;             dtcount   -  �᫮ ����⥫�� � ⠡��� �८�ࠧ������
build_dt        macro dtseg,dttable,dtcount
        local   bdtl
        mov     ax,(dtseg)
        mov     es,ax                   ; ES    = ⠡��� ���ਯ�஢
        mov     si,offset (dttable)     ; DS:SI = ⠡��� ����⥫�� �८��.
        mov     cx,(dtcount)            ; CX    = ���稪 横���
bdtl:
        lodsw
        mov     bx,ax                   ; bx = ᥫ���� ⥪�饣� ᥣ����
        and     bx,0fff8h               ; ���⪠ ��⮢ TI � RPL
        lodsw                           ; ax = ᥣ����� ���� ⥪. ᥣ����
        mov     dl,ah
        shl     ax,4                    ; low 16 ��� 䨧. ���� ᥣ����
        mov     es:[bx+D_base1],ax
        shr     dl,4                    ; high 8 ��� 䨧. ���� ᥣ����
        mov     es:[bx+D_base2],dl
        loop    bdtl
endm

;
; ���� ��ॢ��� ������ � ���饭�� ०�� ࠡ���
goto_prot       macro   gdtptr,idtptr,cseg,stkseg,stkptr,dseg
        local   now_in_prot

        lgdt    [(gdtptr)]              ; ����㧨�� ⠡���� GDT � gdtr
        lidt    [(idtptr)]              ; ����㧨�� ⠡���� IDT � idtr

        cli

        mov     al,A20_PORT             ; ������ ����� A20
        out     STATUS_PORT,al
        mov     al,A20_ON
        out     KBD_PORT_A,al

        mov     [real_es],es            ; ��������� ES ��� ॠ�쭮�� ०���
        mov     [real_ss],ss            ; ��������� 㪠��⥫� �⥪�
        mov     [real_sp],sp

        mov     al,8fh                  ; ����᪨�㥬� ���뢠��� ���������
        out     CMOS_PORT,al            ; ��⮬ 80h �� ����㯥 � CMOS
        jmp     $+2                     ; �������� ����প�
        in      al,CMOS_PORT+1

        in      al,INT_MASK_PORT        ; ࠧ�襭�� ��᪨�㥬�� ���뢠���
        mov     [int_mask],al           ; �������� ���� ���뢠���
        mov     al,0ffh                 ; ����⨬ ���뢠��� ����஫����
        out     INT_MASK_PORT,al        ; ���뢠���

        mov     eax,cr0
        or      al,prot_enable          ; ��४�. ���. � ���饭�� ०.
        mov     cr0,eax                 ; �� � ���饭��� ०���

; �� �室��� ��।� ������ ��室���� �������, �����஢����
; � ॠ�쭮� ०��� ������, �� ���� �����
        jmp     $+2                     ; near jmp ��� ��� ��।� ������

        db      0eah                    ; far jmp ��� ����㧪� ᥫ����
        dw      offset now_in_prot      ; � ����. ᥣ���� ����� ����.
        dw      (cseg)                  ; ०��� �� �㫥��� �஢�� �����
now_in_prot:

        xor     ax,ax
        lldt    ax                      ; NULL ᥫ���� � LDT

        mov     ax,(stkseg)             ; ᥫ���� ᥣ���� SS
        mov     ss,ax
        mov     sp,offset (stkptr)

        mov     ax,(dseg)               ; ᥣ����� ���� ������ prot mode
        mov     ds,ax                   ; ����㧪� ��� ᥣ������ ॣ���஢
        mov     es,ax                   ; ��� ����㧪� ᥫ���஢ �
        mov     fs,ax                   ; ���ਯ�஢ ᥣ���⮢ �ࠢ���묨
        mov     gs,ax                   ; ���祭�ﬨ ��� �����
endm

;
; ���� ��ॢ��� ������ � ॠ��� ०�� ࠡ���
goto_real       macro   dummy_sel,cseg,stkseg,stkptr,dseg
        local   limit_r,now_in_real

        cli

        mov     ax,(dummy_sel)          ; ᥫ���� ������ ॠ�쭮�� ०���
        mov     es,ax                   ; ��� ����㧪� ���ਯ�஢ ᥣ�.
        mov     ds,ax                   ; ॣ���஢ �ࠢ��쭮� ��� DOS
        mov     fs,ax                   ; �࠭�楩 ᥣ���⮢ � ��ਡ�⠬�
        mov     gs,ax                   ; ����㯠
        mov     ss,ax

        db      0eah                    ; far jmp ��� ����㧪� ���ਯ��
        dw      OFFSET  limit_r         ; ᥣ���� ����� �ࠢ��쭮� ��� DOS
        dw      rc_selec                ; �࠭�楩 � ��ਡ�⠬� ����㯠
limit_r:

        mov     eax,cr0
        and     eax,not prot_enable     ; ��४�. ���. � ॠ��� ०��
        mov     cr0,eax                 ; �� � ॠ�쭮� ०���

; �� �室��� ��।� ������ ��室���� �������, �����஢����
; � ���饭��� ०��� ������, �� ���� �����
        jmp     $+2                     ; near jmp ��� ��� ��।� ������

        db      0eah                    ; far jmp ��� ����㧪� ᥫ����
        dw      offset now_in_real      ; � ���ਯ�� ����� �ࠢ����
        dw      (cseg)                  ; � DOS ���ᮬ ���� ᥣ����
now_in_real:

        assume  ds:gdata

        mov     ax,(dseg)               ; ᥣ����� ���� ������ real mode
        mov     ds,ax                   ; ����㧪� ��� ᥣ������ ॣ���஢
        mov     es,ax                   ; ��� ����㧪� ᥫ���஢ �
        mov     fs,ax                   ; ���ਯ�஢ ᥣ���⮢ �ࠢ����
        mov     gs,ax                   ; � DOS ���ᮬ ����

        mov     ax,(stkseg)             ; ᥣ����� ���� �⥪� real mode
        mov     ss,ax                   ; �ࠢ���� ���� ᥣ����
        mov     sp,offset (stkptr)      ; �⥪ ॠ�쭮�� ०���

        lidt    [pold]                  ; ⠡��� ���뢠��� ॠ�쭮�� ०���

        mov     al,A20_PORT             ; ������� ������ 設� A20
        out     STATUS_PORT,al
        mov     al,A20_OF
        out     KBD_PORT_A,al

        mov     ax,00fh                 ; ࠧ�襭�� ����᪨�㥬�� ���뢠���
        out     CMOS_PORT,al
        jmp     $+2                     ; �������� ����প�
        in      al,CMOS_PORT+1

        mov     al,[int_mask]           ; ����⠭���� ���� ���뢠���
        out     INT_MASK_PORT,al        ; ࠧ�訬 ��᪨�㥬� ���뢠���

        sti
endm
