THE KEYBOARD ROUTINES

THE 'KEYBOARD SCANNING' SUBROUTINE
This very important subroutine is called by both the main keyboard subroutine and the INKEY$ routine (in SCANNING).
In all instances the E register is returned with a value in the range of +00 to +27, the value being different for each of the forty keys of the keyboard, or the value +FF, for no-key.
The D register is returned with a value that indicates which single shift key is being pressed. If both shift keys are being pressed then the D and E registers are returned with the values for the CAPS SHIFT and SYMBOL SHIFT keys respectively.
If no keys is being pressed then the DE register pair is returned holding +FFFF.
The zero flag is returned reset if more than two keys are being pressed, or neither key of a pair of keys is a shift key.

028E KEY-SCAN     LD    L,+2F               The initial key value for each
                                            line will be +2F, +2E,...,+28.
                                            (Eight lines.)
                  LD    DE,+FFFF            Initialise DE to 'no-key'.
                  LD    BC,+FEFE            C = port address, B = counter.

Now enter a loop. Eight passes are made with each pass having a different initial key value and scanning a different line of five keys. (The first line is CAPS SHIFT, Z, X, C, V.)

0296 KEY-LINE     IN    A,(C)               Read from the port specified.
                  CPL                       A pressed key in the line will set
                  AND   +1F                 its respective bit (from bit 0 - 
                                            outer key, to bit 4 - inner key).
                  JR    Z,02AB,KEY-DONE     Jump forward if none of the
                                            five keys in the line are being
                                            pressed.
                  LD    H,A                 The key-bits go to the H register
                  LD    A,L                 whilst the initial key value is
                                            fetched.
029F KEY-3KEYS    INC   D                   If three keys are being pressed
                  RET   NZ                  on the keyboard then the D
                                            register will no longer hold +FF
                                            - so return if this happens.
02A1 KEY-BITS     SUB   +08                 Repeatedly subtract '8' from
                  SRL   H                   the present key value until a
                  JR    NC,02A1,KEY-BITS    key-bit is found.
                  LD    D,E                 Copy any earlier key value to
                                            the D register.
                  LD    E,A                 Pass the new key value to the
                                            E register.
                  JR    NZ,029F,KEY-3KEYS   If there is a second, or possibly
                                            a third, pressed key in this line
                                            then jump back.
02AB KEY-DONE     DEC   L                   The line has been scanned so the
                                            initial key value is reduced for
                                            the next pass.
                  RLC   B                   The counter is shifted and the
                  JR    C,0296,KEY-LINE     jump taken if there are still lines
                                            to be scanned.
Four tests are now made.
                  LD    A,D                 Accept any key value which still
                  INC   A                   has the D register holding +FF.
                  RET   Z                   i.e. A single key pressed or
                                            'no-key'.
                  CP    +28                 Accept the key value for a pair
                  RET   Z                   of keys if the 'D' key is CAPS
                                            SHIFT.

                  CP    +19                 Accept the key value for a pair
                  RET   Z                   of keys if the 'D' key is SYMBOL
                                            SHIFT.
                  LD    A,E                 It is however possible for the 'E'
                  LD    E,D                 key of a pair to be SYMBOL
                  LD    D,A                 SHIFT - so this has to be
                  CP    +18                 considered.
                  RET                       Return with the zero flag set if
                                            it was SYMBOL SHIFT and
                                            'another key'; otherwise reset.

THE 'KEYBOARD' SUBROUTINE
This subroutine is called on every occasion that a maskable interrupt occurs. In normal operation this will happen once every 20 ms. The purpose of this subroutine is to scan the keyboard and decode the key value. The code produced will, if the 'repeat' status allows it, be passed to the system variable LAST-K. When a code is put into this system variable bit 5 of FLAGS is set to show that a 'new' key has been pressed.

02BF KEYBOARD     CALL  028E,KEY-SCAN       Fetch a key value in the DE
                  RET   NZ                  register pair but return immedi-
                                            ately if the zero pair flag is reset.

