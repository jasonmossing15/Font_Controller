----------------------------------------------------------------------------------
-- Company: ECE383
-- Engineer: Jason Mossing
-- Create Date:    10:52:51 03/05/2014  
-- Module Name:    intput_to_pulse_with_held - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity input_to_pulse_with_held is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC;
           hold : out  STD_LOGIC;
           pulse : out  STD_LOGIC);
end input_to_pulse_with_held;

architecture Behavioral of input_to_pulse_with_held is
signal dcount_reg, dcount_next : unsigned(15 downto 0);
	signal holdcount, holdcount_temp : unsigned(19 downto 0);
	type button_states is (idle, pressed, held);
	signal p_state_reg, p_state_next : button_states;
	signal pulse_reg, pulse_next, inp, inp_temp, in1, in2, ledsig, leds, held_reg, held_next : std_logic;
	constant shiftdelay : integer := 50000;
	constant holddelay : integer := 10000000;
	
begin
--Count State Register
	process(clk, reset)
	begin
		if (reset = '1') then
			in1 <= '0';
			in2 <= '0';
			dcount_reg <= to_unsigned(0,16);
			inp <= '0';
			holdcount <= to_unsigned(0,20);
		elsif rising_edge(clk) then
			dcount_reg <= dcount_next;
			in1 <= input;
			in2 <= in1;
			inp <= inp_temp;
			holdcount <= holdcount_temp;
		end if;
	end process;

dcount_next <= dcount_reg + 1 when in1 = in2 else
				  to_unsigned(0,16);
				  
inp_temp <= in2 when dcount_reg > shiftdelay else
				inp;

--	State Register
	process(clk, reset)
	begin
		if (reset = '1') then
			p_state_reg <= idle;
		elsif rising_edge(clk) then
			p_state_reg <= p_state_next;
		end if;
	end process;

--Paddle Next logic
	process(p_state_reg, dcount_reg, inp)
	begin
		p_state_next <= p_state_reg;

		case p_state_reg is
			when pressed =>
					p_state_next <= held;
			when held =>
				if(inp = '0') then
					p_state_next <= idle;
				end if;
			when idle =>
				if (inp = '1') then
					p_state_next <= pressed;
				end if;
		end case;
	end process;



--Pulse output logic
	process(p_state_reg)
	begin
		pulse_next <= '0';
		held_next <= '0';
		
		case p_state_reg is
			when pressed =>
				pulse_next <= '1';
			when held =>
				held_next <='1';
			when idle =>
		end case;
	end process;	

holdcount_temp <= holdcount + 1 when held_reg = '1' and holdcount < holddelay else
						to_unsigned(0,20);

--output Register
	process(clk, reset)
	begin
		if (reset = '1') then
			pulse_reg <= '0';
			held_reg <= '0';
		elsif rising_edge(clk) then
			pulse_reg <= pulse_next;
			held_reg <= held_next;
		end if;
	end process;


pulse <= pulse_reg;
hold <= '1' when holdcount = shiftdelay else
			'0';


end Behavioral;

