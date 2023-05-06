@ Filename: VendingMachine.s
@ Author:   Noirmiles
@ Purpose:  This program simulates a one-day operation of a simple teller machine

@ Use these commands to assemble, link, run and debug this program:
@    as -o VendingMachine.o VendingMachine.s
@    gcc -o VendingMachine VendingMachine.o
@    ./VendingMachine 
@    gdb --args ./VendingMachine @lets you use debugger


@SECRET ADMIN INVENTORY CODE: h 

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

	@these are used to represent the inventory
	mov r4, #2  @Gum Inv
	mov r5, #2  @Peanuts Inv
	mov r6, #2  @Cheese Crackers Inv
	mov r7, #2  @M&Ms Inv
	
	MOV r8, #0 @Session Counter
	
startloop:
	adds r8, r8, #1   @Increments the session counter
	bne checkGInv


@----             @Checks each items inventory before proceeding
checkGInv:        @If all inventory is OUT OF STOCK, end program                
	cmp r4, #0    @Else, begins the normal procedure
	beq checkPInv
	bne loop

checkPInv:
	cmp r5, #0
	beq checkCInv
	bne loop


checkCInv:
	cmp r6, #0
	beq checkMInv
	bne loop
	
checkMInv:
	cmp r7, #0
	beq emptyLeave
	bne loop
	
emptyLeave:
	ldr r0, =Empty_msg
	bl printf
	b myexit
	
@----

loop:   @Main loop

	ldr r0, =clear_command  @Clears the terminal       
	bl system
	
	              
	ldr r0, =Session_Counter @Session Counter Print
	mov r1, r8
	bl printf
	
	ldr r0, =strIntroMessage @printing out the intro message
	bl printf
	
	MOV r9, #0 @Inserted Money count
	mov r3, #0

	
	ldr r0, =prompt1    @prints initial prompt
	bl printf

	ldr r0, =select_item_prompt @printing out selection prompt
	bl printf

	ldr r0, =charInputPattern   @Setup to read in one number
	ldr r1, =charInput	   @load r1 with the addsress of where the input will be stores
	
	mov r3, #0
	bl  scanf                @ scan the keyboard.
   	cmp r0, #READERROR       @ Check for a read error.
  	beq error               @ If there was a read error go handle it. 
   	ldr r1, =charInput        @ Have to reload r1 because it gets wiped out. 
	ldr r3, [r1] 
	push {r3}
	
    @ Compares the entry to the selection list, enters subsroutine
	cmp r3, #'g'
	beq gum
	cmp r3, #'p'
	beq peanuts
	cmp r3, #'c'
	beq crackers
	cmp r3, #'m'
	beq mnm
	cmp r3, #'x'
	beq myexit
	cmp r3, #'h'     @secret code to enter inventory page
	beq admin_menu
	b error	

admin_menu:
	ldr r0, =clear_command      @Lists the inventory for each item
	bl system 
	
	ldr r0, =inventoryStart
	bl printf
	
	ldr r0, =gumInventory
	mov r1, r4
	bl printf
	
	ldr r0, =peanutInventory
	mov r1, r5
	bl printf
	
	ldr r0, =crackersInventory
	mov r1, r6
	bl printf
	
	ldr r0, =mnmsInventory
	mov r1, r7
	bl printf
	
	
	ldr r0, =charInputPattern  @waits until enter key is pressed to move on.
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	b loop 
	
empty:
	ldr r0, =Empty_msg       @Prints "OUT OF STOCK" message when necessary
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf                         @waits until enter key is pressed to move on
	
	b loop

@Gum Section----------------------------------------	
		
gum:
	ldr r0, =clear_command             @clears terminal
	bl system 
	
	cmp r4, #0                     @checks gum inventory
	beq	empty
	
	ldr r0, =confirmation_promptG  @Confirmation prompt for gum
	pop {r1}
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 
	
	ldr r1, =charInput   @compares to y or n, continues procedure.
	ldr r3, [r1]
	cmp r3, #'y'
	beq dispensingG
	cmp r3, #'n'
	beq loop
	b error 
	

	
dispensingGum:
	ldr r0, =dispensingItems      @substracts inserted coins from price
	subs r9,#50
	mov r1, r9
	bl printf
	subs r4, #1              @modifies inventory count
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	
	b startloop
	
	
