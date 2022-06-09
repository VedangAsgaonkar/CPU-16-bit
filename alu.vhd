library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port(op: in std_logic_vector(1 downto 0);
  Inp_alu_a: in std_logic_vector(15 downto 0);
  Inp_alu_b: in std_logic_vector(15 downto 0);
  alu_car: out std_logic;
  alu_zer: out std_logic;
  alu_outp: out std_logic_vector(15 downto 0));
end entity;

architecture alu_arch of alu is


begin

  process(op, Inp_alu_a , Inp_alu_b)
  variable val_a, val_b : std_logic_vector(16 downto 0);
  variable interm : std_logic_vector(16 downto 0);
	 begin
    
    val_a := "0"&Inp_alu_a;
	val_b := "0"&Inp_alu_b;
	 
	 if op = "10" then
			interm(15 downto 0) := val_a(15 downto 0) nand val_b(15 downto 0);
			interm(16) := '0';	
	 elsif op = "01" or op = "00" then
			
			interm := std_logic_vector(signed(val_a) + signed(val_b ));	
			
	 else
			interm := "00000000000000000";
    end if;
    alu_outp <= interm(15 downto 0);
    alu_car <= interm(16);
    if to_integer(signed(interm(15 downto 0))) = 0 then
		alu_zer <= '1';
	 else 
		alu_zer <= '0';
	end if;
  end process;
end architecture ;