library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

entity mux_7seg is
    Port ( --bcd_unidades : in STD_LOGIC_VECTOR (3 downto 0);
           --bcd_dezenas : in STD_LOGIC_VECTOR (3 downto 0);
           --bcd_centenas : in STD_LOGIC_VECTOR (3 downto 0);
           --bcd_milhares : in STD_LOGIC_VECTOR (3 downto 0);
           clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC);
end mux_7seg;

architecture Behavioral of mux_7seg is

    component driver_bcd_7seg
        Port ( sw : in STD_LOGIC_VECTOR (3 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0));
    end component;
    
    signal clk_dividido: STD_LOGIC:='0';
    signal counter: integer range 1 to 100_000 := 1;
    signal seletor_display: integer range 1 to 4:=1;
    signal s_an, bcd_now : STD_LOGIC_VECTOR (3 downto 0);
    signal bcd_unidades : STD_LOGIC_VECTOR (3 downto 0);
    signal bcd_dezenas : STD_LOGIC_VECTOR (3 downto 0);
    signal bcd_centenas : STD_LOGIC_VECTOR (3 downto 0);
    signal bcd_milhares : STD_LOGIC_VECTOR (3 downto 0);
    
begin

    ------------------------------
    ---- Divisor de clock----
    ------------------------------
    divisor_clk: process(clk)
    begin
    
        if rising_edge(clk) then
            if counter = 50_000_000 then
                counter <= 1;
                clk_dividido <= not clk_dividido;
            else
                counter <= counter + 1;
            end if; 
        end if;
        
    end process;
    
    ---------------------------------------
    ---- Multiplexação dos displays-----
    ---------------------------------
    multiplexacao: process (clk_dividido)
    begin
        if rising_edge(clk_dividido) then
            
            if bcd_unidades < "1001" then
                bcd_unidades <= bcd_unidades + 1;
            elsif bcd_dezenas < "0110" then
                bcd_unidades <= "0000";
                bcd_dezenas <= bcd_dezenas + 1;
            elsif bcd_centenas <= "1001" then
                bcd_unidades <= "0000";
                bcd_dezenas <= "0000";
                bcd_centenas <= bcd_centenas + 1;
            end if;
                    
            case seletor_display is
                when 1 => s_an <= "1110"; bcd_now <= bcd_unidades;
                when 2 => s_an <= "1101"; bcd_now <= bcd_dezenas;
                when 3 => s_an <= "1011"; bcd_now <= bcd_centenas;
                when 4 => s_an <= "0111"; bcd_now <= bcd_milhares;
                when others => null;
            end case;            
            seletor_display <= seletor_display + 1;            
        end if;
    end process;
    
    an <= s_an;
    dr_bcd: driver_bcd_7seg port map(sw =>bcd_now, seg=>seg);
    dp <='1';
    
end Behavioral;