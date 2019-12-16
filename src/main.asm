.386

.model	flat, stdcall
option	casemap :none

;include files
INCLUDE	windows.inc
INCLUDE	user32.inc
INCLUDE	kernel32.inc
INCLUDE	comctl32.inc	
INCLUDE	winmm.inc
INCLUDE	comdlg32.inc
INCLUDE	msvcrt.inc
INCLUDE shlwapi.inc
INCLUDE msvcrt.inc
INCLUDE gdi32.inc
INCLUDE gdiplus.inc
INCLUDE wsock32.inc

;include libs
INCLUDELIB shlwapi.lib
INCLUDELIB user32.lib
INCLUDELIB kernel32.lib
INCLUDELIB comctl32.lib
INCLUDELIB winmm.lib
INCLUDELIB msvcrt.lib
INCLUDELIB comdlg32.lib
INCLUDELIB gdi32.lib
INCLUDELIB gdiplus.lib
INCLUDELIB wsock32.lib

;function declaration
main_proc	PROTO	:DWORD,:DWORD,:DWORD,:DWORD
init	PROTO :DWORD
handle_exit		PROTO :DWORD
open_song		PROTO:DWORD, :DWORD
alter_song		PROTO :DWORD, :DWORD
handle_add_btn	PROTO :DWORD
handle_dele_btn PROTO :DWORD
handle_play_btn	PROTO :DWORD
alter_volume	PROTO :DWORD
show_volume		PROTO :DWORD
read_lrc_file	PROTO:DWORD, :DWORD
show_lrc		PROTO:DWORD
handle_time_slider		PROTO  :DWORD
alter_time				PROTO  :DWORD
switch_next_song		PROTO  :DWORD
handle_silence_btn		PROTO : DWORD
handle_recycle_btn		PROTO : DWORD

;�����ṹ��
Song STRUCT
	music_name BYTE 100 DUP(0);������
	music_path BYTE 100 DUP(0);����·��
Song ends

;lrc��ʽṹ��
Lyric STRUCT
	content BYTE 100 DUP(0);�������
	time DWORD 0;��ʿ�ʼʱ��
Lyric ends

.const
	IMG_LOGO	EQU	200
	IMG_START	EQU	300
	IMG_PAUSE	EQU	301
	IMG_OPEN_SOUND	EQU	304
	IMG_CLOSE_SOUND	EQU	305
	IMG_RECYCLE		EQU	306
	IMG_SINGLE		EQU	307
	IMG_RANDOM		EQU	308

	IDD_MAIN			EQU 1000
	IDB_EXIT			EQU 1001
	IDC_paly_btn		EQU 1100;���Ű�ť
	IDC_time_slider		EQU 1101;ʱ�������
	IDC_vol_slider		EQU 1102;����
	IDC_song_menu		EQU 1103;�赥�б�
	IDC_vol_txt			EQU 1104;������ʾ
	IDC_time_txt		EQU 1105;������ʾ
	
	IDC_prev_btn		EQU 1200;��һ�׸�
	IDC_next_btn		EQU 1201;��һ�׸�
	IDC_backward		EQU 1203;����
	IDC_forward			EQU 1204;���
	
	IDC_add_music_btn		EQU 1205;�������
	IDC_dele_btn			EQU 1206;ɾ������
	IDC_silence_btn			EQU 1207;������ť
	IDC_recycle_btn			EQU 1208;ѭ��ģʽ��ť
	IDC_lyrics_current		EQU 1220;�����ʾ
	IDC_lyrics_prev1		EQU 1221;�����ʾ
	IDC_lyrics_next1		EQU 1222;�����ʾ
	IDC_lyrics_prev2		EQU 1223;�����ʾ
	IDC_lyrics_next2		EQU 1224;�����ʾ
	IDC_lyrics_board		EQU 1225

	SINGLE_REPEAT		EQU 0;����ѭ��
	LIST_REPEAT			EQU 1;�б�ѭ��
	RANDOM_REPEAT		EQU 2;���ѭ��

	STOP_MUSIC		EQU 0;ֹͣ����
	PLAY_MUSIC		EQU 1;���ڲ���
	PAUSE_MUSIC		EQU 2;��ͣ����

	WM_SHELLNOTIFY    	EQU WM_USER+5 
	
