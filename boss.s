.3ds

.open "code.bin", "build/patched_code.bin", 0x100000

.arm

;;;
; Generic SpotPass Redirection Engine
;;;

snprintf equ 0x124b24 
strncmp  equ 0x125148 
strncpy  equ 0x126C08 
strlen   equ 0x12775c 
memclr   equ 0x126ef0 

URLBufferSizePtr equ 0x10B208
sub_10C104 equ 0x10C104
BOSS_MakeHTTPRequest equ 0x122A2C

BOSS_ConvertAakamaitoNPDL_FirstEnding equ 0x10B1F2
BOSS_ConvertAakamaitoNPDL_SecondEnding equ 0x10B1FE

.thumb
.org BOSS_ConvertAakamaitoNPDL_FirstEnding
.area 0x4
  bl ConvertAakamaitoNPDL_NewFirstEnding
.endarea

.org BOSS_ConvertAakamaitoNPDL_SecondEnding
.area 0x4
  bl ConvertAakamaitoNPDL_NewSecondEnding
.endarea

.arm
.org 0x11E0E4
.area 0x40
ConvertAakamaitoNPDL_NewFirstEnding:
  push {r0-r8, lr}
  bl sub_10C104
  bl PatchSpotpassUrl
.endarea

.org 0x1225D0
.area 0x40
ConvertAakamaitoNPDL_NewSecondEnding:
  push {r0-r8, lr}
  blx strncpy
  bl PatchSpotpassUrl
.endarea

.org 0x10BBCC
.area 0x50
PatchSpotpassUrl:
  ldr r6, [URLBufferSizePtrPtr]
  ldr r6, [r6]

  mov r1, r6
  add r1, r1, #0x18

  rsb r0, r1, #0
  add sp, r0

  add r0, sp, #0
  blx memclr

  bl PatchSpotpassUrl_cont1

.align 4
URLBufferSizePtrPtr:
  .word URLBufferSizePtr
.endarea

.org 0x12981C
.area 0x60
PatchSpotpassUrl_cont1:
  mov r4, #0

  ldrb r1, [r7, r4]
  cmp r1, #0
  beq PatchSpotpassUrl_FindEndProtocolLoop_ExitNoProtocol

  b PatchSpotpassUrl_FindEndProtocolLoop_DoLoop

PatchSpotpassUrl_FindEndProtocolLoop_NextIteration:
  add r4, r4, #1
  cmp r4, r6
  bge PatchSpotpassUrl_SkipPatch_Redirect1