dispensingG:
	ldr r0, =clear_command        @clears terminal
	bl system
	
	cmp r9, #50                    @checks if current entered coins is enough for purchase
	bge dispensingGum				@ends transaction
	
	ldr r0, =moneyG_notice         @displays current transaction information
	mov r1, r9
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 

	ldr r1, =charInput            @prompts for coin entry selection
	ldr r3, [r1]
	cmp r3, #'d'
	beq dimeInsertedG
	cmp r3, #'q'
	beq quarterInsertedG
	cmp r3, #'b'
	beq dollarInsertedG
	
	
	b error
	
	
dimeInsertedG: 				@performs math for coin inserted
	adds r9, #10
	b dispensingG
quarterInsertedG:
	adds r9, #25
	b dispensingG
dollarInsertedG:
	adds r9, #100
	b dispensingG
	
	
	
	
	
@PEANUT SECTION********************************   @Works the same as Gum routines.
peanuts:
	ldr r0, =clear_command
	bl system
	
	cmp r5, #0
	beq	empty
	
	ldr r0, =confirmation_promptP  @Confirmation prompt for gum
	pop {r1}
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 
	
	ldr r1, =charInput
	ldr r3, [r1]
	cmp r3, #'y'
	beq dispensingP
	cmp r3, #'n'
	beq loop
	
dispensingPeanuts:
	ldr r0, =dispensingItems
	subs r9,#55
	mov r1, r9
	bl printf
	subs r5, #1
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	
	b startloop
	
	
	
dispensingP:
	ldr r0, =clear_command
	bl system
	
	cmp r9, #50
	bge dispensingPeanuts
	
	ldr r0, =moneyP_notice
	mov r1, r9
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 

	ldr r1, =charInput
	ldr r3, [r1]
	cmp r3, #'d'
	beq dimeInsertedP
	cmp r3, #'q'
	beq quarterInsertedP
	cmp r3, #'b'
	beq dollarInsertedP
	
	
	b error
	
	
dimeInsertedP:
	adds r9, #10
	b dispensingP
quarterInsertedP:
	adds r9, #25
	b dispensingP
dollarInsertedP:
	adds r9, #100
	b dispensingP
	
@CRACKER SECTION********************************
crackers:
	ldr r0, =clear_command
	bl system
	
	cmp r6, #0
	beq	empty
	
	ldr r0, =confirmation_promptC  @Confirmation prompt for crackers
	pop {r1}
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 
	
	ldr r1, =charInput
	ldr r3, [r1]
	cmp r3, #'y'
	beq dispensingC
	cmp r3, #'n'
	beq loop
	b error
	
dispensingCrackers:
	ldr r0, =dispensingItems
	subs r9,#65
	mov r1, r9
	bl printf
	subs r6, #1
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	b startloop
	
	
	
dispensingC:
	ldr r0, =clear_command
	bl system
	
	cmp r9, #65
	bge dispensingCrackers
	
	ldr r0, =moneyC_notice
	mov r1, r9
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error

	ldr r1, =charInput
	ldr r3, [r1]
	cmp r3, #'d'
	beq dimeInsertedC
	cmp r3, #'q'
	beq quarterInsertedC
	cmp r3, #'b'
	beq dollarInsertedC
	
	
	b error
	
	
dimeInsertedC:
	adds r9, #10
	b dispensingC
quarterInsertedC:
	adds r9, #25
	b dispensingC
dollarInsertedC:
	adds r9, #100
	b dispensingC



@M&M SECTION********************************
mnm:
	ldr r0, =clear_command
	bl system
	
	cmp r7, #0
	beq	empty
	
	ldr r0, =confirmation_promptM  @Confirmation prompt for m&ms
	pop {r1}
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 
	
	ldr r1, =charInput
	ldr r3, [r1]
	cmp r3, #'y'
	beq dispensingM
	cmp r3, #'n'
	beq loop
	
dispensingMnMs:
	ldr r0, =dispensingItems
	subs r9,#100
	mov r1, r9
	bl printf
	subs r7, #1
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	b startloop
	
	
	
dispensingM:
	ldr r0, =clear_command
	bl system
	
	cmp r9, #100
	bge dispensingMnMs
	
	ldr r0, =moneyM_notice
	mov r1, r9
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf
	
	cmp r0, #READERROR       @ Check for a read error.
  	beq error 

	ldr r1, =charInput
	ldr r3, [r1]
	cmp r3, #'d'
	beq dimeInsertedM
	cmp r3, #'q'
	beq quarterInsertedM
	cmp r3, #'b'
	beq dollarInsertedM
	
	
	b error
	
	