.data	
	;--------mci����--------
	cmd_open BYTE 'open "%s" alias my_song type mpegvideo',0
	cmd_close BYTE "close my_song",0
	cmd_play BYTE "play my_song", 0	
	cmd_pause BYTE "pause my_song",0
	cmd_resume BYTE "resume my_song",0
	cmd_getLen BYTE "status my_song length", 0
	cmd_getPos BYTE "status my_song position", 0
	cmd_setPos BYTE "seek my_song to %d", 0
	cmd_setStart BYTE "seek my_song to start", 0	
	cmd_setVol BYTE "setaudio my_song volume to %d",0
	;--------mci����--------

	list_name BYTE "\\song.txt",0 ;�赥�ļ�

	;--------��ǰ������Ϣ--------
	current_len BYTE 32 dup(0)
	current_len_minute DWORD 0
	current_len_second DWORD 0

	current_pos BYTE 32 dup(0)
	current_pos_minute DWORD 0
	current_pos_second DWORD 0	

	current_index DWORD 0;��ǰ�����ڸ赥�е��±�
	;--------��ǰ������Ϣ--------

	;--------��ʽ������Ϣ--------
	scale_second DWORD 1000		;��ת������
	scale_minute DWORD 60		;����ת����	
	int_fmt BYTE '%d',0	
	time_fmt BYTE "%d:%d/%d:%d", 0	;ʱ����ʾ��ʽ
	;--------��ʽ������Ϣ--------

	;--------״̬ģʽ��Ϣ--------
	dragging DWORD 0	;�Ƿ������϶���������0-��1-��
	repeat_mode BYTE 0	;ѭ��ģʽ������/�б�/���
	play_state BYTE 0	;����״̬��ֹͣ/����/��ͣ	
	have_sound BYTE 1	;�Ƿ�������
	;--------״̬ģʽ��Ϣ--------

	;�赥��Ϣ
	song_menu Song 100 dup(<"1", "1">)
	song_menu_size DWORD 0  ;�赥��С
	
	;------���ļ��Ի�����Ϣ------
	open_file_dlg OPENFILENAME <>
	dlg_title BYTE 'ѡ�񲥷�����', 0	
	dlg_warning_title BYTE '����', 0
	dlg_warning BYTE '��ѡ��Ҫɾ���ĸ�����', 0
	dlg_init_dir BYTE '\\', 0
	dlg_open_file_names BYTE 8000 DUP(0)
	dlg_file_name BYTE 100 DUP(0)
	dlg_path BYTE 100 DUP(0)
	dlg_nmax_file = SIZEOF dlg_open_file_names
	dlg_base_dir BYTE 256 DUP(0)
	sep BYTE '\\'
	;------���ļ��Ի�����Ϣ------

	;--------�����Ϣ--------
	lrc_array Lyric 500 dup(<>) ;�������
	lrc_lines dword 0 ;��ʵ�����
	
	lrc_addr dword 1000 dup(0)	;ÿ���ʵ�ַ
	lrc_time dword 1000 dup(0)	;��ʶ�Ӧ��ʱ��
	cur_lrc_index dword 0	;��ǰ���index
	lyric_line_total dword 0;������
	
	lrc_next_sentence byte "[", 0
	has_lyric byte 0;�Ƿ����������
	none_lrc_txt byte "�޸�ʵĴ����֣����߸���ļ���·��^_^",0
	empty_lrc byte "^_^",0
	long_str byte 1000 dup(0)
	dot_lrc byte ".lrc", 0
	point byte ".", 0
	lrc_buffer byte 200000 dup(0)
	lrc_file byte 2000 dup(0)
	actual_read_bytes dword 0
	lrc_prepare byte "- - - - - - - -",0
	;--------�����Ϣ--------

.data?
	hInstance	dd	?
	mci_cmd BYTE ?; mci��������
.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	invoke	InitCommonControls
	;��rc�ļ�ģ���ʼ��
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset main_proc, 0
	invoke	ExitProcess, eax

