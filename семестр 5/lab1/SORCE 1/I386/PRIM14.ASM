;/*
; �ਬ�� 14
; �ணࠬ�� ���室� ������ � ०�� ����㠫쭮�� v86-��

.386p

include struct.ash
include macros.ash

INTNO           equ     256     ; �᫮ ����஢ � ⠡��� IDT
DSCPSIZE        equ     8       ; ࠧ��� ���ਯ��
INTSIZE         equ     4       ; ࠧ��� ����� ������ ���뢠���

TWO             equ     2
WORDLEN         equ     4       ; �᫮ ᨬ����� � ��ப� �ᥫ
prot_enable     equ     01h     ; ��� ����祭�� ���饭���� ०���
attribute       equ     07h     ; ��ਡ�� ᨬ����� �� ��࠭�
space           equ     20h     ; ��� ᨬ���� �஡���

;
; ��� 1: ������쭠� ⠡��� ���ਯ�஢ ᥣ���⮢ ��⥬�
;
GDT             segment para    public  use16   'GDT'

gdt_tab label   qword   ; ���ਯ�� *!! �ॡ��� ���樠����樨 ����

; NULL ᥫ���� GDT, ������ ���� �ᥣ�� � ���� � ⠡���
null_selec      equ     0
   dscp         <0,0,0,0,0,0>

; ᥫ���� � ᥣ����� GDT ��� � ᥣ����� ������
gdt_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <gdt_limit,0,0,DATA_ACC or DPL_0,0,0>           ;*!!

; ᥣ���� ��⥬��� ����� ����㧪� �ணࠬ��, �ᥣ�� RPL=DPL=0
code_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <code_limit,0,0,CODE_ACC or DPL_0,0,0>          ;*!!

; ᥣ���� TSS ����� ����㧪�, RPL,DPL � ���ண� ����� �������
task0_TSS_selec equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <task0_TSS_limit,0,0,TSS_ACC or DPL_0,0,0>      ;*!!

; ᥣ���� �⥪� ����� �஢�� 0, RPL=DPL=0 �ᥣ��
stk0_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <stk0_limit,0,0,DATA_ACC or DPL_0,0,0>          ;*!!

; ᥣ���� �⥪� ����� �஢�� 1, RPL=DPL=1 �ᥣ��
stk1_selec      equ     $-gdt_tab or TBL_GDT or RPL_1
   dscp         <stk1_limit,0,0,DATA_ACC or DPL_1,0,0>          ;*!!

; ᥣ���� �⥪� ����� �஢�� 2, RPL=DPL=2 �ᥣ��
stk2_selec      equ     $-gdt_tab or TBL_GDT or RPL_2
   dscp         <stk2_limit,0,0,DATA_ACC or DPL_2,0,0>          ;*!!

; ᥣ���� �⥪� ����� �஢�� 3, RPL=DPL=3 �ᥣ��
stk3_selec      equ     $-gdt_tab or TBL_GDT or RPL_3
   dscp         <stk3_limit,0,0,DATA_ACC or DPL_3,0,0>          ;*!!

; ᥣ���� ���������� 梥⭮�� ०���, RPL=0, DPL=3
video_selec     equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <CRT_SIZE-1,CRT_LOW,CRT_SEG,DATA_ACC or DPL_3,0,0>

; ᥣ���� ������ ����� ����㧪�, RPL,DPL ࠧ�襭���� ����㯠
gdata_selec     equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <gdata_limit,0,0,DATA_ACC or DPL_3,0,0>         ;*!!

; ᥣ���� ����� �ணࠬ� ��ࠡ�⪨ ���뢠���, RPL,DPL �६��� �믮������
int_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <code_limit,0,0,CODE_ACC or DPL_0,0,0>          ;*!!

; ᥫ���� � ���ਯ�� ������ � �ଠ� ॠ�쭮� ���� ������
dmy_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <0ffffh,0,0,DATA_ACC or DPL_0,0,0>              ;*!!

; ᥫ���� � ���ਯ�� ����� � �ଠ� ॠ�쭮� ���� ������
rc_selec        equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <0ffffh,0,0,CODE_ACC or DPL_0,0,0>              ;*!!

; ᥣ���� ������ ����㭨��樨 BIOS, RPL,DPL �� �ᬮ�७�� ����
bios_selec      equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <B_DATA_SIZE-1,B_DATA_ADDR,0,DATA_ACC or DPL_0,0,0>

;
; ��� 1.1: ���ਯ�� ᥣ���⮢ ����㠫쭮�� v86
;
; ᥣ���� ������ v86 �� ������ ����஢ �� 1�����
dos_selec       equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <0ffffh,00000h,000h,DATA_ACC or DPL_0,00fh,0>

; ᥣ���� TSS ����� v86, RPL = DPL = 3
task1_TSS_selec equ     $-gdt_tab or TBL_GDT or RPL_3
   dscp         <task1_TSS_limit,0,0,TSS_ACC or DPL_3,0,0>      ;*!!

; ᥣ���� �⥪� ����� v86 �஢�� 0, RPL=DPL=0 �ᥣ��
stack0_selec    equ     $-gdt_tab or TBL_GDT or RPL_0
   dscp         <stack0_limit,0,0,DATA_ACC or DPL_0,0,0>        ;*!!

; ᥣ���� ������ ����� v86, RPL,DPL ࠧ�襭���� ����㯠
; �ᯮ��. ��� ����㯠 � ����� v86 ��� ������� ������権
; � ��� ����㯠 � �⥪� ����� v86
gdata1_selec    equ     $-gdt_tab or TBL_GDT or RPL_0
gdata1  label   byte
   dscp         <0ffffh,0,0,DATA_ACC or DPL_3,0,0>

GDT_size        equ     $-gdt_tab       ; ����� ⠡����
GDT_limit       equ     GDT_size-1
GDT             ends

;
; ��� 2: ⠡��� ���ਯ�஢ ���뢠��� ��⥬�
;
IDT             segment para    public  use16   'IDT'

idt_tab         equ     $
        REPT    INTNO
; ����. ���⨫� ���뢠���, DPL ��।���� �ਢ������ ����㯠 � ������,
; �ਢ������ ��ࠡ�⪨ ���뢠��� ������ ��� DPL � ���ਯ�� �����
; �� ����稨 v86 �ਢ������ ����㯠 � ���ਯ�ࠬ ���뢠��� ������
; ���� �㫥�묨 (DPL=0) ��� ���墠� ���뢠��� ०��� v86 �� ��饩 ����
          dscp  <0,int_selec,0,INT_ACC or DPL_0,0,0>
        ENDM
IDT_size        equ     $-idt_tab
IDT_limit       equ     IDT_size-1
IDT             ends

;
; ������� ������ ��⥬�
;
Gdata           segment para    public  use16   'Gdata'

;
; ��� 3: ����⥫� ���ਯ���� ⠡��� ��� ����㧪� ॣ���஢
;
pGDT    label   fword
        dw      GDT_limit               ; ࠧ��� GDT
        dd      0                       ; 䨧. ������ ���� GDT
pIDT    label   fword
        dw      IDT_limit               ; ࠧ��� IDT ����. ०���
        dd      0                       ; 䨧. ������ ���� IDT
pold    label   fword
        dw      03ffh                   ; ࠧ��� IDT ॠ�쭮� ����
        dd      0                       ; 䨧. ������ ���� IDT

;
; ��� 4: ⠡��� �८�ࠧ���⥫�� ���ਯ�஢ ᥣ���⮢ GDT
;
gdt_phys_tab    label   word
        dw      task0_TSS_selec,task0_TSS       ; ᥫ����,ᥣ����� ����
        dw      stk0_selec,stk0
        dw      stk1_selec,stk1
        dw      stk2_selec,stk2
        dw      stk3_selec,stk3
        dw      code_selec,code
        dw      gdata_selec,Gdata
        dw      int_selec,code
        dw      dmy_selec,dmy
        dw      rc_selec,code
        dw      gdt_selec,gdt
;
; ��� 4.1: ��� �������⥫��� ���ਯ�஢
;
        dw      stack0_selec,stack0
        dw      task1_TSS_selec,task1_TSS

gdt_tab_count   equ     ($-gdt_phys_tab)/4

;
; ��� 5: ��⥬�� ᮮ�饭��
;
msg_addr        dw      05               ; ��ப� ��砫� �뢮�� �� ��࠭
in_protected    db      'in protected mode',0
int_msg         db      'interrupt '
int_num         db      '????','H '
err_num         db      '????','H',0

;
; ��� 5.1: ��⥬�� ᮮ�饭�� v86
;
task1_msg       db      'switch to v86 mode',0dh,0ah,'$'
success         db      'now in v86 mode task 1 !!!',0dh,0ah
                db      'press any key to go back to protected mode'
                db      0dh,0ah,'$'
error           db      'error !',0
retmsg          db      'return to protected mode',0
stopmsg         db      'stop',0
intnum          db      ?
retaddr         dw      ?
err1            dw      0
err2            dw      0

;
; ������ ��� �࠭���� ॣ���஢ SS,SP,ES.
; ��� ��࠭����� ����� ��। �室�� � ���饭�� ०��.
real_ss         dw      ?
real_sp         dw      ?
real_es         dw      ?
int_mask        db      ?       ; ��� ᯠᥭ�� ��᪨ ���뢠���

Gdata_size      equ     $
Gdata_limit     equ     Gdata_size-1
Gdata           ends

;
; ��� 6: �⥪��� ᥣ����� ��� ��� �஢��� �ਢ������
;
stk0            segment para    public  use16   'stk0'
        db      100h    dup(0)
stk0_size       equ     $
stk0_limit      equ     stk0_size-1
stk0            ends

stk1            segment para    public  use16   'stk1'
        db      100h    dup(0)
stk1_size       equ     $
stk1_limit      equ     stk1_size-1
stk1            ends

stk2            segment para    public  use16   'stk2'
        db      100h    dup(0)
stk2_size       equ     $
stk2_limit      equ     stk2_size-1
stk2            ends

stk3            segment para    public  use16   'stk3'
        db      100h    dup(0)
stk3_size       equ     $
stk3_limit      equ     stk3_size-1
stk3            ends

DOS_stack       segment para    stack   'stack'
        db      100h    dup(?)
stk_DOS_size    equ     $
stk_DOS_limit   equ     stk_DOS_size-1
DOS_stack       ends

;
; ��� 6.1: �⥪��� ᥣ����� ��� v86
;
stack0          segment para    public  use16   'stack0'
        db      100h    dup(?)
stack0_size       equ     $
stack0_limit      equ     stack0_size-1
stack0            ends

;
; ��� 7: ᥣ���� ���ﭨ� ����� TSS
;
task0_TSS       segment para    public  use16   'task0'
TSS_stack       stk0_selec,stk0_size,stk1_selec,stk1_size,stk2_selec,stk2_size
TSS_cr3         0
TSS_regs        0,0,0,0,0,0,0,0,0,stk0_size
TSS_seg         gdata_selec,code_selec,stk0_selec,gdata_selec,gdata_selec,gdata_selec
                dd      0       ; LDT
                dw      0       ; T ��� TSS �ᥣ�� 0 �� ���樠����樨
                dw      068h    ; I/O table start
task0_TSS_size  equ     $
task0_TSS_limit equ     task0_TSS_size-1
task0_TSS       ends

;
; ��� 7.1: ᥣ���� ���ﭨ� ����� v86
; EFLAGS ����� IOPL=3, VM-set, IF-set
; v86_flags     equ     fl_vm or fl_iopl3 or fl_if or fl_set
; ᯠᥭ�� ᥣ����� ॣ����� ᮤ�ঠ� ᥣ����� ���� (CS,SS)
task1_TSS       segment para    public  use16   'task1'
TSS_stack       stk0_selec,stk0_size,stk1_selec,stk1_size,stk2_selec,stk2_size
TSS_cr3         0
TSS_regs        entry,v86_flags,0,0,0,0,0,0,0,stack0_size
TSS_seg         0,task1_seg,stack0,0,0,0
                dd      0       ; LDT
                dw      0       ; T ��� TSS �ᥣ�� 0 �� ���樠����樨
                dw      068h    ; I/O table start
                dw      100h    dup(0)  ; 4096 ���� ���⮢ i/o
task1_TSS_size  equ     $
task1_TSS_limit equ     task1_TSS_size-1
task1_TSS       ends

;
; ��� 8: ᥣ���� ������ � �ଠ� ॠ�쭮� ���� ��� ������ � DOS
;
dmy             segment para    public  use16   'dmy'
        db      128     dup(0)
dmy_size        equ     $
dmy_limit       equ     0ffffh
dmy             ends

;
; ������� ����� ��⥬�
;
code            segment para    public  use16   'code'
        assume  cs:code, ds:gdata

main    proc    far
        cli
        mov     ax,gdata
        mov     ds,ax

        mov     ax,stk0
        mov     ss,ax
        mov     sp,offset stk0_size
        sti
;
; ��� 9: ���樠������ IDT
;
        mov     ax,IDT
        mov     es,ax
        mov     di,offset idt_tab       ; DI=⠡��� ���뢠��� IDT
        mov     ax,offset int_entry     ; AX=���� �ண�. ��ࠡ. ���뢠���
                                        ; ��� ᬥ饭�� �� int_selec
        mov     cx,INTNO
fillidt:
        mov     es:[di],ax              ; ��� �室� � ���ਯ�� �맮��
        add     di,DSCPSIZE             ; ᫥�. ���ਯ�� � IDT
        add     ax,INTSIZE              ; �窠 �室� ��� ᫥�. ���뢠���
        loop    fillidt                 ; ��� ��� ���뢠��� � IDT

;
; ��� 10: ��ந� ����⥫� GDT
;
        build_gdtr      gdt,pgdt,gdt_limit

;
; ��� 11: ��ந� ����⥫� IDT
;
        build_idtr      idt,pidt,idt_limit

;
; ��� 12: ��ந� ��������� ⠡���� ���ਯ�஢ ��⥬� GDT
;
        build_dt        gdt,gdt_phys_tab,gdt_tab_count

;
; ��� 13: ���室�� � ���饭�� ०�� �� 0 �஢�� �ਢ������
;
        goto_prot       pgdt,pidt,code_selec,stk0_selec,stk0_size,Gdata_selec

;
; ��� 14: �뢮� ᮮ�饭�� � ���室� � ���饭�� ०��
;
        mov     ax,video_selec          ; ᥫ���� ����������
        mov     es,ax
        mov     cx,CRT_SIZE             ; ࠧ��� ����������
        shr     cx,TWO                  ; � ᫮���
        xor     di,di
        mov     ah,attribute
        mov     al,space
        rep     stosw                   ; ���⨬ ��࠭

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset in_protected  ; ���� ᮮ�饭�� (���筨�)
        mov     di,ax                   ; ���� ��࠭�    (�ਥ����)
        call    disp_it                 ; �뢥�� ��ப� �� ��࠭

;
; ��� 15: ����㧪� � TR TSS
;
        mov     ax,task0_TSS_selec
        ltr     ax
;
; ��� 15.1: ��४��祭�� �� ������ v86
;
        jmpf    task1_TSS_selec

;
; ��� 15.2: ��୥��� � ��᫥ ������ �� v86
;
        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset retmsg        ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it

;
; ��� 16: ������ ���⭮ � DOS
;
        jmp     goto_real_

;
; ��� 16.1: ��।���� �⥪ �� �室� � ���뢠���
;
spcheck         equ     offset (stk0_size - v86stklen - 4)
                ; �� �⮬� ����� �㤥� ��� �訡��, �᫨ �� ��,
                ; �� ���뢠��� �� ०��� v86

;
; ��� 17: ���ᨢ �祪 �室� �� ��ࠡ�⪥ ���뢠���
;
int_entry:
      REPT    INTNO
        call  intchk                    ; ��楤�� ��ࠡ�⪨ ���뢠���
        iret
      ENDM

;
; ��� 17.1: ������ ��ࠡ�⪨ ���뢠��� ��⥬�
;       1. ��⠭�������� ᥫ���� ��⥬��� ������
;       2. ���������� ���� ������ �� ������ ���뢠���
;       3. ���������� ��� �訡��, �᫨ ��� �뫠
intchk:
        push    eax
        mov     ax,gdata_selec
        mov     ds,ax                   ; ��⠭�� �� ��⥬�� �����
        pop     eax

        pop     [retaddr]               ; ���� ������樨 iret

        mov     [err1],0ffffh
        cmp     sp,spcheck              ; ��㡨�� �⥪� ����砥� �訡�� ?
        jne     contint                 ; neq, ���, �ய��⨬
        pop     [err1]                  ; ��� �訡�� �� �⥪�
        pop     [err2]                  ; �㤠 �� ����饭 dd, ���⨬ �⥪

;
; ��� 17.2: ����稬 ����� ����� ���뢠���
;
contint:
        pushad                          ; push all regs

        call    disp

        mov     ax,[retaddr]            ; ���� �窨 ������
        sub     ax,offset int_entry     ; ᬥ饭�� �窨 �室� � �����
        shr     ax,TWO                  ; /4 ��� ����祭�� ����� �����

        cmp     ax,13                   ; ���뢠��� ��饩 ����� 13 ?
        je      int_13                  ; eq, ��, ��ࠡ�⠥� ���

;
; ��� 17.3: �� ���뢠��� ��饩 �����, ����稬 ���� ������
;
        mov     cx,stk0_selec
        mov     es,cx                   ; ES = stk0
        mov     bx,sp
        add     bx,size pushaddef       ; �ய��⨬ pushad
        mov     esi,es:[bx+oldeip]      ; ���� ������ �� ���뢠��� (DOS)
        jmp     setint                  ; ax = #���뢠���

;
; ��� 17.4: ���뢠��� ��饩 �����, �᫨ �� intn, � ��ࠡ�⠥�,
;           ���� ����� �ணࠬ��
;
int_13:
        mov     ax,stk0_selec
        mov     es,ax                   ; ES = stk0
        mov     bx,sp
        add     bx,size pushaddef       ; �ய��⨬ pushad
        mov     eax,es:[bx+oldecs]      ; ᥣ���� ����� � DOS
        mov     ch,ah
        shl     ax,4
        shr     ch,4                    ; ch:ax = 24 bit ������� ����

        assume  ds:gdt

        mov     dx,gdt_selec
        mov     ds,dx                   ; DS = gdt
        mov     [gdata1.d_base1],ax     ; ������� ���� ����� � ���ਯ��
        mov     [gdata1.d_base2],ch     ; ������ ��� ����㯠 � ��������
        mov     ax,gdata1_selec
        mov     ds,ax                   ; DS = ᥣ���� ����� ����� v86
        mov     esi,es:[bx+oldeip]      ; si = ���� ������樨 ���뢠���
        cld
        lodsb                           ; al = �������, �맢���� ���뢠���
        cmp     al,0cdh                 ; ��� ������� "INT n" ?
        jne     stop                    ; neq, ���, ����� �ணࠬ��

;
; ��� 17.5: �뫮 ���뢠��� v86 "INT n", 㧭��� �����
;
procint:
        lodsb                           ; al = # ����襭���� ���뢠���

;
; ��� 17.6: �᫨ ����襭� ���뢠��� INT 1 (T-bit), ����� ࠡ���
;
        cmp     al,1
        je      int_1

;
; ��� 17.7: ��⮢�� �⥪ ����� v86 ��� ��室� �� ᢮��� ���뢠���,
;           ��᪮��� ������ ���뢠��� �뫠 �믮����� � ०���
;           v86, � �� 8086 � � �⥪� 0 ��⥬�
;   SI = IP (v86) ������ �� ���뢠���
;   AL = �ந��襤襥 ��� ����襭��� ���뢠��� � ०��� v86
setint:
        mov     ecx,es:[bx+oldess]
        mov     dh,ch
        shl     cx,4
        shr     dh,4                    ; dh:cx = 24 bit ���� �⥪� v86
        mov     di,gdt_selec
        mov     ds,di
        mov     [gdata1.d_base1],cx
        mov     [gdata1.d_base2],dh     ; ����ந� ࠡ�稩 ���ਯ�� �� SS
        mov     dx,gdata1_selec
        mov     ds,dx                   ; DS = v86 SS ᥫ����
        mov     edi,es:[bx+oldesp]      ; DI = v86 SP
        sub     edi,6                   ; ��१�ࢨ�㥬 ���� ��� 3 ��ࠬ���
        mov     es:[bx+oldesp],edi      ; ���뢠��� (IP,CS,FLAGS)
        mov     [di],si                 ; IP �������� � �⥪ v86
        mov     edx,es:[bx+oldecs]
        mov     [di+2],dx               ; CS �������� � �⥪ v86
        mov     edx,es:[bx+oldeflg]
        mov     [di+4],dx               ; FLAGS �������� � �⥪ v86

;
; ��� 17.8: ��⮢�� ���室 �� ��ࠡ��� ���뢠��� DOS
;   AL  = �ந��襤襥 ��� ����襭��� ���뢠��� � ०��� v86
;   EDX = ᫮�� 䫠��� v86 � ������ ���뢠���
        and     dx,NOT (fl_if or fl_tf) ; ���⨬ IF � TF � ᫮�� 䫠��� v86
        mov     cx,dos_selec
        mov     ds,cx                   ; DS = ᥫ���� ����஢ v86
        xor     ah,ah
        shl     ax,2                    ; ���� ����⥫� �����
        xor     si,si
        add     si,ax                   ; SI = ������ ����� � ⠡��� DOS
        xor     eax,eax
        mov     ax,[si]                 ; v86 vector offset
        xor     ecx,ecx
        mov     cx,[si+2]               ; v86 vector segment
        mov     es:[bx+oldecs],ecx      ; vector's CS     �������� � stk0
        mov     es:[bx+oldeip],eax      ; vector's EIP    �������� � stk0
        mov     es:[bx+oldeflg],edx     ; vector's EFLAGS �������� � stk0
        popad
        db      066h                    ; LARGE ��䨪�
        iret                            ; ��३� �� ��ࠡ��� ���뢠���
                                        ; � ����� v86

;
; ��� 17.9: ��⠭�� �ணࠬ��, ��� � �訡��
;
stop:
        assume  ds:gdata

        mov     dx,gdata_selec
        mov     ds,dx                   ; DS = gdata
        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset stopmsg       ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it

;
; ��� 17.10: ������ � ���饭�� ०�� �� ०��� v86
;
int_1:
        popad                           ; ����⠭����� �⥪
        jmpf    task0_TSS_selec         ; ��४����� ������

;
; ��� 18: ������ �⠭���⭮� ��ࠡ�⪨ ���뢠���
;         ������ ����� ����� � �뢮��� ��� �� ��࠭
;         � �����頥��� � DOS
;
disp    proc    near
        push    eax
        push    esi
        push    ecx

        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        mov     ax,[err1]               ; ��� �訡��
        shr     ax,3                    ; ax = ����� ����� DOS

        cmp     ax,029h
        jz      no_disp
        cmp     ax,010h
        jz      no_disp
        cmp     ax,028h
        jz      no_disp
        cmp     ax,016h
        jz      no_disp
        cmp     ax,02ah
        jz      no_disp
        cmp     ax,01ch
        jz      no_disp
        cmp     ax,01ah
        jz      no_disp
        cmp     ax,015h
        jz      no_disp

        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        mov     ax,[retaddr]            ; ���� ������
        sub     ax,offset int_entry
        shr     ax,TWO                  ; ax= ����� �����

        cmp     ax,008h                 ; DOS timer �ய��⨬
        jz      no_disp

        xor     esi,esi                 ; ���⨬ ���� ��ப�
        mov     si,offset int_num       ; ���� ��ப� ����� �����
        mov     cx,WORDLEN              ; �᫮ ᨬ����� � ��ப�
        call    htoa                    ; HEX->ASCII (esi,cx,eax)

        xor     eax,eax                 ; ���⨬ �᫮ ��� �८�ࠧ������
        mov     ax,[err1]               ; ��� �訡��
        xor     esi,esi
        mov     si,offset err_num       ; ���� ��ப� ���� �訡��
        mov     cx,WORDLEN              ; �᫮ ᨬ����� � ��ப�
        call    htoa                    ; HEX->ASCII (esi,cx,eax)

        mov     ax,[msg_addr]           ; ����� ��ப� �� ��࠭�
        cmp     ax,25
        ja      no_disp
        inc     [msg_addr]              ; ᫥�. ��ப� �� 1 �����
        mov     cl,160                  ; ����� ��ப� � �����
        mul     cl                      ; AX = ���� ᮮ�饭�� �� ��࠭�
        mov     si,offset int_msg       ; ���� ��ப� (���筨�)
        mov     di,ax                   ; ���� ��࠭� (�ਥ����)
        call    disp_it                 ; �뢥�� ��ப� �� ��࠭

no_disp:
        pop     ecx
        pop     esi
        pop     eax
        ret
disp    endp

;
; ��� 19: ������ � ॠ��� ०�� ������
;
goto_real_:
        goto_real dmy_selec,code,stk0,stk0_size,Gdata

;
; ��� 20: ������ � DOS
;
        mov     ax,4c00h                ; Exit Process
        int     21h

main    endp

;
; ��楤�� �뢮�� ��ப� �� ��ᯫ�� � ���饭��� ०���
;  DS:SI - ���� ��ப� ᨬ����� ASCIZ; DI - ᬥ饭�� � ����������
;
disp_it         proc    near
        push    ax
        push    es
        mov     ax,video_selec          ; ᥫ���� ����������
        mov     es,ax
        mov     ah,attribute            ; ��ਡ�� ᨬ�����
disp_loop:
        lodsb                           ; ᨬ��� �� ��ப�
        cmp     al,0                    ; ����� ��ப� ?
        jz      end_disp                ; z, ��, ������
        stosw                           ; ᨬ��� � �����������
        jmp     disp_loop               ; ������� �� ���� ��ப�
end_disp:
        pop     es
        pop     ax
        ret
disp_it         endp

;
; ��楤�� �८�ࠧ������ HEX->ASCII
;  DS:ESI - ���� ��ப� ᨬ�����, CX - �� �����,
;  EAX    - �᫮ ��� �८�ࠧ������
htoa_tab        db      '0123456789ABCDEF'
htoa            proc    near
        push    ebx
        push    eax
        xor     ebx,ebx
        add     si,cx
        dec     si                      ; ��⠭�� �� ����� ��ப�
htoa_loop:
        mov     bl,al
        and     bl,0fh
        mov     bl,cs:[ebx+htoa_tab]    ; ASCII ��� ᨬ����
        mov     byte ptr [esi],bl       ; ��� � ��ப� ᨬ�����
        dec     esi                     ; �த������� � ��ப� ᨬ�����
        shr     eax,4                   ; �த������� � �᫥ �� ��ࠤ�
        loop    htoa_loop
        pop     eax
        pop     ebx
        ret
htoa            endp

code_size       equ     $
code_limit      equ     code_size-1
code            ends

;
; ��� 23: ������ ᥣ���� ����� v86
;       �ᯮ������ �����⢫���� � ०��� v86
;
task1_seg       segment para    public  use16   'task1_seg'
        assume  cs:task1_seg, ds:gdata

task_entry      proc    near
entry:
        mov     ax,gdata
        mov     ds,ax                   ; DS = SEGMENT gdata

;;        mov     al,[int_mask]           ; ��᪠ ���뢠���
;;        and     al,NOT 002h             ; ࠧ�訬 ���뢠��� ���������
        mov     al,NOT 002h             ; ࠧ�訬 ���뢠��� ���������
        out     INT_MASK_PORT,al        ; ���뢠���
;
; ��� 24: ����� � DOS (INT 21h) �� �뢮� ��ப�
;
        mov     dx,offset task1_msg     ; ���� ᮮ�饭�� DOS
        mov     ah,09                   ; ������� �뢮�� ��ப�
        int     21h                     ; ���뢠��� � DOS

        mov     dx,offset success       ; ���� ᮮ�饭�� DOS
        mov     ah,09                   ; ������� �뢮�� ��ப�
        int     21h                     ; ���뢠��� � DOS

;
; ��� 25: ����� � DOS (INT 21h) �� ���� ᨬ���� � ����������
;
        mov     ah,1
        int     21h                     ; ���� ����� ᨬ���� � ����������

;
; ��� 26: ������ �� ०��� v86 � ���饭�� ०��
;
        mov     al,0ffh                 ; ����⨬ ���뢠��� ����஫����
        out     INT_MASK_PORT,al        ; ���뢠���

        int     1
task_entry      endp

task1_seg       ends

        end     main

