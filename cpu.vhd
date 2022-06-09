library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IITB_RISC is
  port (
    clk, rst : in std_logic;
    start_addr : in std_logic_vector(15 downto 0);
	 kill : out std_logic
  ) ;
end entity;

architecture IITB_RISC_arch of IITB_RISC is
    component alu 
    port(op: in std_logic_vector(1 downto 0);
    Inp_alu_a: in std_logic_vector(15 downto 0);
    Inp_alu_b: in std_logic_vector(15 downto 0);
    alu_car: out std_logic;
    alu_zer: out std_logic;
    alu_outp: out std_logic_vector(15 downto 0));
    end component;
    
    component RegFile 
        port(
            rst, en : in std_logic;
            a1, a2, a3 : in std_logic_vector (2 downto 0);
            d1, d2 : out std_logic_vector (15 downto 0);
            d3 : in std_logic_vector (15 downto 0)            
        );
    end component;

    component memory
        port(clk: in std_logic;
        mem_wr: in std_logic;
        address: in std_logic_vector(5 downto 0);
        data_in: in std_logic_vector(15 downto 0);
        data_out: out std_logic_vector(15 downto 0));
    end component;
	 
	 component priority_encoder
	 port(
		input_pe: in std_logic_vector(7 downto 0);
		output_pe: out std_logic_vector(2 downto 0);
		next_input_pe : out std_logic_vector(7 downto 0);
		valid: out std_logic);
	end component;

    signal state : std_logic_vector(7 downto 0); -- MS 4 will be state and next 4 will be the inst
    signal c_flag , z_flag , alu_c , alu_z : std_logic;
    signal reg_wr : std_logic;
    signal op : std_logic_vector(1 downto 0);
    signal reg_a1, reg_a2, reg_a3 : std_logic_vector (2 downto 0);
    signal reg_d1, reg_d2, reg_d3 , Inp_alu_a , Inp_alu_b , alu_outp , t1, t2 ,e1,e2: std_logic_vector (15 downto 0);
    signal mem_wr : std_logic;
    signal mem_d_in, mem_d_out : std_logic_vector (15 downto 0);
	 signal mem_addr : std_logic_vector(5 downto 0);
    signal ct, valid_pe : std_logic;
    signal input_pe, next_input_pe : std_logic_vector(7 downto 0);
    signal output_pe : std_logic_vector(2 downto 0);
	 signal sigkill : std_logic;
   
