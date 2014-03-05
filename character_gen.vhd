----------------------------------------------------------------------------------
-- Company: ECE383
-- Engineer: Jason Mossing
-- Create Date:    13:24:55 02/21/2014 
-- Module Name:    character_gen - Behavioral 
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

entity character_gen is
    Port ( clk : in  STD_LOGIC;
           blank : in  STD_LOGIC;
			  reset : in std_logic;
           row : in  STD_LOGIC_VECTOR (10 downto 0);
           column : in  STD_LOGIC_VECTOR (10 downto 0);
           --ascii_to_write : in  STD_LOGIC_VECTOR (7 downto 0);
           write_en : in  STD_LOGIC;
			  up, down, left, right : in std_logic;
           r,g,b : out  STD_LOGIC_VECTOR (7 downto 0));
end character_gen;

architecture Behavioral of character_gen is

	component font_rom 
		port(
			clk: in std_logic;
			addr: in std_logic_vector(10 downto 0);
			data: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component char_screen_buffer
		Port ( clk : in  STD_LOGIC;
           we : in  STD_LOGIC;
           address_a : in  STD_LOGIC_VECTOR (11 downto 0);
           address_b : in  STD_LOGIC_VECTOR (11 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out_a : out  STD_LOGIC_VECTOR (7 downto 0);
           data_out_b : out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	signal data_out_b, data, ascii_to_write, ascii_sig, ascii : std_logic_vector(7 downto 0);
	signal row_sig, col_sig, col_sig1 : std_logic_vector(10 downto 0);
	signal pixel, upsig, downsig, rightsig, leftsig : std_logic;
	signal address : std_logic_vector(13 downto 0);
	signal count, count_temp : STD_LOGIC_VECTOR (11 downto 0);
	constant zero : std_logic_vector(7 downto 0) := (others=>'0');
	constant a : std_logic_vector(7 downto 0) := x"41";
	constant last : integer :=2399;
	constant first : integer := 0;
	constant rowshift : integer := 80;
	

begin

	 inst_font_rom : font_rom
	 		port map(
			clk => clk,
			addr => data_out_b(6 downto 0) & row_sig(3 downto 0),
			data => data
		);

	inst_char_screen_buffer : char_screen_buffer
		Port map ( clk => clk,
		  we => write_en,
		  address_a => count,
		  address_b => address(11 downto 0),
		  data_in => ascii_to_write,
		  data_out_a => ascii,
		  data_out_b => data_out_b
		  );

count <= count_temp;
			
count_temp <= (others => '0') when reset = '1' else
				  std_logic_vector(unsigned(count) + 1) when rising_edge(rightsig) else
				  std_logic_vector(unsigned(count) - 1) when rising_edge(leftsig) else
				  count;
					
ascii_to_write <= std_logic_vector(unsigned(ascii_sig) + 1) when upsig = '1' else
						std_logic_vector(unsigned(ascii_sig) - 1) when downsig = '1' else
						ascii_sig;
						
ascii_sig <= (a) when reset = '1' else
					ascii;

address <= std_logic_vector(unsigned(row(10 downto 4))* rowshift + unsigned(column(10 downto 3)));

-- Row DFF
	Process (clk)
	begin
		if (rising_edge(clk)) then
			row_sig <= row;
		end if;
	end process;
	
	-- Column 1 DFF
	Process (clk)
	begin
		if (rising_edge(clk)) then
			col_sig <= column;
		end if;
	end process;
	
	-- Column 2 DFF
	Process (clk)
	begin
		if (rising_edge(clk)) then
			col_sig1 <= col_sig;
		end if;
	end process;

-- 8 to 1 mux

with col_sig1(2 downto 0) select
	pixel <= data(7) when "000",
				data(6) when "001",
				data(5) when "010",
				data(4) when "011",
				data(3) when "100",
				data(2) when "101",
				data(1) when "110",
				data(0) when others;



	process (pixel, blank)
	begin
		r <= zero;
		g <= zero;
		b <= zero;
		
		if(blank = '0') then
			if(pixel = '1') then
				r <= (others => '1');
			end if;
		end if;
	end process;
			
	inst_up : entity work.input_to_pulse(shiftReg)
	    Port map ( 
			  clk => clk,
           reset => reset,
           input => up,
           pulse => upsig);
			  
	inst_down : entity work.input_to_pulse(shiftReg)
	    Port map ( 
			  clk => clk,
           reset => reset,
           input => down,
           pulse => downsig);

	inst_left : entity work.input_to_pulse(shiftReg)
	    Port map ( 
			  clk => clk,
           reset => reset,
           input => left,
           pulse => leftsig);

	inst_right : entity work.input_to_pulse(shiftReg)
	    Port map ( 
			  clk => clk,
           reset => reset,
           input => right,
           pulse => rightsig);
		

end Behavioral;

