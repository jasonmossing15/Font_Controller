----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:26:39 02/21/2014 
-- Design Name: 
-- Module Name:    char_screen_buffer - Behavioral 
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

entity char_screen_buffer is
    Port ( clk : in  STD_LOGIC;
           we : in  STD_LOGIC;
           address_a : in  STD_LOGIC_VECTOR (11 downto 0);
           address_b : in  STD_LOGIC_VECTOR (11 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out_a : out  STD_LOGIC_VECTOR (7 downto 0);
           data_out_b : out  STD_LOGIC_VECTOR (7 downto 0));
end char_screen_buffer;

architecture Behavioral of char_screen_buffer is
    signal address_a_reg : std_logic_vector(11 downto 0);
    signal address_b_reg : std_logic_vector(11 downto 0);

    type ram_type is array (4096-1 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type :=
    (
        (others => x"41")
    );
    -- x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"0A", x"0B", x"0C", x"0D", x"0E", x"0F"
begin

    process (clk) is
    begin
        if rising_edge(clk) then
            if (we = '1') then
                RAM(to_integer(unsigned(address_a))) <= data_in;
            end if;

            address_a_reg <= address_a;
            address_b_reg <= address_b;
        end if;
    end process;

    data_out_a <= RAM(to_integer(unsigned(address_a_reg)));
    data_out_b <= RAM(to_integer(unsigned(address_b_reg)));


end Behavioral;

