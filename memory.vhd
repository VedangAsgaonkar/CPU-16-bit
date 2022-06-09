library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  port(clk: in std_logic;
      mem_wr: in std_logic;
      address: in std_logic_vector(5 downto 0);
      data_in: in std_logic_vector(15 downto 0);
      data_out: out std_logic_vector(15 downto 0));
end entity;

architecture mem of memory is
  type RAM_array is array (0 to 2**6-1) of std_logic_vector (15 downto 0);
	signal RAM : RAM_array:= (X"4255",X"4655",X"4A55", X"4C55", X"4800", X"5109", X"C06A", X"610A",X"FFFF",X"000A",others=>X"0000"); -- those values are our code
begin
  process(clk, mem_wr, data_in, address, RAM)
    begin
    if rising_edge(clk) then
      if(mem_wr = '1') then
        RAM(to_integer(unsigned(address))) <= data_in;
      end if;
    end if;
      data_out <= RAM(to_integer(unsigned(address)));
  end process;
end architecture mem;
