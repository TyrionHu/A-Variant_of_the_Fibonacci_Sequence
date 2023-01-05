# Lab02 A Variant of the Fibonacci Sequence

## Category

[toc]

## Task & Purpose

Calculate a variant of the Fibonacci sequence:
$$
F(0)=F(1)=1\\
F(N)=F(N-2)\%p+F(N-1)\%q \ \ (2≤N≤1024)\\
p=2^k\ (2≤k≤10),\ 10≤q≤1024
$$
Note that $p$ will be stored in $x3100$, $q$ will be stored in $x3101$ and $N$ will be stored in $x3102$.

My job: to store $F(N)$ in $x3103$.

R0-R7 are set to zeros at the beginning, and the program should start at $x3000$.

## Example

| $N$  | $p$  | $q$  | $F(N)$ |
| ---- | ---- | ---- | ------ |
| 100  | 256  | 123  | 146    |
| 200  | 512  | 456  | 818    |
| 300  | 1024 | 789  | 1219   |

## Requirements

1. The program should start with $.ORIG\ x3000$;
2. The Program should end with $.END$;
3. The last instruction should be $TRAP\ x25\ (HALT)$;
4. **Capitalized** keywords(as well as labels) are recommended(For instance, use "ADD" instead of "add", and use "NUMBER" instead of "number");
5. **Spaces** after **commas**(```ADD R0, R0, #1``` rather than ```ADD R0,R0,#1```);
6. **Decimal** constants starts with $\#$, **hexadecimal** with lowercase $x$;
7. Write comments when necessary. 

## Principle

My program includes 3 subroutines: VFS(Variant of Fibonacci Sequence), MOD, SUB.

The main program calls VFS, and VFS calls MOD, and MOD calls SUB.

1. VFS(Variant of Fibonacci Sequence) - the most functional subroutine in the program:

   First of all, initialize F0 = F1 = 1, which are the base value of the sequence;

   Then, see if the input N is 0 or 1, under which circumstance, the program will return 1;

   On the other hand, if N is larger than one, the program will enter a loop, and will not exit until N is equal to or less than 1. And in this loop, where are three steps:

   1. F = F0 % P + F1 % Q;
   2. F0 = F1;
   3. F1 = F;

   In the first step, the subroutine MOD will be called. 

2. MOD is just a '%' in C language. However in the LC-3 assembly language, it need a subroutine to complete its function. 

   Say we have do the calculation N % A, we just need to keep doing the operation N - A until N is a negative number, then we add A to N. 

3. SUB is a subtract operation, I use a subroutine to do it as it's a way to save a register. 

## Procedure

- The very first problem I encountered is how to save P or Q or N to a specific location in memory. And the solution is quite simple:
  1. Save all the addresses which will be used to save them and also their value, with the pseudo-operation .FILL;
  2. Load the values with LD;
  3. Save the values to the intened location with instruction STI;
- The biggest obstacle I encountered is however, the general approach to solve the problem: Resursion or Loop. And actually the first time, I write a program with the mindset of Resursion, which is legitimately, absolutely, and undoubtedly theoretically correct. However, when I tested the program with a set of relatively large 'N', it kept running, making me believe that there must be a dead loop it cannot exit successfully somewhere. And now I know that it just need 'more' time. 
- Meanwhile, I had some problems with the instruciton BR, because sometimes I forgot to put the right register before the instruction, resulting in it testing value that I did not expected.  

## Code in C

In this specific problem, I found it massively helpful to right the program first with my most skilled programming language - C, and I evenly found it much more useful than draw a flowchart which requires me to use another software and to spend much more time. 

```c++
int FibonacciVariant(int N, int P, int Q)
{
    int F = 0;
    int F0 = 1;
    int F1 = 1;
    if(N == 0 || N == 1)
    {
        return 1;
    }
    for(; N > 1; N--)
    {
        F = F0 % P + F1 % Q;
        F0 = F1;
        F1 = F;
    }
    return F;
}
```

## Code

```assembly
        .ORIG   X3000
;INITIALIZATION
        AND R0, R0, #0
        AND R1, R1, #0
        AND R2, R2, #0
        AND R3, R3, #0
        AND R4, R4, #0
        AND R5, R5, #0
        AND R6, R6, #0
        AND R7, R7, #0
        
        LD  R0, STOREP
        STI R0, STOREX3100      ;STORE P IN MEM[X3100]
        LD  R0, STOREQ
        STI R0, STOREX3101      ;STORE Q IN MEM[X3101]
        LD  R0, STOREN
        STI R0, STOREX3102      ;STORE N IN MEM[X3102]
        
        AND R0, R0, #0
        STI R0, STOREX3103      ;THE RESULT WILL BE SAVED HERE. FIRST FILL IT WITH A ZERO
        LDI R0, STOREX3102      ;R0 = N
        LD  R6, STOREX4000      ;R6 IS THE STACK POINTER

;START THE MAIN PROGRAM
        JSR VFS
        STI R1, STOREX3103      ;THE RESULT IS R1        
        HALT

;VFS(Variant of Fibonacci Sequence) subroutine
;VFS(0) = 1
;VFS(1) = 1
;VFS(N) = VFS(N - 2) % P + VFS(N - 1)  % Q
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
        
        AND R1, R1, #0      ;STORE F
        ADD R1, R1, #1      ;F = 1
        
        AND R2, R2, #0      ;STORE F0
        ADD R2, R2, #1      ;F0 = 1
        
        AND R3, R3, #0      ;STORE F1
        ADD R3, R3, #1      ;F1 = 1
        
        AND R4, R4, #0 
        AND R5, R5, #0  
        
TEST1   ADD R5, R0, #-1 
        BRNZ    DONE1       ;IF(N == 0 OR N == 1)
        
        ADD R4, R2, #0      ;R4 = F0
        LDI R5, STOREX3100  ;R5 = P
        JSR MOD             ;R4 = F0 % P
        ADD R1, R4, #0      ;R1 = F0 % P
        
        ADD R4, R3, #0      ;R4 = F1
        LDI R5, STOREX3101  ;R5 = Q
        JSR MOD             ;R4 = F1 % Q
        ADD R1, R1, R4      ;R1 = F0 % P + F1 % Q
        
        ADD R2, R3, #0      ;F0 <- F1
        ADD R3, R1, #0      ;F1 <- F
        ADD R0, R0 #-1      ;N--
        
        BRNZP   TEST1
        
;ITS THE BASE CASE WHEN N IS 0 OR 1        
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
;Return answer in R4
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
SKIP2   ADD R4, R4, R5
        BRnzp DONE2
        
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

STOREX3100      .FILL   X3100
STOREX3101      .FILL   X3101
STOREX3102      .FILL   X3102
STOREX3103      .FILL   X3103
STOREX4000      .FILL   X4000
STOREP          .FILL   X0400
STOREQ          .FILL   X0315
STOREN          .FILL   X012C
                .END
```

## Result

First off, all the given instances are tested and satisfied. 

My other tests, which is aligned with the outcome of the C program. 

| $N$  | $p$  | $q$  | $F(N)$ |
| ---- | ---- | ---- | ------ |
| 10   | 64   | 64   | 89     |
| 20   | 64   | 45   | 19     |
| 30   | 1024 | 78   | 457    |

## Answer the question

In my point of view, where the loop could be improved is the operation F0 % p. 

Say $P = 2^k$, then F0 % p represented in binary form is F0[k-1:0],which can be achieved by mask layer. 

## P.S.

The source code of the resursion method:

```assembly
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
```