A double system of 'KSTATE system variables' (KSTATE0 - KSTATE 3 and KSTATE4 - KSTATE7) is used from now on.
The two sets allow for the detection of a new key being pressed (using one set) whilst still within the 'repeat period' of the previous key to have been pressed (details in the other set).
A set will only become free to handle a new key if the key is held down for about 1/10 th. of a second. i.e. Five calls to KEYBOARD.

                  LD    HL,KSTATE0          Start with KSTATE0.
02C6 K-ST-LOOP    BIT   7,(HL)              Jump forward if a 'set is free';
                  JR    NZ,02D1,K-CH-SET    i.e. KSTATE0/4 holds +FF.
                  INC   HL                  However if the set is not free
                  DEC   (HL)                decrease its '5 call counter'
                  DEC   HL                  and when it reaches zero signal
                  JR    NZ,02D1,K-CH-SET    the set as free.
                  LD    (HL),+FF

After considering the first set change the pointer and consider the second set.

02D1 K-CH-SET     LD    A,L                 Fetch the low byte of the
                  LD    HL,KSTATE4          address and jump back if the
                  CP    L                   second set has still to be
                  JR    NZ,02C6,K-ST-LOOP   considered.

Return now if the key value indicates 'no-key' or a shift key only.

                  CALL  031E,K-TEST         Make the necessary tests and
                  RET   NC                  return if needed. Also change
                                            the key value to a 'main code'.

A key stroke that is being repeated (held down) is now separated from a new key stroke.

                  LD    HL,KSTATE0          Look first at KSTATE0.
                  CP    (HL)                Jump forward if the codes
                  JR    Z,0310,K-REPEAT     match - indicating a repeat.
                  EX    DE,HL               Save the address of KSTATE0.
                  LD    HL,KSTATE4          Now look at KSTATE4.
                  CP    (HL)                Jump forward if the codes
                  JR    Z,0310,K-REPEAT     match - indicating a repeat.

But a new key will not be accepted unless one of the sets of KSTATE system variables is 'free'.

                  BIT   7,(HL)              Consider the second set.
                  JR    NZ,02F1,K-NEW       Jump forward if 'free'.
                  EX    DE,HL               Now consider the first set.

                  BIT   7,(HL)              Continue if the set is 'free' but
                  RET   Z                   exit from the KEYBOARD
                                            subroutine if not.

The new key is to be accepted. But before the system variable LAST-K can be filled, the KSTATE system variables, of the set being used, have to be initialised to handle any repeats and the key's code has to be decoded.

02F1 K-NEW        LD    E,A                 The code is passed to the
                  LD    (HL),A              E register and to KSTATE0/4.
                  INC   HL                  The '5 call counter' for this
                  LD    (HL),+05            set is reset to '5'.
                  INC   HL                  The third system variable of
                  LD    A,(REPDEL)          the set holds the REPDEL value
                  LD    (HL),A              (normally 0.7 secs.).
                  INC   HL                  Point to KSTATE3/7.

The decoding of a 'main code' depends upon the present state of MODE, bit 3 of FLAGS and the 'shift byte'.

                  LD    C,(MODE)            Fetch MODE.
                  LD    D,(FLAGS)           Fetch FLAGS.
                  PUSH  HL                  Save the pointer whilst the
                  CALL  0333,K-DECODE       'main code' is decoded.
                  POP   HL
                  LD    (HL),A              The final code value is saved in
                                            KSTATE3/7; from where it is
                                            collected in case of a repeat.

The next three instruction lines are common to the handling of both 'new keys' and 'repeat keys'.

0308 K-END        LD    (LAST-K),A          Enter the final code value into
                  SET   5,(FLAGS)           LAST-K and signal 'a new key'.
                  RET                       Finally return.

THE 'REPEATING KEY' SUBROUTINE
A key will 'repeat' on the first occasion after the delay period - REPDEL (normally 0.7 secs.) and on subsequent occasions after the delay period - REPPER (normally 0.1 secs.).

