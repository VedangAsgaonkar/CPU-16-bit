library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

entity priority_encoder is
	port(
		input_pe: in std_logic_vector(7 downto 0);
		output_pe: out std_logic_vector(2 downto 0);
		next_input_pe : out std_logic_vector(7 downto 0);
		valid: out std_logic);
end entity;

architecture priority_encoder_arch of priority_encoder is
	signal output_temp: std_logic_vector(2 downto 0);
	
begin

	process(input_pe)
		variable nxi : std_logic_vector(7 downto 0);
		variable prev_ind : natural := 0;
		variable prev_flag : std_logic := '0';
	begin
		output_temp <= (others => '0');
		prev_ind := 0;
		prev_flag := '0';
		nxi := input_pe;
		for i in 7 downto 0 loop
			if input_pe(i) = '1' then
				if prev_flag = '0' then
					nxi(i) := '0';
					prev_ind := i;
					prev_flag := '1';
				else
					nxi(prev_ind) := '1';
					nxi(i) := '0';
					prev_ind := i;
				end if;
				output_temp <= std_logic_vector(to_unsigned(i,3));
			end if;
		end loop;
		next_input_pe <= nxi;
	end process;
	
	output_pe <= output_temp;
	
	valid <= '0' when (to_integer(unsigned(output_temp)) = 0 and input_pe(0) = '0') else '1';
	
end architecture;
