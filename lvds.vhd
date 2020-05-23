----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:32:56 05/23/2020 
-- Design Name: 
-- Module Name:    lvds - Behavioral 
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package par_array_pkg is

    type par8_a is array (natural range <>) of
	std_logic_vector (7 downto 0);

    type par10_a is array (natural range <>) of
	std_logic_vector (9 downto 0);

    type par12_a is array (natural range <>) of
	std_logic_vector (11 downto 0);

    type par16_a is array (natural range <>) of
	std_logic_vector (15 downto 0);

end par_array_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.par_array_pkg.ALL;



entity lvds is
port(
      clk     : in std_logic;
		reset   : in std_logic;
		lvds1   : out std_logic_vector(11 downto 0);
		lvds2   : out std_logic_vector(11 downto 0);
		lvds3   : out std_logic_vector(11 downto 0);
		lvds4   : out std_logic_vector(11 downto 0);
		lvds5   : out std_logic_vector(11 downto 0);
		lvds6   : out std_logic_vector(11 downto 0);
		lvds7   : out std_logic_vector(11 downto 0);
		lvds8   : out std_logic_vector(11 downto 0);
		lvds9   : out std_logic_vector(11 downto 0);
		lvds10  : out std_logic_vector(11 downto 0);
		lvds11  : out std_logic_vector(11 downto 0);
		lvds12  : out std_logic_vector(11 downto 0);
		lvds13  : out std_logic_vector(11 downto 0);
		lvds14  : out std_logic_vector(11 downto 0);
		lvds15  : out std_logic_vector(11 downto 0);
		lvds16  : out std_logic_vector(11 downto 0);
		lvds17  : out std_logic_vector(11 downto 0);
		lvds18  : out std_logic_vector(11 downto 0);
		lvds19  : out std_logic_vector(11 downto 0);
		lvds20  : out std_logic_vector(11 downto 0);
		lvds21  : out std_logic_vector(11 downto 0);
		lvds22  : out std_logic_vector(11 downto 0);
		lvds23  : out std_logic_vector(11 downto 0);
		lvds24  : out std_logic_vector(11 downto 0);
		lvds25  : out std_logic_vector(11 downto 0);
		lvds26  : out std_logic_vector(11 downto 0);
		lvds27  : out std_logic_vector(11 downto 0);
		lvds28  : out std_logic_vector(11 downto 0);
		lvds29  : out std_logic_vector(11 downto 0);
		lvds30  : out std_logic_vector(11 downto 0);
		lvds31  : out std_logic_vector(11 downto 0);
		lvds32  : out std_logic_vector(11 downto 0);
		ctrl_in : out std_logic_vector(11 downto 0);
		clk_div : out std_logic;
		test    : out std_logic_vector(3 downto 0)
		


);
end lvds;

architecture Behavioral of lvds is

signal counter : std_logic_vector(11 downto 0):= (others => '0');
signal counter_clk :std_logic_vector(3 downto 0):= (others => '0');
--signal clk_div : std_logic;
constant testpattern1 : std_logic_vector(11 downto 0):="111111111111";
constant testpattern2 : std_logic_vector(11 downto 0):="111100000000";
signal word_clk       : std_logic:='0';


begin

counter_clk_proc: process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			counter_clk<= (others => '0');
		else 
			if counter_clk="1011" then
				counter_clk<= (others => '0');
			else 
				counter_clk<=counter_clk+1;
			end if;
		end if;
	end if;
end process;


test <= counter_clk;


clk_div_proc: process(clk)
begin
	if rising_edge(clk) then
		if reset='1' then
			word_clk <= '0';
		else
			if counter_clk= "1011" then
				word_clk <= '1';
			elsif counter_clk ="0110" then
				word_clk <= '0';
			end if;
		end if;
	end if;
end process;

clk_div<=word_clk;

counter_proc: process(word_clk)
begin
	if rising_edge(word_clk) then
		if reset ='1' then
			counter <= (others => '0');
			ctrl_in<="000000000000";
			
		else
                if counter = "000011111111" then
                    counter <= testpattern1;
						  ctrl_in<= "001000000000";
						  
					 elsif counter= testpattern1 then
							counter <= (others => '0');
							ctrl_in <="111000000000";
							
					 elsif counter=  "000001111111" then 
							counter <= testpattern2;
							ctrl_in<="011000000000";
							
					 elsif counter= testpattern2 then
							counter <= "000010000000" ;
							ctrl_in <="111000000000";

							
                else
                    counter <= counter + 1;
						  ctrl_in<="111000000000";

                end if;
            end if;
        end if;
    end process;
	 
				
	 
	 lvds1 <= counter;
	 lvds2 <= counter;
	 lvds3 <= counter;
	 lvds4 <= counter;
	 lvds5 <= counter;
	 lvds6 <= counter;
	 lvds7 <= counter;
	 lvds8 <= counter;
	 lvds9 <= counter;
	 lvds10 <= counter;
	 lvds11 <= counter;
	 lvds12 <= counter;
	 lvds13 <= counter;
	 lvds14 <= counter;
	 lvds15 <= counter;
	 lvds16 <= counter;
	 lvds17 <= counter;
	 lvds18 <= counter;
	 lvds19 <= counter;
	 lvds20 <= counter;
	 lvds21 <= counter;
	 lvds22 <= counter;
	 lvds23 <= counter;
	 lvds24 <= counter;
	 lvds25 <= counter;
	 lvds26 <= counter;
	 lvds27 <= counter;
	 lvds28 <= counter;
	 lvds29 <= counter;
	 lvds30 <= counter;
	 lvds31 <= counter;
	 lvds32 <= counter;


end Behavioral;

