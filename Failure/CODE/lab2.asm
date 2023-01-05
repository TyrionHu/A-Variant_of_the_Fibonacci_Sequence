        .ORIG   X3000

START   AND R0, R0, #0
        AND R1, R1, #0
        AND R2, R2, #0
        AND R3, R3, #0
        AND R4, R4, #0
        AND R5, R5, #0
        AND R6, R6, #0
        AND R7, R7, #0
        
        LD R0, STOREP
        STI R0, STOREX3100      ;STORE P IN MEM[X3100]
                
        LD R0, STOREQ
        STI R0, STOREX3101      ;STORE Q IN MEM[X3101]
                
        LD R0, STOREN
        STI R0, STOREX3102      ;STORE N IN MEM[X3102]
                
        STI R0, STOREX3103      ;THE RESULT WILL BE SAVED HERE
        
;START TO CALCULATE
        LDI R0, STOREX3102
        LD  R6, STOREX4000
        JSR VFS
        STI R1, STOREX3103
        HALT
;VFS(Variant of Fibonacci Sequence) subroutine
;VFS(0) = 1
;VFS(1) = 1
;VFS(N) = VFS(N - 2) % p + VFS(N - 1)  % q
;
;Input: R0(N)
;R2, R3, R4, R5 will be used 
;Return answer in R1
VFS     ADD R6, R6, #-1 ;
        STR R7, R6, #0  ;PUSH R7, THE RETURN LINKAGE
        ADD R6, R6, #-1 ;
        STR R0, R6, #0  ;PUSH R0, THE VALUE OF N
        ADD R6, R6, #-1 ;
        STR R2, R6, #0  ;PUSH R2, WHICH IS NEEDED IN THE SUBROUTINE
        ADD R6, R6, #-1 ;
        STR R3, R6, #0  ;PUSH R3, WHICH IS NEEDED IN THE SUBROUTINE
        ADD R6, R6, #-1 ;
        STR R4, R6, #0  ;PUSH R4, WHICH IS NEEDED IN THE SUBROUTINE
        ADD R6, R6, #-1 ;
        STR R5, R6, #0  ;PUSH R5, WHICH IS NEEDED IN THE SUBROUTINE
        
        AND R2, R2, #0
        AND R3, R3, #0
        AND R4, R4, #0
        AND R5, R5, #0
;CHECK IF ITS THE BASE CASE
        ADD R2, R0, #-1     ;CHECK N - 1
        BRp SKIP1           ;RESULT IS 1 IF R2 = -1 OR 0
        AND R1, R1, #0  
        ADD R1, R1, #1      ;R1 IS 1
        BRnzp   DONE1
        
;ITS NOT A BASE CASE, AND THE RECURSION NEEDS TO BE DONE
SKIP1   ADD R0, R0, #-1
        JSR VFS          ;R1 = VFS(N - 1)
        ADD R2, R1, #0   ;MOVE RESULT BEFORE CALLING VFS AGAIN, R2 = VFS(N - 1)
        ADD R0, R0, #-1
        JSR VFS          ;R1 = VFS(N - 2)
       
        ADD R4, R2, #0      ;R4 = VFS(N - 1)
        LDI R5, STOREX3101  ;R5 = q
        JSR MOD
        ADD R2, R3, #0      ; R2 = VFS(N - 1)  % q
       
        ADD R4, R1, #0              ;R4 = VFS(N - 2)
        LDI R5, STOREX3100          ;R5 = p
        JSR MOD
        ADD R1, R3, #0   ; R1 = VFS(N - 2)  % P 
       
        ADD R1, R1, R2   ;R1 = VFS(N) = FS(N - 2) % p + VFS(N - 1)  % q
        BRnzp DONE1
        
;RESTORE REGISTERS AND RETURN
DONE1   LDR R5, R6, #0  ;RESTORE R5
        ADD R6, R6, #1
        LDR R4, R6, #0  ;RESTORE R4
        ADD R6, R6, #1
        LDR R3, R6, #0  ;RESTORE R3
        ADD R6, R6, #1
        LDR R2, R6, #0  ;RESTORE R2
        ADD R6, R6, #1
        LDR R0, R6, #0  ;RESTORE RO
        ADD R6, R6, #1
        LDR R7, R6, #0  ;RESTORE R7
        ADD R6, R6, #1
        RET
        
;MOD subroutine
;Instance: N % A
;Input: R4(N); R5(A)
;R1, R2 WILL BE USED IN THIS SUBROUTINE
;Return answer in R3
MOD     ADD R6, R6, #-1 ;
        STR R7, R6, #0  ;PUSH R7, THE RETURN LINKAGE
        ADD R6, R6, #-1 ;
        STR R1, R6, #0  ;PUSH R1, WHICH IS NEEDED IN THE SUBROUTINE
        ADD R6, R6, #-1 ;
        STR R2, R6, #0  ;PUSH R2, WHICH IS NEEDED IN THE SUBROUTINE
        
        AND R2, R2, #0  ;R2 IS THE COUNTER
        
        JSR SUB
        ADD R4, R4, #0
        
TEST2   BRn SKIP2
        ADD R2, R2, #1
        JSR SUB
        ADD R4, R4, #0
        BRnzp   TEST2

;THE CONDITION OF THE LOOP IS SATISFIED    
SKIP2   ADD R3, R4, R5
        BRnzp DONE2
        
;ALL IS DONE
DONE2   LDR R2, R6, #0  ;RESTORE R2
        ADD R6, R6, #1
        LDR R1, R6, #0  ;RESTORE R1
        ADD R6, R6, #1
        LDR R7, R6, #0  ;RESTORE R7
        ADD R6, R6, #1
        RET

;SUB(SUBSTRACT) SUBROUTINE
;A - B
;INPUT: R4(A); R5(B)
;R3 IS NEEDED IN THIS SUBROUTINE
;RETURN ANSWER IN R4
SUB     ADD R6, R6, #-1 ;
        STR R7, R6, #0  ;PUSH R7, THE RETURN LINKAGE
        ADD R6, R6, #-1 ;
        STR R3, R6, #0  ;PUSH R3, WHICH IS NEEDED IN THE SUBROUTINE
        
        NOT R3, R5
        ADD R3, R3, #1  ;R3 = - R5
        
        ADD R4, R4, R3  ;R4 = R4 - R5
        
        BRnzp   DONE3
        
        
DONE3   LDR R3, R6, #0  ;RESTORE R3
        ADD R6, R6, #1
        LDR R7, R6, #0  ;RESTORE R7
        ADD R6, R6, #1
        RET
        
        
;MAIN
;SET THE REGISTERS TO ZERO

        TRAP    x25
        
STOREX3100      .FILL   X3100
STOREX3101      .FILL   X3101
STOREX3102      .FILL   X3102
STOREX3103      .FILL   X3103
STOREX4000      .FILL   X4000
;SAVEX3103      
STOREP          .FILL   X0004
STOREQ          .FILL   X000A
STOREN          .FILL   X000F

                .END