;##################################################
; �����̺���
;##################################################
main_proc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL wc:WNDCLASSEX 
	LOCAL current_slider:DWORD	
	.if	uMsg == WM_CLOSE		;�˳�����
		invoke handle_exit, hWin
	.elseif	uMsg == WM_INITDIALOG	;��ʼ������
    	mov   wc.style, CS_HREDRAW or CS_DBLCLKS or CS_VREDRAW
    	invoke RegisterClassEx, addr wc ;ע�ᴰ��
		invoke init, hWin
		invoke	LoadIcon,hInstance,IMG_LOGO
		invoke	SendMessage, hWin, WM_SETICON, 1, eax  ;����ͼ��

	.elseif uMsg == WM_TIMER	;��ʱ����Ϣ
		.if play_state == PLAY_MUSIC
			invoke handle_time_slider, hWin	;ˢ�½�����
			invoke show_lrc, hWin			;ˢ�¸��
			invoke switch_next_song, hWin	;����Ƿ���ɲ��л�����
		.endif

	.elseif uMsg == WM_COMMAND ;��������
		mov	eax,wParam
		.if	ax == IDB_EXIT
			invoke	SendMessage, hWin, WM_CLOSE, 0, 0
		.elseif ax == IDC_add_music_btn	;���µ��������
			invoke handle_add_btn, hWin
		.elseif song_menu_size == 0	;���ɸ赥Ϊ��,���ఴť��Ч
			ret 
		.elseif ax == IDC_song_menu  ;ѡ�и赥Ԫ��
			shr eax,16
			.if ax == LBN_SELCHANGE	;ѡ������ı�
				invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_GETCURSEL, 0, 0	;��ȡ��ǰѡ��index
				invoke alter_song,hWin,eax	;�ı䲥�Ÿ���
			.endif
		.elseif ax == IDC_paly_btn	;����/��ͣ
			invoke handle_play_btn, hWin
		.elseif ax == IDC_prev_btn		;ǰһ�׸�
			.if current_index == 0
				mov eax, song_menu_size
				mov current_index,eax
			.endif
			dec current_index
			invoke SendDlgItemMessage,hWin, IDC_song_menu, LB_SETCURSEL, current_index, 0
			invoke alter_song,hWin,current_index
		.elseif ax == IDC_next_btn;�������һ�׸�
			inc current_index
			mov eax, current_index
			.if eax == song_menu_size
				mov current_index,0
			.endif
			invoke SendDlgItemMessage,hWin, IDC_song_menu, LB_SETCURSEL, current_index, 0
			invoke alter_song,hWin,current_index
		.elseif ax == IDC_backward	 ;���������			
			.if play_state == 1		;��ǰΪ����״̬
				invoke mciSendString, addr cmd_getPos, addr current_pos, 32, NULL	;��ȡ��ǰ����λ��
				invoke StrToInt, addr current_pos	;��ǰ����ת��int
				mov edi, eax
				.if edi < 5000  ;5�����ڷ��ؿ�ͷ���������5��
					mov edi, 0
				.else
					add edi, -5000
				.endif
				invoke SendDlgItemMessage, hWin, IDC_time_slider, TBM_SETPOS, 1, edi
				invoke wsprintf, addr mci_cmd, addr cmd_setPos, edi		;����mci_cmd��ʽ
				invoke mciSendString, addr mci_cmd, NULL, 0, NULL	
				invoke mciSendString, addr cmd_play, NULL, 0, NULL
			.endif
		.elseif ax == IDC_forward	;��������			
			.if play_state == 1	;��ǰΪ����״̬
				invoke mciSendString, addr cmd_getPos, addr current_pos, 32, NULL	;��ȡ��ǰ����λ��
				invoke StrToInt, addr current_pos	;��ǰ����ת��int
				mov edi, eax
				add edi, 5000	;���5��
				invoke SendDlgItemMessage, hWin, IDC_time_slider, TBM_SETPOS, 1, edi
				invoke wsprintf, addr mci_cmd, addr cmd_setPos, edi		;����mci_cmd��ʽ
				invoke mciSendString, addr mci_cmd, NULL, 0, NULL	
				invoke mciSendString, addr cmd_play, NULL, 0, NULL
			.endif
		.elseif ax == IDC_silence_btn	;���¾�����ť
			invoke handle_silence_btn,hWin
		.elseif ax == IDC_recycle_btn	;����ѭ����ť
			invoke handle_recycle_btn,hWin		
		.elseif ax == IDC_dele_btn	;����ɾ����ť
			invoke handle_dele_btn, hWin
		.endif

	.elseif uMsg == WM_HSCROLL		;��������Ϣ
		invoke GetDlgCtrlID,lParam
		mov current_slider,eax	;���浱ǰ�����ؼ�
		mov ax,WORD PTR wParam
		.if current_slider == IDC_vol_slider
			.if ax == SB_THUMBTRACK		;������Ϣ
				invoke alter_volume,hWin
				invoke show_volume, hWin
			.endif
		.elseif current_slider == IDC_time_slider
			.if ax == SB_THUMBTRACK		;������
				mov dragging, 1
			.elseif ax == SB_ENDSCROLL	;��������
				mov dragging, 0
				invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_GETCURSEL, 0, 0	;��ȡ�����б���ѡ����Ŀ
				.if eax != -1
					invoke alter_time, hWin
				.endif
			.endif
		.endif
	.endif
	mov	eax, 0
	ret
main_proc endp

;##################################################
; һЩ��ʼ������
;##################################################
init proc hWin:DWORD

	LOCAL hFile: DWORD
	LOCAL bytes_read: DWORD

	;��ȡ�赥
	invoke crt__getcwd, ADDR dlg_base_dir, SIZEOF dlg_base_dir
	invoke lstrcpy, ADDR dlg_file_name, ADDR dlg_base_dir
	invoke lstrcat, ADDR dlg_file_name, ADDR list_name
	invoke CreateFile, ADDR dlg_file_name, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	mov hFile, eax
	.if hFile == INVALID_HANDLE_VALUE
		mov song_menu_size, 0
	.else
		invoke ReadFile, hFile, ADDR song_menu_size, SIZEOF song_menu_size, ADDR bytes_read, NULL
		.if bytes_read != SIZEOF song_menu_size
			mov song_menu_size, 0
		.else
			invoke ReadFile, hFile, ADDR song_menu, SIZEOF song_menu, ADDR bytes_read, NULL
			.if bytes_read != SIZEOF song_menu
				mov song_menu_size, 0
			.endif
		.endif
	.endif
	invoke CloseHandle, hFile

	;�ڿռ�����ʾ�赥
	mov ecx, song_menu_size
	mov esi, offset song_menu
	.if ecx > 0
		L1:
			push ecx
			invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_ADDSTRING, 0, ADDR (Song PTR [esi]).music_name
			add esi, TYPE song_menu
			pop ecx
		loop L1
	.endif
		
	;0.2 ��ˢ��һ��
	invoke SetTimer, hWin, 1, 200, NULL
	
	;������ICON
	mov eax, IMG_START
	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
	invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax
	
	;ѭ������ICON
	mov repeat_mode,LIST_REPEAT
	mov eax, IMG_RECYCLE
	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
	invoke SendDlgItemMessage,hWin,IDC_recycle_btn, BM_SETIMAGE, IMAGE_ICON, eax	
	
	;������ťICON
	mov have_sound, 1
	mov eax, IMG_OPEN_SOUND
	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
	invoke SendDlgItemMessage,hWin,IDC_silence_btn, BM_SETIMAGE, IMAGE_ICON, eax

	;��ʼ��������
	invoke SendDlgItemMessage, hWin, IDC_vol_slider, TBM_SETRANGEMIN, 0, 0
	invoke SendDlgItemMessage, hWin, IDC_vol_slider, TBM_SETRANGEMAX, 0, 1000
	invoke SendDlgItemMessage, hWin, IDC_vol_slider, TBM_SETPOS, 1, 1000
	Ret