begin

    regfile_inst : RegFile
        port map(rst => rst, en => reg_wr, a1 => reg_a1, a2 => reg_a2, a3 => reg_a3, d1 => reg_d1, d2 => reg_d2, d3 => reg_d3);
        
    memory_inst : memory
        port map(clk => clk, mem_wr => mem_wr, address => mem_addr, data_in => mem_d_in, data_out => mem_d_out);
      
    alu_inst : alu 
        port map(op => op, Inp_alu_a =>  Inp_alu_a , Inp_alu_b => Inp_alu_b , alu_car => alu_c , alu_zer => alu_z ,alu_outp => alu_outp);
        
    priority_encoder_inst : priority_encoder
        port map(
            input_pe =>input_pe,   output_pe=>output_pe, next_input_pe => next_input_pe , valid => valid_pe  );

        
    process(clk)
        variable IR : std_logic_vector(15 downto 0);
		  variable PC : unsigned(15 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then -- boot the computer
                c_flag <= '0';
                z_flag <= '0';
					 sigkill <= '0';
					                 
                reg_a3 <= "111";
                reg_d3 <= start_addr;
                ct <= '0';
                state <= "00010000";
                PC := unsigned(start_addr);
                reg_wr<='1';
                -- ct is 0 at beginning and 1 during the processing of the edge
				elsif sigkill = '1' then
					 sigkill <= '1';
            else                
                -- reset is not 1 here.
                if state(7 downto 4) = "0001" then -- load IR
                    if ct = '0' then
                        mem_addr <= std_logic_vector(PC(5 downto 0));
                        ct <= '1';
                        PC := PC + 1;
                        reg_a3 <= "111";
                        reg_d3 <= std_logic_vector(PC);
                        reg_wr<='1';
                    elsif ct = '1' then
                        IR := mem_d_out;
                        state(3 downto 0) <= mem_d_out(15 downto 12);
                        ct <= '0';
                        if IR(15 downto 12) = "0001" or IR(15 downto 12) = "0000" or IR(15 downto 12) = "0010" or IR(15 downto 12) = "0101" or IR(15 downto 12) = "0111" or IR(15 downto 12) = "0111" or IR(15 downto 12) = "1101" or IR(15 downto 12) = "1100" or IR(15 downto 12) = "1000" then
                            state(7 downto 4) <= "0010";
                        elsif IR(15 downto 12) = "0100" then
                            state(7 downto 4) <= "0110";
                        elsif IR(15 downto 12) = "1001" or IR(15 downto 12) = "1011" then
                            state(7 downto 4) <= "1111";
                        elsif IR(15 downto 12) = "1010" then
                            state(7 downto 4) <= "0000"; -- 16 zero hai
								elsif IR(15 downto 12) <= "1111" then --halt
									 sigkill <= '1';
                        end if;
                        reg_wr<='0';
                    end if;

                elsif state(7 downto 4) = "0010" then
                    --State is 2 currently
                    if ct='0' then
                        ct<='1';
                        reg_a1<=IR(8 downto 6);
                        reg_a2<=IR(11 downto 9);                        
                        
                        reg_wr<='1';
                    else
                        -- Going to next state now.
                        ct<='0';
								
								e1<=reg_d1;
                        if state(3 downto 0)="0001" and IR(1 downto 0)="11" then --ADL
                            e2<=reg_d2(14 downto 0)&'0';
                            t1<=reg_d2(14 downto 0)&'0';
                        else 
                            e2<=reg_d2;
                            t1<=reg_d2;
                        end if;
                        
                        reg_wr<='0';
                        input_pe<=IR(7 downto 0);
                        --LHI is 01_00
                        if state(3 downto 0)="0000" then --ADI
                            state(7 downto 4)<="0111";
                        elsif state(3 downto 0)="0101" then --LW
                            state(7 downto 4)<="0111";
                        elsif state(3 downto 0)="0111" then --SW
                            state(7 downto 4)<="0111";
                        elsif state(3 downto 0)="1101" then --LM
                            state(7 downto 4)<="1010";
									 mem_addr <= reg_d2(5 downto 0);
                        elsif state(3 downto 0)="1100" then --SM
                            state(7 downto 4)<="1100";
                        elsif state(3 downto 0)="1000" then --BEQ
                            if reg_d1=reg_d2 then
                                state(7 downto 4)<="1110";
                            else
                                state(7 downto 4)<="0101";
                            end if;
                        elsif state(1 downto 0)="01" then --Cases of ADD
                            if IR(1 downto 0)= "10" then
                                if c_flag = '1' then
                                    state(7 downto 4)<="0011";
                                else
                                    state(7 downto 4)<="0101";
                                end if;
                            elsif IR(1 downto 0)= "01" then
                                if z_flag = '1' then
                                    state(7 downto 4)<="0011";
                                else
                                    state(7 downto 4)<="0101";
                                end if;
                            else 
                                state(7 downto 4)<="0011";
                            end if; 

                        elsif state(1 downto 0)="10" then --Cases of NAND
                            if IR(1 downto 0)= "10" then
                                if c_flag = '1' then
                                    state(7 downto 4)<="0011";
                                else
                                    state(7 downto 4)<="0101";
                                end if;
                            elsif IR(1 downto 0)= "01" then
                                if z_flag = '1' then
                                    state(7 downto 4)<="0011";
                                else
                                    state(7 downto 4)<="0101";
                                end if;
                            else 
                                state(7 downto 4)<="0011";
                            end if;                                                   
                        
                        end if;
         
                    end if;
                    

                    
                
                elsif state(7 downto 4) = "0011" then
                    if ct= '0' then
                        
                       Inp_alu_a <= e1;
                       Inp_alu_b <= e2; 
                       op <= state(1 downto 0);
                        
                        ct<='1';
                    else
                        if state(3 downto 0) = "0001" then
                            t1 <= alu_outp;
									 c_flag <= alu_c;
									 z_flag <= alu_z;
								elsif state(3 downto 0) = "0010" then
									 t1 <= alu_outp;
									 z_flag <= alu_z;
                        end if;
                        ct<='0';
								
                        state(7 downto 4) <=  "0100";
                    end if;

                    
                elsif state(7 downto 4) = "0100" then
                    if ct= '0' then
                        if state(3 downto 0) = "0000" then
                            reg_a3<=IR(8 downto 6);
                        else
                             reg_a3<=IR(5 downto 3);
                        end if;
                        ct<='1';
                        reg_d3<=t1;
                        reg_wr<='1';
                    else
                        ct<='0';
                        state(7 downto 4)<="0001";
                        reg_wr<='0';
                    end if;
                
                elsif state(7 downto 4) = "0101" then
                    if ct= '0' then
                        reg_d3 <= std_logic_vector(PC);
                        reg_a3 <= "111";                
                        Inp_alu_a <= t1;
                        Inp_alu_b <= (others => '0');
                        ct<='1';
                        reg_wr<='1';
                    else
                        ct<='0';
                        reg_wr<='0';
                        state(7 downto 4) <= "0001";    
                    end if;
                
                elsif state(7 downto 4) = "0110" then
                    if ct= '0' then
                        ct<='1';
                        reg_a3<=IR(11 downto 9);
                        reg_d3<=IR(8 downto 0)&"0000000";
                        reg_wr<='1';
                    else
                        ct<='0';  
                        reg_wr<='0';
                        state(7 downto 4)<="0001";

                    end if;
            
                elsif state(7 downto 4) = "0111" then 
                    if ct = '0' then
                        Inp_alu_a <= e1;
                        if IR(5) = '1' then 
                            Inp_alu_b <= "1111111111"&IR(5 downto 0);
                        else
                            Inp_alu_b <= "0000000000"&IR(5 downto 0);
                        end if;
                        op <= "00";
                        ct <= '1';
                    else 
                        t1 <= alu_outp;
                        mem_wr <= '0';
                        mem_addr <= alu_outp(5 downto 0);
                        if state(3 downto 0) = "0000" then
                            state(7 downto 4) <= "0100";
                        elsif state(3 downto 0) = "0101" then
                            state(7 downto 4) <= "1000";
                        elsif state(3 downto 0 )<= "0111" then
                            state(7 downto 4) <= "1001";
                        end if;
                        ct <= '0';
                    end if;
                    
                elsif state(7 downto 4) = "1000" then
                    if ct= '0' then
                        t2 <= mem_d_out;
                        reg_d3 <= mem_d_out;
                        reg_a3 <= IR(11 downto 9);
								reg_wr <= '1';
                        ct<='1';
                    else
                        ct<='0';
                        if state(3 downto 0) = "0101" then
                            state(7 downto 4) <= "0101";
                        end if;
								reg_wr <= '0';
                        
                    end if;

                elsif state(7 downto 4) = "1001" then
                    if ct = '0' then
                        mem_d_in <= reg_d2;
                        mem_wr <= '1';
                        reg_wr <= '1';
                        reg_d3 <= std_logic_vector(PC);
                        reg_a3 <= "111";
                        ct <= '1';
                    else
                        ct <= '0';
                        mem_wr <= '0';
                        reg_wr <= '0'; 
                        state(7 downto 4) <= "0001";    
                    end if;

                elsif state(7 downto 4) = "1010" then
                    if ct= '0' then
                        t2 <= mem_d_out;
                        ct<='1';
                    else
                        ct <= '0';
                        if state(3 downto 0) = "1101" then
                            state(7 downto 4) <= "1011";
                        end if;
                
                    end if;
                
                
                
                elsif state(7 downto 4) = "1011" then
                    if ct= '0' and valid_pe = '1' then
                        reg_d3 <= t2;
                        reg_a3 <= output_pe;
								input_pe <= next_input_pe;
                        t1 <= std_logic_vector(unsigned(t1) + 1);                       
                        reg_wr<='1';
                        ct<='1';
                    else
                        ct<='0';
                        reg_wr<='0';
								mem_addr <= t1(5 downto 0);
                        if valid_pe = '0' then
                            state(7 downto 4) <= "0101";
                        else
                            state(7 downto 4) <= "1010";
                        end if;
                
                    end if;
                
                elsif state(7 downto 4) = "1100" then
                    if ct = '0' then
                        reg_a2 <= output_pe;
								input_pe <= next_input_pe;
                        mem_addr <= t1(5 downto 0);
                        ct<='1';
                        --Why is only address being assigned here?
                    else
                        ct <= '0';
								mem_d_in <= reg_d2;
								mem_wr <= '1';
                        if state(3 downto 0) <= "1100" then
                            state(7 downto 4) <= "1101";
								end if;
						  end if;

                elsif state(7 downto 4) = "1101" then
                    if ct= '0' then
								if valid_pe = '1'then
									t1 <= std_logic_vector(unsigned(t1) + 1);
								end if;
								mem_wr <= '0';
                        ct<='1';
                    else
                        ct<='0';
                        if valid_pe = '0' then
                            state(7 downto 4) <= "0101";
                        else
                            state(7 downto 4) <= "1100";
                        end if;

                    end if;


                elsif state(7 downto 4) = "1110" then
                    if ct= '0' then
                        reg_a1 <= "111";
                        ct <= '1';
                    else
                        ct<='0';
                        Inp_alu_a <= reg_d1;
                        if IR(5) = '1' then 
                            Inp_alu_b <= "1111111111"&IR(5 downto 0);
									 PC := unsigned(reg_d1) + unsigned("1111111111"&IR(5 downto 0)) - 1;
                        else
                            Inp_alu_b <= "0000000000"&IR(5 downto 0);
									 PC := unsigned(reg_d1) + unsigned("0000000000"&IR(5 downto 0)) - 1;
                        end if;
                        
                        state(7 downto 4) <= "0101";
                    end if;
                
                elsif state(7 downto 4) = "1111" then
                    if ct= '0' then
								if state(3 downto 0) = "1001" then
									reg_d3 <= std_logic_vector(PC);
									reg_a3 <= IR(11 downto 9);
									reg_a1 <= "111";
									reg_wr <= '1';
								else
									reg_a1 <= IR(11 downto 9);
									reg_wr <= '0';
								end if;                        
                        ct <= '1';
                    else
                        reg_wr <= '0';
                        Inp_alu_a <= reg_d1;
                        if IR(8) = '1' then 
                            Inp_alu_b <= "1111111"&IR(8 downto 0);
									 PC := unsigned(reg_d1) + unsigned("1111111"&IR(8 downto 0)) - 1;
                        else
                            Inp_alu_b <= "0000000"&IR(8 downto 0);
									 PC := unsigned(reg_d1) + unsigned("0000000"&IR(8 downto 0)) - 1;
                        end if;
								if state(3 downto 0) = "1011" then
									PC := PC +1 ;
								end if;
                        ct<='0';
                        state(7 downto 4) <= "0001";
                    end if;
                
                
                
                elsif state(7 downto 4) = "0000" then
                    if ct= '0' then
								reg_a1 <= IR(8 downto 6);
                        reg_a3 <= IR(11 downto 9);
                        reg_d3 <= std_logic_vector(PC);
                        ct <= '1';
                        reg_wr<='1';
                    else
                        ct<='0';
								PC := unsigned(reg_d1);

                        reg_wr<='0';
                        
                        state(7 downto 4) <= "0001";
                        
                    end if;
                end if;
            end if;    
        end if;
    end process;
	 kill <= sigkill;
end architecture;