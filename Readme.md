# Font Controller

This lab is creating a font controller by using the exsiting atlys lab file, along with three new files: character_gen, font_rom, and char_screen_buffer. The issues we needed to address during this lab were: correct delay of signals, proper concatenation of signals in order to pass them on to the next component, and properly creating a single pulse output given a button push.

## Implementation

This was implemented by using the existing atlys lab video file and adding a component of character_gen. Inside of character_gen, there are two components: char_screen_buffer and font_rom. Also for B and A functionality there are some input_to_pulse components. In addition to character_gen, in A functionality there is a nes_controller component in order to interface with the nes controller. The following is a visual representation of the component connections for A functionality:

![Overall Connections](Connections.jpg)

The character_gen is the only component that needed to be edited, since the other components were given. Character_gen involves three main items: component instantiation, logic for the components, and logic for displaying the characters (equivalent to pixel_gen).

1 the components instantiated are the font_rom, char_screen_buffer, and input_to_pulse.

2 The logic for the components involves: concatenation (`addr => data_out_b(6 downto 0) & row_sig(3 downto 0);`), a 8 to 1 mux, D-Flip Flops, and logic for an internal count (B and A functionality)

3 The logic for pixel generation is almost identical to the pixel_gen. The pixel being highleted is determined by the 8-to-1 mux.


B Functionality deals with using the switches and a button in order to change the character. The array of the switches is the std_logic_vector for the ascii_to_write. Then the button is the write_en after it has gone through the input_to_pulse component.

A Functionality is interfacing with the nes controller. the hardest part is dealing with the logic in order to deal with how to change the character selected and what that character should be.

## Test and Debug

This program was tested by trial and error. When I felt that an effective change was made I generated a new BIT file and tested it. Just like the Pong lab, this was very ineffective what it comes to time spent.

I ran into two main issues: glitches due to not enough delay and glitches due to moving to the next character.

- The *delay error* was due to not having enouhg D-Flip Flops for my row signal. This caused a shift of two pixels to the right. The fix was the addition of a flip flop. Here is an example of a D-Flip Flop:
```
Process (clk)
begin 
	if (rising_edge(clk)) then
		row_sig <= row;
	end if;
end process;
```

- The other error is *moving to the next character*. This occured when dealing with the internal count in the char_screen_buffer. At first I was checking when `write_en = '1'` instead of checking `rising_edge(write_en)`. The second allows the count to change once because it only changes when write_en rises to '1' instead of changing every time it checks.

## Conclusion

Overall I learned once again the importance of timing. Even one clock cycle difference for one signal can shift the results by a few pixels. I also learned the importance of the ordering of concatenated signals. In addition, I learned the importance of debouncing buttons. If I were to add one thing to this lab, I would add a blinking cursor to the A functionality.
