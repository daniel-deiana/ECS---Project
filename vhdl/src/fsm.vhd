-- edgeDetector.vhd
-- Moore and Mealy Implementation

library ieee;
use ieee.std_logic_1164.all; 

entity fsm is
    generic(
        -- generics 
        image_width : natural := 16;
        filter_width : natural := 4;
        );
    port(
        -- inputs
        clk, reset : in std_logic;
        i_f :        in std_logic; 
        x_valid :    in std_logic;
        x :          in std_logic_vector(7 downto 0);
        -- outputs
        y_valid :    out std_logic;
        y :          out std_logic_vector(7 downto 0);
        );
end fsm;

architecture arch of fsm is 

    -- State values
    -- S0, S1, S2, S3, W0, W1, PAD0, PAD1
    
    type state_type is (S0, S1, S2, S3, W0, W1); 
    signal state_reg, state_next : state_type;

    -- counter 
    signal COUNT : std_logic_vector()

begin   

    -- State register sequential logic 
    process(clk, reset)
    begin
        if (reset = '1') then 
            state_reg <= S0;
        elsif (clk'event and clk = '1') then 
            state_reg <= state_next;
        else
            null;
        end if; 
    end process;
    
    -- COUNT register sequential logic
    process(clk, reset, state_reg)
    begin 
        if (reset = '1') then
            COUNT <= image_width**2;
        elsif(clk'event and clk = '1' ) then
            COUNT <= COUNT - 1;
        else 
            null;
        end if;
    end process;

    -- combinatorial state logic 
    process(state_reg,x_valid,COUNT)
    begin 
            -- store current state as next
            state_next <= state_reg; -- required: when no case statement is satisfied
            
            case state_reg is 
                
            when S0 =>
                -- S0 logic         
                    if (x_valid = '1' and i_f = '1') then 
                        state_next <= S1; 
                    end if;
                -- end S0 
                
            when S1 => 
                -- S1 logic
                    if (x_valid = '0') then 
                        state_next <= W0;
                    elsif (COUNT = '0') then
                        COUNT <= filter_width**2;
                        state_next <= S2;
                    end if;
                -- end S1
                
            when S2 =>
                -- S2 logic
                    if (x_valid = '0') then 
                        state_next <= W1;
                    elsif (COUNT = '0') then 
                        state_next <= S3;
                    end if;
                -- end S2
                
            when S3 =>
                -- S3 logic 
                    if (COUNT_OP = '0') then
                        state_next <= S0;
                    end if;
                -- end S3
    
            when W0 =>
                -- W0 logic
                    if (x_valid = '1') then
                        state_next <= S1;
                    end if;
                -- end W0

            when W1 =>
                -- W1 logic
                    if (x_valid = '1') then
                        state_next <= S2;
                    end if;
                -- end W1
                end case; 
        end process;

end architecture; 
        