0310 K-REPEAT     INC   HL                  Point to the '5 call counter'
                  LD    (HL),+05            of the set being used and reset
                                            it to '5'.
                  INC   HL                  Point to the third system vari-
                  DEC   (HL)                able - the REPDEL/REPPER
                                            value, and decrement it.
                  RET   NZ                  Exit from the KEYBOARD
                                            subroutine if the delay period
                                            has not passed.
                  LD    A,(REPPER)          However once it has passed the
                  LD    (HL),A              delay period for the next repeat
                                            is to be REPPER.
                  INC   HL                  The repeat has been accepted
                  LD    A,(HL)              so the final code value is fetched
                                            from KSTATE3/7 and passed
                  JR    0308,K-END          to K-END.

THE 'K-TEST' SUBROUTINE
The key value is tested and a return made if 'no-key' or 'shift-only'; otherwise the 'main code' for that key is found.

031E K-TEST       LD    B,D                 Copy the shift byte.
                  LD    D,+00               Clear the D register for later.
                  LD    A,E                 Move the key number.
                  CP    +27                 Return now if the key was
                  RET   NC                  'CAPS SHIFT' only or 'no-key'.

                  CP    +18                 Jump forward unless the 'E'
                  JR    NZ,032C,K-MAIN      key was SYMBOL SHIFT.
                  BIT   7,B                 However accept SYMBOL SHIFT
                  RET   NZ                  and another key; return with
                                            SYMBOL SHIFT only.

The 'main code' is found by indexing into the main key table.

032C K-MAIN       LD    HL,+0205            The base address of the table.
                  ADD   HL,DE               Index into the table and fetch
                  LD    A,(HL)              the 'main code'.
                  SCF                       Signal 'valid keystroke'
                  RET                       before returning.

THE 'KEYBOARD DECODING' SUBROUTINE
This subroutine is entered with the 'main code' in the E register, the value of FLAGS in the D register, the value of MODE in the C register and the 'shift byte' in the B register.
By considering these four values and referring, as necessary, to the six key tables a 'final code' is produced. This is returned in the A register.

0333 K-DECODE     LD    A,E                 Copy the 'main code'.
                  CP    +3A                 Jump forward if a digit key is
                  JR    C,0367,K-DIGIT      being considered; also SPACE,
                                            ENTER & both shifts.
                  DEC   C                   Decrement the MODE value.
                  JP    M,034F,K-KLC-LET    Jump forward, as needed, for
                  JR    Z,0341,K-E-LET      modes 'K', 'L', 'C' & 'E'.

Only 'graphics' mode remains and the 'final code' for letter keys in graphics mode is computed from the 'main code'.

                  ADD   A,+4F               Add the offset.
                  RET                       Return with the 'final code'.

Letter keys in extended mode are considered next.

0341 K-E-LET      LD    HL,+01EB            The base address for table 'b'.
                  INC   B                   Jump forward to use this table
                  JR    Z,034A,K-LOOK-UP    if neither shift key is being
                                            pressed.
                  LD    HL,+0205            Otherwise use the base address
                                            for table 'c'.

Key tables 'b-f' are all served by the following look-up routine. In all cases a 'final code' is found and returned.

034A K-LOOK-UP    LD    D,+00               Clear the D register.
                  ADD   HL,DE               Index the required table
                  LD    A,(HL)              and fetch the 'final code'.
                  RET                       Then return.

Letter keys in 'K', 'L' or 'C' modes are now considered. But first the special SYMBOL SHIFT codes have to be dealt with.

034F K-KLC-LET    LD    HL,+0229            The base address for table 'e'
                  BIT   0,B                 Jump back if using the SYMBOL
                  JR    Z,034A,K-LOOK-UP    SHIFT key and a letter key.
                  BIT   3,D                 Jump forward if currently in
                  JR    Z,0364,K-TOKENS     'K' mode.
                  BIT   3,(FLAGS2)          If CAPS LOCK is set then
                  RET   NZ                  return with the 'main code'
                  INC   B                   Also return in the same manner
                  RET   NZ                  if CAPS SHIFT is being pressed.
                  ADD   A,+20               However if lower case codes are
                  RET                       required then +20 has to be
                                            added to the 'main code' to give
                                            the correct 'final code'.

