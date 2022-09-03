	.global _start
	
	.extern wl_display_connect, wl_display_disconnect, wl_display_roundtrip
	.extern wl_proxy_marshal_constructor, wl_proxy_add_listener
	.extern wl_registry_interface


	.text

_start:
	# Pirnt intro message
	mov     $intro_msg, %rdi
	mov     $17,        %rsi
	call    print
	
	# rax = wl_display_connect(NULL)
	xor     %rdi, %rdi         # Set the null argument
	call    wl_display_connect # Call the C function to connect to the wayland display

	cmp     $0, %rax # Check if the function returned null
	je      error    # Error out if it is null

	pushq   %rax # Push RAX to the stack to save it for other operations

	# Print the connection message
	mov     $conne_msg, %rdi
	mov     $26,        %rsi
	call    print

	# rax = wl_display_get_registry(display)
	mov     $1,                     %rsi # Use opcode 1 for GET_REGISTRY
	mov     $wl_registry_interface, %rdx # Supply the interface to get the registry
	xor     %rcx,                   %rcx # Supply null for the final argument
	mov     (%rsp),                 %rdi # The last thing on the stack is the display pointer
	pushq   %rbp                         # Push the stack base pointer
	movq    %rsp,                   %rbp # Set the base pointer to the head of the stack
	call    wl_proxy_marshal_constructor
	movq    %rbp,                   %rsp # Reset the stack pointer to the old stack head
	pop     %rbp                         # Set the original base pointer
	
	cmp     $0, %rax # Check if the function returned null
	je      error    # Error out if it is null
	
	mov     %rax,         %rdi # Move the return value from the last function to the first argument
	mov     $reg_listner, %rsi # Register listner
	xor     %rdx,         %rdx # Set null for the data argument
	call wl_proxy_add_listener

	mov     (%rsp),                 %rdi # The last thing on the stack is the display pointer
	pushq   %rbp                         # Push the stack base pointer
	movq    %rsp,                   %rbp # Set the base pointer to the head of the stack
	call    wl_display_roundtrip         # Show the initial set of global things
	movq    %rbp,                   %rsp # Reset the stack pointer to the old stack head
	pop     %rbp                         # Set the original base pointer
	
	# wl_display_disconnect(display)
	popq    %rdi
	call    wl_display_disconnect # Call the C function to connect to the wayland display

	# Print the disconnection message
	mov     $disco_msg, %rdi
	mov     $31,        %rsi
	call    print

	jmp exit                      # Exit without the error message


error:
	# Print the error message
	mov     $error_msg, %rdi
	mov     $31,        %rsi
	call    print

exit:
	mov     $60,        %rax      # Syscall number for exit is 60
	xor     %rdi,       %rdi      # Return with code 0
	syscall

print:
	# Print a message stored in a pointer at rdi and a length in rbp
	mov     $1,         %rax
	mov     %rsi,       %rdx
	mov     %rdi,       %rsi
	mov     $1,         %rdi
	syscall
	
	ret

len:
	xor     %rax, %rax            # Clear rax to store the length
len_loop:
	inc     %rax                  # Increase the length stored in rax
	cmpb    $0,   (%rdi, %rax, 1) # Check if the symbol is a null byte
	jne     len_loop              # If it is not null keep looping
	ret

strcmp:
	call    len                     
	dec     %rax                   # Ignore the null byte
cmp_loop:
	mov     (%rsi, %rax, 1), %r10  # Move the offset data to the r10 register
	cmpb    %r10b, (%rdi, %rax, 1) # Check if the symbol is a null byte
	jne     cmp_ret                # If the length is not equal return with rax > 0
	dec     %rax                   # Decement the number of chars to be checked
	cmp     $0,   %rax             # Check if all characters have been checked
	jne     cmp_loop               # If they haven't then loop again
cmp_ret:
	ret

join_registry_handler:
	mov     %rcx,     %rdi    # Move the current string into rdi
	mov     $comp_if, %rsi    # Move the string to be compared to rsi
	call    strcmp
	cmp     $0,       %rax    # Check if the string was found
	jne     join_ret
	mov     $intro_msg, %rdi
	mov     $17,        %rsi
	call    print
join_ret:
	ret

remove_registry_handler:
	ret

comp_if:
	.ascii "wl_compositor"
shm_if:
	.ascii "wl_shm"
shell_if:
	.ascii "wl_shell"

intro_msg:
	.ascii "Testing wayland:\n"

error_msg:
	.ascii "Cannot connect to the display!\n"

conne_msg:
	.ascii "Connected to the display.\n"

disco_msg:
	.ascii "Disconnected from the display.\n"

newline:
	.ascii "\n"

reg_listner:
	.quad join_registry_handler
	.quad remove_registry_handler
