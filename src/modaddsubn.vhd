----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial 
-- Sibenik, June 11-15, 2018 
-- 
-- Author: Nele Mentens
-- Updated by Pedro Maat Costa Massolino
--  
-- Module Name: modaddsubn
-- Description: n-bit modular adder/subtracter
----------------------------------------------------------------------------------

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

-- describe the interface of the module
-- if as = '0': sum = a + b
-- if as = '1': sum = a - b 
entity addsubn is
    generic(
        n: integer := 8);
    port(
        a, b: in std_logic_vector(n-1 downto 0);
        as: in std_logic;
        sum: out std_logic_vector(n-1 downto 0));
end addsubn;

-- describe the behavior of the module in the architecture
architecture behavioral of addsubn is

-- declare internal signals
signal as_vec, b_as: std_logic_vector(n-1 downto 0);

begin

-- assign as to each bit of as_vec
as_vec <= (others => as);

-- perform a bitwise XOR of b and as_vec
-- if as = '0': b_as = b
-- if as = '1': b_as = not(b)
b_as <= b xor as_vec;

-- add a to b or not(b)
-- if as = '1': add 1 to the sum
--
-- we cannot convert std_logic to unsigned, therefore we use the as_vec to be able to get the one bit of as.
sum <= std_logic_vector(unsigned(a) + unsigned(b_as) + unsigned(as_vec(0 downto 0)));

end behavioral;
-- describe the interface of the module
-- if as = '0': sum = (a + b) mod p
-- if as = '1': sum = (a - b) mod p 

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

entity modaddsubn is
    generic(
        n: integer := 8);
    port(
        a, b, p: in std_logic_vector(n-1 downto 0);
        as: in std_logic;
        sum: out std_logic_vector(n-1 downto 0));
end modaddsubn;

-- describe the behavior of the module in the architecture
architecture behavioral of modaddsubn is

-- declare internal signals
signal a_long, b_long, p_long, c, d: std_logic_vector(n downto 0);
signal as_not: std_logic;

-- declare the addsubn component
component addsubn
    generic(n: integer := 8);
    port(   a, b: in std_logic_vector(n-1 downto 0);
            as: in std_logic;
            sum: out std_logic_vector(n-1 downto 0));
end component;

begin

-- extend a and b with one bit because the "+" and "-" components expect the inputs and output to be of equal length 
a_long <= '0' & a;
b_long <= '0' & b;
p_long <= '0' & p;

-- invert as
as_not <= not as;

-- instantiate the first addsubn component
-- map the generic parameter in the top design to the generic parameter in the component  
-- map the signals in the top design to the ports of the component
inst_addsubn_1: addsubn
    generic map(n => n+1)
    port map(   a => a_long,
                b => b_long,
                as => as,
                sum => c);

-- instantiate the second addsubn component
-- map the generic parameter in the top design to the generic parameter in the component  
-- map the signals in the top design to the ports of the component
inst_addsubn_2: addsubn
    generic map(n => n+1)
    port map(   a => c,
                b => p_long,
                as => as_not,
                sum => d);

-- in the case of a modular addition, assign d to the sum output if d is a positive number
-- in the case of a modular addition, assign c to the sum output if d is a negative number
-- in the case of a modular subtraction, assign c to the sum output if c is a positive number
-- in the case of a modular subtraction, assign d to the sum output if c is a negative number
-- leave the MSB out of the assignment because it is always '0'
mux: process(as, c, d)
begin
    if as = '0' then
        if d(n) = '0' then
            sum <= d(n-1 downto 0);
        else
            sum <= c(n-1 downto 0);
        end if;
    else
        if c(n) = '0' then
            sum <= c(n-1 downto 0);
        else
            sum <= d(n-1 downto 0);
        end if;
    end if;
end process;

end behavioral;