dimeInsertedM:
	adds r9, #10
	b dispensingM
quarterInsertedM:
	adds r9, #25
	b dispensingM
dollarInsertedM:
	adds r9, #100
	b dispensingM











@*******************************
@********************
error:
@********************
	ldr r0, =clear_command       @Clears terminal
	bl system
	
	
	ldr r0, =invalid_input_msg        @Prints invalid inut message
	bl printf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	bl scanf
	
	ldr r0, =charInputPattern
	ldr r1, =charInput
	mov r2, #1
	bl scanf         @waits for enter key to be pressed
	
	b loop           @send system back to loop


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @SVC call to exit
   svc 0         @Make the system call. 



@-------------------------------------------------------
@OUTPUTS
.data

.balign 4
strIntroMessage: .asciz "\n-------------------\nWelcome to Zippy's Vending Machine! \n-------------------\n"

.balign 4
prompt1: .asciz "\nGum ($0.50)\nPeanuts ($0.55)\nCheese Crackers ($0.65)\nM&Ms ($1.00)\n\nGum (g), Peanuts (p), Cheese Crackers (c), M&Ms (m), or Exit (x)\n\n\n"

.balign 4
select_item_prompt: .asciz "\nPlease select an item: "
@******************************
@GUM SECTION
.balign 4
confirmation_promptG: .asciz "\n\nYou selected Gum (%c), is this correct (y/n): "

.balign 4
moneyG_notice: .asciz "\nDime (d), Quarter (q), Dollar Bill (b)\n-PRICE: 50¢\n-INSERTED: %d¢\n\nPlease insert coins: " 



@*****************************
@PEANUT SECTION
.balign 4
confirmation_promptP: .asciz "\n\nYou selected Peanuts (%c), is this correct (y/n): "

.balign 4
moneyP_notice: .asciz "\nDime (d), Quarter (q), Dollar Bill (b)\n-PRICE: 55¢\n-INSERTED: %d¢\n\nPlease insert coins: " 

@*****************************
@CHEESE CRACKERS SECTION
.balign 4
confirmation_promptC: .asciz "\n\nYou selected Cheese Crackers (%c), is this correct (y/n): "

.balign 4
moneyC_notice: .asciz "\nDime (d), Quarter (q), Dollar Bill (b)\n-PRICE: 65¢\n-INSERTED: %d¢\n\nPlease insert coins: " 

@*****************************
@M&Ms SECTION
.balign 4
confirmation_promptM: .asciz "\n\nYou selected M&Ms (%c), is this correct (y/n): "

.balign 4
moneyM_notice: .asciz "\nDime (d), Quarter (q), Dollar Bill (b)\n-PRICE: 100¢\n-INSERTED: %d¢\n\nPlease insert coins: " 


@*****************************
@MISC SECTION
.balign 4
dispensingItems: .asciz "Dispening your items. . .\nPlease Take your change below.\nChange: %d¢\n\nPress enter key to continue."

.balign 4
Empty_msg: .asciz "OUT OF STOCK.\n\nPress enter key to continue."

.balign 4
inventoryStart: .asciz "\nADMIN INVENTORY CONSOLE\n___________________________\n\n"

.balign 4
gumInventory: .asciz "\nGum Inventory: %d\n"

.balign 4
peanutInventory: .asciz "\nPeanuts Inventory: %d\n"

.balign 4
crackersInventory: .asciz "\nCrackers Inventory: %d\n"

.balign 4
mnmsInventory: .asciz "\nM&Ms Inventory: %d\n\nPress any key to continue. . ."


@******************************
@Utility

.balign 4
Session_Counter: .asciz "\n\nSession #: %d\n"

clear_command: .asciz "clear"

.balign 4
charInputPattern: .asciz "%c"  @ character format for read.

.balign 4
charInput: .word 0   @ Location used to store the user input.

.balign 4
intInputPattern: .asciz "%d"  @ character format for read.

.balign 4
intInput: .word 0   @ Location used to store the user input.


.balign 4
invalid_input_msg: .asciz "\nInvalid Input, Try again."

@ Let the assembler know these are the C library functions

.global printf
.global scanf