The 'final code' values for tokens are found by adding +A5 to the 'main code'.

0364 K-TOKENS     ADD   A,+A5               Add the required offset and
                  RET                       return.

Next the digit keys; and SPACE, ENTER & both shifts; are considered.

0367 K-DIGIT      CP    +30                 Proceed only with the digit keys.
                  RET   C                   i.e. Return with SPACE (+20),
                                            ENTER (+0D) & both shifts
                                            (+0E).
                  DEC   C                   Now separate the digit keys into
                                            three groups - according to the
                                            mode.
                  JP    M,039D,K-KLC-DGT    Jump with 'K', 'L' & 'C' modes;
                  JR    NZ,0389,K-GRA-DGT   and also with 'G' mode.
                                            Continue with 'E' mode.
                  LD    HL,+0254            The base address for table 'f'.
                  BIT   5,B                 Use this table for SYMBOL
                  JR    Z,034A,K-LOOK-UP    SHIFT & a digit key in
                                            extended mode.
                  CP    +38                 Jump forward with digit keys
                  JR    NC,0382,K-8-&-9     '8' and '9'.

The digit keys '0' to '7' in extended mode are to give either a 'paper colour code' or an 'ink colour code' depending on the use of the CAPS SHIFT.

                  SUB   +20                 Reduce the range +30 to +37
                                            giving +10 to +17.
                  INC   B                   Return with this 'paper colour
                  RET   Z                   code' if the CAPS SHIFT is
                                            not being used.
                  ADD   A,+08               But if it is then the range is to
                  RET                       be +18 to +1F instead - indicat-
                                            ing an 'ink colour code'.

The digit keys '8' and '9' are to give 'BRIGHT' & 'FLASH' codes.

0382 K-8-&-9      SUB   +36                 +38 & +39 go to +02 & +03.
                  INC   B                   Return with these codes if CAPS
                  RET   Z                   SHIFT is not being used. (These
                                            are 'BRIGHT' codes.)
                  ADD   A,+FE               Subtract '2' is CAPS SHIFT is
                  RET                       being used; giving +00 & +01 (as
                                            'FLASH' codes).

The digit keys in graphics mode are to give the block graphic characters (+80 to +8F), the GRAPHICS code (+0F) and the DELETE code (+0C).

0389 K-GRA-DGT    LD    HL,+0230            The base address of table 'd'.
                  CP    +39                 Use this table directly for
                  JR    Z,034A,K-LOOK-UP    both digit key '9' that is to give
                  CP    +30                 GRAPHICS, and digit key '0'
                  JR    Z,034A,K-LOOK-UP    that is to give DELETE.
                  AND   +07                 For keys '1' to '8' make the
                  ADD   A,+80               range +80 to +87.
                  INC   B                   Return with a value from this
                  RET   Z                   range if neither shift key is
                                            being pressed.
                  XOR   +0F                 But if 'shifted' make the range
                  RET                       +88 to +8F.

Finally consider the digit keys in 'K', 'L' & 'C' modes.

039D K-KLC-DGT    INC   B                   Return directly if neither shift
                  RET   Z                   key is being used. (Final codes
                                            +30 to +39.)
                  BIT   5,B                 Use table 'd' if the CAPS
                  LD    HL,+0230            SHIFT key is also being
                  JR    NZ,034A,K-LOOK-UP   pressed.

The codes for the various digit keys and SYMBOL SHIFT can now be found.

                  SUB   +10                 Reduce the range to give +20 to
                                            +29.
                  CP    +22                 Separate the '@' character
                  JR    Z,03B2,K-@-CHAR     from the others.
                  CP    +20                 The '-' character has also to be
                                            separated.
                  RET   NZ                  Return now with the 'final
                                            codes' +21, +23 to +29.
                  LD    A,+5F               Give the '-' character a
                  RET                       code of +5F.
03B2 K-@-CHAR     LD    A,+40               Give the '@' character a code
                  RET                       of +40.

THE LOUDSPEAKER ROUTINES

