library ieee;
use ieee.std_logic_1164.all;

entity RegFile is
    port(
        rst, en : in std_logic;
        a1, a2, a3 : in std_logic_vector (2 downto 0);
        d1, d2 : out std_logic_vector (15 downto 0);
        d3 : in std_logic_vector (15 downto 0)
    );
end entity;

architecture RegisterFile_arch of RegFile is
    signal s1_0, s1_1, s1_2, s1_3, s1_4, s1_5, s1_6, s1_7 : std_logic_vector (15 downto 0);

begin  				
    process(rst, en, a1, a2, a3, d3)
    begin
        

            if a1 = "000" then
                d1 <= s1_0;
            end if;
            if a1 = "001" then
                d1 <= s1_1;
            end if;
            if a1 = "010" then
                d1 <= s1_2;
            end if;
            if a1 = "011" then
                d1 <= s1_3;
            end if;
            if a1 = "100" then
                d1 <= s1_4;
            end if;
            if a1 = "101" then
                d1 <= s1_5;
            end if;
            if a1 = "110" then
                d1 <= s1_6;
            end if;
            if a1 = "111" then
                d1 <= s1_7;
            end if;

            if a2 = "000" then
                d2 <= s1_0;
            end if;
            if a2 = "001" then
                d2 <= s1_1;
            end if;
            if a2 = "010" then
                d2 <= s1_2;
            end if;
            if a2 = "011" then
                d2 <= s1_3;
            end if;
            if a2 = "100" then
                d2 <= s1_4;
            end if;
            if a2 = "101" then
                d2 <= s1_5;
            end if;
            if a2 = "110" then
                d2 <= s1_6;
            end if;
            if a2 = "111" then
                d2 <= s1_7;
            end if;

            if en = '1' then
                if a3 = "000" then
                    s1_0 <= d3;
                end if;
                if a3 = "001" then
                    s1_1 <= d3;
                end if;
                if a3 = "010" then
                    s1_2 <= d3;
                end if;
                if a3 = "011" then
                    s1_3 <= d3;
                end if;
                if a3 = "100" then
                    s1_4 <= d3;
                end if;
                if a3 = "101" then
                    s1_5 <= d3;
                end if;
                if a3 = "110" then
                    s1_6 <= d3;
                end if;
                if a3 = "111" then              
                    s1_7 <= d3;
					 end if;
                
			   end if;
       
    end process ;

end RegisterFile_arch ; -- RegisterFile_arch