init endp


;##################################################
; ����ر�
;##################################################
handle_exit proc hWin:DWORD
	LOCAL hFile: HANDLE
	LOCAL bytes_written: DWORD
	;�رղ��Ÿ���
	.if play_state != STOP_MUSIC
		invoke mciSendString, ADDR cmd_close, NULL, 0, NULL
	.endif

	;����赥
	invoke lstrcat, ADDR dlg_base_dir, ADDR list_name
	invoke CreateFile, ADDR dlg_base_dir, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov hFile, eax
	.if hFile != INVALID_HANDLE_VALUE
		invoke WriteFile, hFile, ADDR song_menu_size, SIZEOF song_menu_size, ADDR bytes_written, NULL
		invoke WriteFile, hFile, ADDR song_menu, SIZEOF song_menu, ADDR bytes_written, NULL
		invoke CloseHandle, hFile
	.endif

	;�رնԻ���
	invoke	EndDialog, hWin, 0
	ret
handle_exit endp

;##################################################
; ��ȡmp3�ļ�Ŀ¼�µ�lrc�ļ�
;##################################################
read_lrc_file proc hWin:DWORD, index:DWORD
	local hFile:DWORD
	local dscale:DWORD
	local offs:DWORD
	local times:DWORD
	local current_time:DWORD

	mov lrc_lines, 0
	mov offs, 48
	
	mov eax, index
	mov ebx, type song_menu
	mul ebx
	invoke lstrcpy,addr lrc_file,addr song_menu[eax].music_path
	invoke StrRStrI,addr lrc_file, NULL, addr point
	mov esi, eax
	invoke lstrcpy,esi, addr dot_lrc	;����mp3�ļ��ҵ�lrc�ļ�
	
	;��ȡlrc�ļ�
	invoke CreateFile,addr lrc_file,GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	mov hFile, eax
	.if hFile == INVALID_HANDLE_VALUE	;��ʧ��
		mov has_lyric, byte ptr 0		;״̬����lrc
		invoke SendDlgItemMessage, hWin, IDC_lyrics_current, WM_SETTEXT, 0, addr none_lrc_txt
		invoke SendDlgItemMessage, hWin, IDC_lyrics_prev1, WM_SETTEXT, 0, addr empty_lrc
		invoke SendDlgItemMessage, hWin, IDC_lyrics_prev2, WM_SETTEXT, 0, addr empty_lrc
		invoke SendDlgItemMessage, hWin, IDC_lyrics_next1, WM_SETTEXT, 0, addr empty_lrc
		invoke SendDlgItemMessage, hWin, IDC_lyrics_next2, WM_SETTEXT, 0, addr empty_lrc
	.else	;����lrc
		mov has_lyric, byte ptr 1
		mov cur_lrc_index, 0
		invoke ReadFile, hFile, addr lrc_buffer, sizeof lrc_buffer, addr actual_read_bytes, NULL
		mov times, 0
		invoke StrStrI,addr lrc_buffer, addr lrc_next_sentence
		mov esi, eax
		
		L2:
		movzx ebx, byte ptr [esi+1]
		.if ebx>=48
			.if ebx<=57
				;������ʽ��ȣ�min:s.ms
				movzx eax, byte ptr [esi+1]
				sub eax, offs
				mov dscale, 10
				mul dscale
				
				movzx ebx, byte ptr [esi+2]
				sub ebx, offs
				add eax, ebx
				mov dscale, 60
				mul dscale
				
				push eax
				
				movzx eax, byte ptr [esi+4]
				sub eax, offs
				mov dscale, 10
				mul dscale
				
				movzx ebx, byte ptr [esi+5]
				sub ebx, offs
				add eax, ebx
				
				pop ebx	;ȡ������ת���ɵ�����
				
				add eax, ebx	;eax�д���������
				
				mov dscale, 100
				mul dscale
				
				push eax
				
				movzx eax, byte ptr [esi+7]
				sub eax, offs
				mov dscale, 10
				mul dscale
				
				movzx ebx, byte ptr [esi+8]
				sub ebx,offs
				add eax, ebx
				
				pop ebx
				add eax, ebx
				
				mov dscale, 10
				mul dscale	
				
				mov current_time, eax
				mov eax, times
				mov ebx, TYPE dword
				mul ebx
				mov ebx, current_time
				mov [lrc_time + eax], ebx
				mov [lrc_addr + eax], esi
				
				invoke StrStrI,addr [esi+1], addr lrc_next_sentence
				.if eax != 0
					mov esi, eax	;esiָ����һ��[�ĵ�ַ
					inc times
					jmp L2
				.else
					mov eax, times
					mov lyric_line_total, eax
					jmp L2_END
				.endif
			.else
				invoke StrStrI,addr [esi+1], addr lrc_next_sentence
				mov esi, eax
				cmp eax, 0
				jne L2
				jmp L2_END
			.endif
		.else
			invoke StrStrI,addr [esi+1], addr lrc_next_sentence
			mov esi, eax
			cmp eax, 0
			jne L2
			jmp L2_END
		.endif
	.endif
	L2_END:
	INVOKE CloseHandle, hFile
	
	Ret
read_lrc_file endp

;##################################################
; ʵʱ��ʾ���
;##################################################
show_lrc proc hWin:DWORD
	local present_line:DWORD
	local play_progress:DWORD
	.if play_state == PLAY_MUSIC		;tied with playing mode
		.if has_lyric == 1
			invoke mciSendString, addr cmd_getPos, addr current_pos, 32, NULL		;fetch current time pos to %eax
			invoke StrToInt, addr current_pos		;int->str in %eax
			mov play_progress, eax					;for checking which line the progress locate
			mov present_line, 0
			mov edx, present_line
			.while edx <= lyric_line_total
				mov eax, present_line
				mov ebx, TYPE dword
				mul ebx						;eax stores how much the present_line differs from lrc_array
				mov ebx, lrc_time[eax]	;lyric position
				;Middle line
				.if ebx > play_progress				;checking which line the progress locate(first to ">", later we'll Ret)
						
					mov edi, lrc_addr[eax];starting address
					mov ebx, present_line
					.if ebx == 0			;starting part of the song
						invoke SendDlgItemMessage, hWin, IDC_lyrics_current, WM_SETTEXT, 0, addr lrc_prepare
					.else
						mov eax, present_line
						mov ebx, TYPE dword
						mul ebx				;eax stores how much the present_line differs from lrc_array
						sub eax, TYPE dword
						mov esi, lrc_addr[eax];former line address
						mov edx, edi			;line address
						sub edx, esi			;Bytes that we should print
						sub edx, 10				;[3,12.1]should not be printed
						invoke lstrcpyn, addr long_str, addr [esi+10], edx
						invoke SendDlgItemMessage, hWin, IDC_lyrics_current, WM_SETTEXT, 0, addr long_str
					.endif

					;1st line
					dec present_line
					dec present_line
					mov edx, present_line
					mov eax, present_line
					mov ebx, TYPE dword
					mul ebx				;eax stores how much the present_line differs from lrc_array
					mov edi, lrc_addr[eax]
					mov ebx, lrc_time[eax]
					.if ebx <= 0
						;invoke lstrcpy, addr long_str, addr [edi+10]
						invoke SendDlgItemMessage, hWin, IDC_lyrics_prev2, WM_SETTEXT, 0, addr lrc_prepare
					.else
						mov eax, present_line
						mov ebx, TYPE dword
						mul ebx					;eax stores how much the present_line differs from lrc_array
						sub eax, TYPE dword
						mov esi, lrc_addr[eax];former line address
						mov edx, edi			;line address
						sub edx, esi			;Bytes that we should print
						sub edx, 10				;[3,12.1]should not be printed
						invoke lstrcpyn, addr long_str, addr [esi+10], edx
						invoke SendDlgItemMessage, hWin, IDC_lyrics_prev2, WM_SETTEXT, 0, addr long_str
					.endif
					inc present_line
					inc present_line

					;�ڶ���
					dec present_line
					mov edx, present_line
					mov eax, present_line
					mov ebx, TYPE dword
					mul ebx					;eax stores how much the present_line differs from lrc_array
					mov edi, lrc_addr[eax]
					mov ebx, lrc_time[eax]
					.if ebx <= 0
						invoke SendDlgItemMessage, hWin, IDC_lyrics_prev1, WM_SETTEXT, 0, addr lrc_prepare
					.else
						mov eax, present_line
						mov ebx, TYPE dword
						mul ebx					;eax stores how much the present_line differs from lrc_array
						sub eax, TYPE dword
						mov esi, lrc_addr[eax];former line address
						mov edx, edi			;line address
						sub edx, esi			;Bytes that we should print
						sub edx, 10				;[3,12.1]should not be printed
						invoke lstrcpyn, addr long_str, addr [esi+10], edx
						invoke SendDlgItemMessage, hWin, IDC_lyrics_prev1, WM_SETTEXT, 0, addr long_str
					.endif
					inc present_line
						
					;������
					inc present_line
					mov edx, present_line
					mov eax, present_line
					mov ebx, TYPE dword
					mul ebx				;eax stores how much the present_line differs from lrc_array
					mov edi, lrc_addr[eax]
					mov ebx, lrc_time[eax]
						
					mov eax, present_line
					mov ebx, TYPE dword
					mul ebx						;eax stores how much the present_line differs from lrc_array
					sub eax, TYPE dword
					mov esi, lrc_addr[eax];former line address
					mov edx, edi			;line address
					sub edx, esi			;Bytes that we should print
					sub edx, 10				;[3,12.1]should not be printed
					invoke lstrcpyn, addr long_str, addr [esi+10], edx
					invoke SendDlgItemMessage, hWin, IDC_lyrics_next1, WM_SETTEXT, 0, addr long_str
					dec present_line
						
					;������
					inc present_line
					inc present_line
					mov edx, present_line
					mov eax, present_line
					mov ebx, TYPE dword
					mul ebx				;eax stores how much the present_line differs from lrc_array
					mov edi, lrc_addr[eax]
					mov ebx, lrc_time[eax]
						
					mov eax, present_line
					mov ebx, TYPE dword
					mul ebx				;eax stores how much the present_line differs from lrc_array
					sub eax, TYPE dword
					mov esi, lrc_addr[eax];former line address
					mov edx, edi			;line address
					sub edx, esi			;Bytes that we should print
					sub edx, 10				;[3,12.1]should not be printed
					invoke lstrcpyn, addr long_str, addr [esi+10], edx
					invoke SendDlgItemMessage, hWin, IDC_lyrics_next2, WM_SETTEXT, 0, addr long_str
					dec present_line
					dec present_line
					jmp dL_LEND
				.endif
				inc present_line
				mov edx, present_line
			.endw
		.endif
	.endif
	dL_LEND:
	Ret
show_lrc endp


;##################################################
; �򿪸���
;##################################################
open_song proc hWin:DWORD, index:DWORD
	invoke read_lrc_file, hWin, index	;get the lyric functionally
	mov eax, index
	mov ebx, TYPE song_menu
	mul ebx						;eax stores how much the present_line differs from lrc_array
	invoke wsprintf, ADDR mci_cmd, ADDR cmd_open, ADDR song_menu[eax].music_path
	invoke mciSendString, ADDR mci_cmd, NULL, 0, NULL
	Ret
open_song endp


;##################################################
; ��������Ű�ťʱ
;##################################################
handle_play_btn proc hWin:DWORD
	.if play_state == STOP_MUSIC	;����ǰΪֹͣ״̬
		mov play_state, PLAY_MUSIC	;תΪ����״̬
		invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_SETCURSEL, current_index, 0
		invoke open_song,hWin, current_index	;��ѡ������
		invoke mciSendString, ADDR cmd_play, NULL, 0, NULL	;��������
		invoke alter_volume,hWin	;��������

		;�޸�ͼ��
		mov eax, IMG_PAUSE
		invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
		invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax

		invoke mciSendString, addr cmd_getLen, addr current_len, 32, NULL	;��ȡ��ǰ���ֳ���
		invoke StrToInt, addr current_len
		invoke SendDlgItemMessage, hWin, IDC_time_slider, TBM_SETRANGEMAX, 0, eax	;�޸Ľ���������
		
		;��������ʱ����ʽ
		invoke StrToInt, addr current_len
		mov edx, 0
		div scale_second
	
		mov edx, 0
		div scale_minute
		mov current_len_minute, eax
		mov current_len_second, edx

	.elseif play_state == PLAY_MUSIC	;��ǰΪ����״̬
		mov play_state, PAUSE_MUSIC		;תΪ��ͣ״̬
		invoke mciSendString, ADDR cmd_pause, NULL, 0, NULL	;��ͣ����
		
		;�޸�ͼ��
		mov eax, IMG_START
		invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
		invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax

	.elseif play_state == PAUSE_MUSIC	;��ǰΪ��ͣ״̬
		mov play_state, PLAY_MUSIC		;תΪ����״̬
		invoke mciSendString, ADDR cmd_resume, NULL, 0, NULL ;�ָ�����

		;�޸�ͼ��
		mov eax, IMG_PAUSE
		invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
		invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax
	.endif
	Ret
handle_play_btn endp

;##################################################
; �ı䲥�Ÿ���
;##################################################
alter_song proc hWin:DWORD, newSongIndex: DWORD
	.if play_state != STOP_MUSIC
		invoke mciSendString, ADDR cmd_close, NULL, 0, NULL
	.endif

	mov eax, newSongIndex
	mov current_index, eax  ;���µ�ǰindex
	invoke open_song,hWin, current_index	;���µĸ���
	.if play_state == PLAY_MUSIC
		invoke mciSendString, ADDR cmd_play, NULL, 0, NULL;���Ÿ���
	.endif
	invoke alter_volume,hWin	;��������
	
	;���ý�����
	invoke mciSendString, addr cmd_getLen, addr current_len, 32, NULL
	invoke StrToInt, addr current_len
	invoke SendDlgItemMessage, hWin, IDC_time_slider, TBM_SETRANGEMAX, 0, eax
	
	;���ø���ʱ����ʽ
	invoke StrToInt, addr current_len
	mov edx, 0
	div scale_second
	
	mov edx, 0
	div scale_minute
	mov current_len_minute, eax
	mov current_len_second, edx
	Ret
alter_song endp

;##################################################
; �����б���Ӹ���
;##################################################
handle_add_btn proc uses eax ebx esi edi hWin:DWORD
	LOCAL len: DWORD	
	LOCAL cur_size: DWORD
	LOCAL cur_offset: DWORD
	LOCAL origin_offset: DWORD

	mov al,0
	mov edi, OFFSET open_file_dlg
	mov ecx, SIZEOF open_file_dlg
	cld
	rep stosb
	mov open_file_dlg.lStructSize, SIZEOF open_file_dlg
	mov eax, hWin
	mov open_file_dlg.hwndOwner, eax
	mov eax, OFN_ALLOWMULTISELECT
	or eax, OFN_EXPLORER
	mov open_file_dlg.Flags, eax
	mov open_file_dlg.nMaxFile, dlg_nmax_file
	mov open_file_dlg.lpstrTitle, OFFSET dlg_title
	mov open_file_dlg.lpstrInitialDir, OFFSET dlg_init_dir
	mov open_file_dlg.lpstrFile, OFFSET dlg_open_file_names
	invoke GetOpenFileName, ADDR open_file_dlg
	.IF eax == 1
		invoke lstrcpyn, ADDR dlg_path, ADDR dlg_open_file_names, open_file_dlg.nFileOffset
		invoke lstrlen, ADDR dlg_path
		mov len, eax
		mov ebx, eax
		mov al, dlg_path[ebx]
		.IF al != sep
			mov al, sep
			mov dlg_path[ebx], al
			mov dlg_path[ebx + 1], 0
		.ENDIF
		mov ebx, song_menu_size
		mov cur_size, ebx
		mov edi, OFFSET song_menu
		mov eax, SIZEOF Song
		mul ebx
		add edi, eax
		mov cur_offset, edi
		mov origin_offset, edi
		mov esi, OFFSET dlg_open_file_names
		mov eax, 0
		mov ax, open_file_dlg.nFileOffset
		add esi, eax
		mov al, [esi]
		.WHILE al != 0
			mov dlg_file_name, 0
			invoke lstrcat, ADDR dlg_file_name, ADDR dlg_path
			invoke lstrcat, ADDR dlg_file_name, esi
			mov edi, cur_offset
			add cur_offset, SIZEOF Song
			invoke lstrcpy, edi, esi
			add edi, 100
			invoke lstrcpy, edi, ADDR dlg_file_name
			invoke lstrlen, esi
			inc eax
			add esi, eax
			add song_menu_size, 1
			mov al, [esi]
		.ENDW
		mov esi, origin_offset
		mov ecx, song_menu_size
		sub ecx, cur_size
		.IF ecx > 0
			L1:
				push ecx
				invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_ADDSTRING, 0, ADDR (Song PTR [esi]).music_name
				add esi, TYPE song_menu
				pop ecx
			loop L1
		.ENDIF
	.ENDIF
	ret
handle_add_btn endp


;##################################################
; ɾ�������б���ѡ�е�����
;##################################################
handle_dele_btn proc hWin: DWORD
	invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_GETCURSEL, 0, 0	;��ȡ��ѡ�е��±�
	.if eax == -1
		invoke MessageBox, hWin, ADDR dlg_warning, ADDR dlg_warning_title, MB_OK
	.else
		push eax
		invoke SendDlgItemMessage, hWin, IDC_song_menu, LB_DELETESTRING, eax, 0
		pop eax
		mov ebx, eax
		add ebx, 1
		mov edi, OFFSET song_menu
		mov edx, SIZEOF Song
		mul edx
		add edi, eax
		mov esi, edi
		add esi, SIZEOF Song
		.while ebx < song_menu_size
			mov ecx, SIZEOF Song
			cld
			rep movsb
			add ebx, 1
		.endw
		sub song_menu_size, 1
	.ENDIF
	ret
handle_dele_btn endp

;##################################################
; �ı�����
;##################################################
alter_volume proc hWin:	DWORD
	invoke SendDlgItemMessage,hWin,IDC_vol_slider,TBM_GETPOS,0,0	;��ȡ��ǰSliderλ��
	.if have_sound == 1
		invoke wsprintf, addr mci_cmd, addr cmd_setVol, eax
	.else
		invoke wsprintf, addr mci_cmd, addr cmd_setVol, 0
	.endif
	invoke mciSendString, addr mci_cmd, NULL, 0, NULL
	Ret
alter_volume endp


;##################################################
; �л��Ƿ�Ϊ������״̬
;##################################################
handle_silence_btn proc hWin: DWORD
	.if have_sound == 1
		mov have_sound, 0
		mov eax, IMG_CLOSE_SOUND
	.else
		mov have_sound,1
		mov eax, IMG_OPEN_SOUND
	.endif
	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
	invoke SendDlgItemMessage,hWin,IDC_silence_btn, BM_SETIMAGE, IMAGE_ICON, eax;�޸İ�ť
	invoke alter_volume,hWin
	Ret
handle_silence_btn endp

;##################################################
; �ı�������ʾ����ֵ
;##################################################
show_volume proc hWin: DWORD
	local tmp: DWORD
	invoke SendDlgItemMessage,hWin,IDC_vol_slider,TBM_GETPOS,0,0;��ȡ��ǰSlider�α�λ��
	;����������ʾ����
	mov tmp, 10
	mov edx, 0
	div tmp
	invoke wsprintf, addr mci_cmd, addr int_fmt, eax
	invoke SendDlgItemMessage, hWin, IDC_vol_txt, WM_SETTEXT, 0, addr mci_cmd
	Ret
show_volume endp

;##################################################
; ���ݲ��Ž���ˢ�½������Ͳ���ʱ��
;##################################################
handle_time_slider proc hWin: DWORD
	local cur_pos: DWORD
	.if play_state == PLAY_MUSIC	;����״̬
		invoke mciSendString, addr cmd_getPos, addr current_pos, 32, NULL	;��ȡ����λ��
		invoke StrToInt, addr current_pos
		mov cur_pos, eax
		.if dragging == 0	;�ſ���ק������
			invoke SendDlgItemMessage, hWin, IDC_time_slider, TBM_SETPOS, 1, cur_pos
		.endif

		;ˢ��ʱ����ʾ
		mov eax, cur_pos
		mov edx, 0
		div scale_second
	
		mov edx, 0
		div scale_minute
		mov current_pos_minute, eax
		mov current_pos_second, edx
		invoke wsprintf, addr mci_cmd, addr time_fmt, current_pos_minute, current_pos_second, current_len_minute, current_len_second
		invoke SendDlgItemMessage, hWin, IDC_time_txt, WM_SETTEXT, 0, addr mci_cmd;�޸����� 

	.endif
	Ret
handle_time_slider endp


;##################################################
;�޸Ĳ���ʱ��
;##################################################
alter_time proc hWin: DWORD
	invoke SendDlgItemMessage,hWin,IDC_time_slider,TBM_GETPOS,0,0	;��ȡ��ǰSliderλ��
	invoke wsprintf, addr mci_cmd, addr cmd_setPos, eax
	invoke mciSendString, addr mci_cmd, NULL, 0, NULL
	.if play_state == PLAY_MUSIC
		invoke mciSendString, addr cmd_play, NULL, 0, NULL
	.elseif play_state == PAUSE_MUSIC
		invoke mciSendString, addr cmd_play, NULL, 0, NULL
		mov play_state, PLAY_MUSIC
		mov eax, IMG_PAUSE
		invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
		invoke SendDlgItemMessage,hWin,IDC_paly_btn, BM_SETIMAGE, IMAGE_ICON, eax
	.endif
	Ret
alter_time endp


;##################################################
; �л�ѭ��״̬
;##################################################
handle_recycle_btn proc hWin: DWORD
	.if repeat_mode == SINGLE_REPEAT
		mov repeat_mode, LIST_REPEAT
		mov eax, IMG_RECYCLE
	.elseif repeat_mode == LIST_REPEAT
		mov repeat_mode,RANDOM_REPEAT
		mov eax, IMG_RANDOM
	.elseif repeat_mode == RANDOM_REPEAT
		mov repeat_mode,SINGLE_REPEAT
		mov eax, IMG_SINGLE
	.endif
	invoke LoadImage, hInstance, eax,IMAGE_ICON,32,32,NULL
	invoke SendDlgItemMessage,hWin,IDC_recycle_btn, BM_SETIMAGE, IMAGE_ICON, eax;�޸İ�ť
	Ret
handle_recycle_btn endp


;##################################################
; ���Ž��������ѭ��ģʽ������һ�׸���л�
;##################################################
switch_next_song proc hWin: DWORD
	local temp: DWORD
	invoke StrToInt, addr current_len
	mov temp, eax
	invoke StrToInt, addr current_pos
	.if eax >= temp	;��������
		.if repeat_mode == SINGLE_REPEAT
			invoke mciSendString, addr cmd_setStart, NULL, 0, NULL
			invoke mciSendString, addr cmd_play, NULL, 0, NULL
		.elseif repeat_mode == LIST_REPEAT
			invoke SendMessage, hWin, WM_COMMAND, IDC_next_btn, 0;
		.elseif repeat_mode == RANDOM_REPEAT
			invoke SendMessage, hWin, WM_COMMAND, IDC_next_btn, 0
		.endif
	.endif
	Ret
switch_next_song endp
end start