PatchSpotpassUrl_FindEndProtocolLoop_DoLoop:
  add r1, r7, r4
  ldrb r1, [r1, #1]

  cmp r1, #'/'
  beq PatchSpotpassUrl_FindEndProtocolLoop_NextIsSlash

  cmp r1, #0
  beq PatchSpotpassUrl_FindEndProtocolLoop_ExitNoProtocol

  b PatchSpotpassUrl_FindEndProtocolLoop_NextIteration

PatchSpotpassUrl_FindEndProtocolLoop_NextIsSlash:
  ldrb r1, [r7, r4]
  cmp r1, #'/'
  bne PatchSpotpassUrl_FindEndProtocolLoop_NextIteration

  add r1, r4, #2

PatchSpotpassUrl_FindEndProtocolLoop_ExitNoProtocol:
PatchSpotpassUrl_FindEndProtocolLoop_ExitEndLoop:
  bl PatchSpotpassUrl_cont2

PatchSpotpassUrl_SkipPatch_Redirect1:
  bl PatchSpotpassUrl_SkipPatch
.endarea

.org 0x12F0A0
.area 0x40
PatchSpotpassUrl_cont2:
  mov r4, r1

  ldr r5, [spotpassUrlRewritePtr]
  
  b PatchSpotpassUrl_LoopEntry
PatchSpotpassUrl_LoopContinue:
  add r5, r5, #7
  add r5, r5, #5

PatchSpotpassUrl_LoopEntry:
  ldr r0, [r5, #0x0]
  cmp r0, #0

  bl PatchSpotpassUrl_cont3
.align 4
spotpassUrlRewritePtr:
  .word spotpassUrlRewrite
.endarea

.org 0x113694
.area 0x50
PatchSpotpassUrl_cont3:
  beq PatchSpotpassUrl_SkipPatch_Redirect2
  blx strlen
  
  mov r8, r0
  mov r2, r0
  add r0, r7, r4
  ldr r1, [r5, #0x0]
  blx strncmp
  cmp r0, #0
  bne PatchSpotpassUrl_LoopContinue_Redirect1

  bl PatchSpotpassUrl_cont4
PatchSpotpassUrl_SkipPatch_Redirect2:
  bl PatchSpotpassUrl_SkipPatch
PatchSpotpassUrl_LoopContinue_Redirect1:
  bl PatchSpotpassUrl_LoopContinue
.endarea

.org 0x113818
.area 0x50
PatchSpotpassUrl_cont4:
  mov r0, r8
  add r0, r0, r4
PatchSpotpassUrl_FindEndSubdomainLoop_Continue:
  add r0, r0, #1
  ldrb r1, [r7, r0]
  cmp r1, #0
  beq PatchSpotpassUrl_LoopContinue_Redirect2
  cmp r1, #'/'
  beq PatchSpotpassUrl_LoopContinue_Redirect2
  cmp r1, #'.'
  bne PatchSpotpassUrl_FindEndSubdomainLoop_Continue
  add r0, r0, #1

  mov r8, r0
  add r1, r7, r4
  sub r2, r0, r4
  add r0, sp, #8
  bl PatchSpotpassUrl_cont5
PatchSpotpassUrl_LoopContinue_Redirect2:
  bl PatchSpotpassUrl_LoopContinue
.endarea

.org 0x1138D8
.area 0x60
PatchSpotpassUrl_cont5:
  blx strncpy
  ldr r0, [r5, #0x4]
  blx strlen

  mov r2, r0
  ldr r1, [r5, #0x4]
  mov r3, r8
  add r0, r3, r7
  
  add r3, r3, r2
  mov r8, r3
  
  blx strncmp
  cmp r0, #0
  bne PatchSpotpassUrl_LoopContinue_Redirect2

  mov r3, r8
  add r0, sp, #0x18
  add r1, r7, r3
  mov r2, r6
  blx strncpy

  bl PatchSpotpassUrl_cont6
.endarea

.org 0x111878
.area 0x50
PatchSpotpassUrl_cont6:
  mov r0, r7
  mov r1, r6
  ldr r2, [newSpotpassUrlPatternPtr]
  ldr r3, [r5, #0x8]
  add r4, sp, #8
  str r4, [sp, #0]
  add r4, sp, #0x18
  str r4, [sp, #4]
  bl snprintf
PatchSpotpassUrl_SkipPatch:
  add sp, r6
  add sp, #0x18
  pop {r0-r8, pc}
.align 4
newSpotpassUrlPatternPtr:
  .word newSpotpassUrlPattern
.endarea

;;;
; Read-only Data (Generic Domain Mapping)
;;;

.org 0x148a7c
.area 0x300
.align 4
spotpassUrlRewrite:
  .word spotpassGeneralPrefix
  .word spotpassGeneralUrl
  .word spotpassGeneralPath
  
  .word 0
  
  .word spotpassVideoPrefix
  .word spotpassVideoUrl
  .word spotpassVideoPath

  .word 0

spotpassGeneralPrefix:
  .asciiz "np"
spotpassGeneralUrl:
  .asciiz "cdn.nintendowifi.net"
spotpassGeneralPath:
  .asciiz "/"
spotpassVideoPrefix:
  .asciiz "pubtv"
spotpassVideoUrl:
  .asciiz "est.c.app.nintendowifi.net"
spotpassVideoPath:
  .asciiz "/v/"

  .align 4
newSpotpassUrlPattern:
  .asciiz "https://video.mariocube.com%s%s%s"
  .align 4
.endarea

;;;
; /CHECK Endpoint Overrides
;;;
.org 0x159160
.asciiz "https://video.mariocube.com/%s%s-d%s/%d/%d/%d/CHECK"

.org 0x1591B0
.asciiz "https://video.mariocube.com/%s%s-t%s/%d/%d/%d/CHECK"

.org 0x159200
.asciiz "https://video.mariocube.com/%s%s-p%s/%d/%d/%d/CHECK"

.close