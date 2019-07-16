;; This file is a part of the IncludeOS unikernel - www.includeos.org
;;
;; Copyright 2018 IncludeOS AS, Oslo, Norway
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http:;;www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

global __syscall_entry:function
global __clone_helper:function
global __clone_return:function
extern syscall_entry

;; x86_64 / System V ABI calling convention
%define arg1 rdi
%define arg2 rsi
%define arg3 rdx
%define arg4 rcx
%define arg5 r8
%define arg6 r9

%macro PUSHAQ 0
   ;;push rax
   push rcx
   push rdx
   push rdi
   push rsi
   push r8
   push r9
   push r10
   push r11
%endmacro
%macro POPAQ 0
   pop r11
   pop r10
   pop r9
   pop r8
   pop rsi
   pop rdi
   pop rdx
   pop rcx
   ;;pop rax
%endmacro


SECTION .text
__syscall_entry:
    ;; clone syscall
    cmp rax, 56
    je __clone_helper

    ;; store return address
    push rcx
    ;;  Convert back from syscall conventions
    ;;  Last param on stack movq 8(rsp),r9
    mov r9, r8
    mov r8, r10
    mov rcx, rdx
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, rax
    call syscall_entry
    ;; return to rcx
    pop rcx
    jmp QWORD rcx

__clone_helper:
    PUSHAQ

    push rsp ;; alignment
    ;; R9: thread callback
    push r9
    ;; RSP: old stack
    push rsp

    mov r11, rcx
    ;; R9:  TLS data
    mov r9, r8
    ;; R8:  void* ctid
    mov r8, r10
    ;; RCX: void* ptid
    mov rcx, rdx
    ;; RDX: void* stack
    mov rdx, rsi
    ;; RSI: unsigned long flags
    mov rsi, rdi
    ;; RDI: next instruction
    mov rdi, r11

    ;; call clone so that kernel can create the thread data
    extern syscall_clone
    call syscall_clone
    ;; remove old rsp
    add rsp, 0x18
    ;; return value preserved
    POPAQ
    PUSHAQ
    push rbp
    push rax ;; store thread id

    ;; switch stack
    mov rsp, rsi
    ;; zero return value
    xor rax, rax
    ;; return back
    jmp QWORD rcx

__clone_return:
    mov rbx, rdi
    mov rsp, rsi

    pop rax ;; restore thread id
    pop rbp
    POPAQ
    ;;
    jmp QWORD rbx
