----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:06 02/19/2014 
-- Design Name: 
-- Module Name:    input_to_pulse - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_to_pulse is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           input : in  STD_LOGIC;
           pulse : out  STD_LOGIC);
end input_to_pulse;

architecture Behavioral of input_to_pulse is
	signal dcount_reg, dcount_next : unsigned(15 downto 0);
	type button_states is (idle, pressed, debounce, debounced);
	signal p_state_reg, p_state_next : button_states;
	signal pulse_reg, pulse_next : std_logic;
	
begin
--Count State Register
	process(clk, reset)
	begin
		if (reset = '1') then
			dcount_reg <= to_unsigned(0,16);
		elsif rising_edge(clk) then
			dcount_reg <= dcount_next;
		end if;
	end process;

dcount_next <= dcount_reg + 1 when p_state_reg = debounce else
				  to_unsigned(0,16);

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
	process(p_state_reg, input, dcount_reg)
	begin
		p_state_next <= p_state_reg;

		case p_state_reg is
			when pressed =>
				p_state_next <= debounce;
			when debounce =>
				if dcount_reg > 50000 then
					p_state_next <= debounced;
				end if;
			when debounced =>
				p_state_next <= idle;
			when idle =>
				if (input = '1') then
					p_state_next <= pressed;
				end if;
		end case;
	end process;



--Paddle output logic
	process(p_state_reg)
	begin
		pulse_next <= '0';
		
		case p_state_reg is
			when pressed =>
			when debounce =>
			when debounced =>
				pulse_next <= '1';
			when idle =>
		end case;
	end process;			

--output Register
	process(clk, reset)
	begin
		if (reset = '1') then
			pulse_reg <= '0';
		elsif rising_edge(clk) then
			pulse_reg <= pulse_next;
		end if;
	end process;


pulse <= pulse_reg;

end Behavioral;

