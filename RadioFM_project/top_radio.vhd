--Simple FM Transmitter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fm_xmit is
    Port ( clk_in : in  STD_LOGIC;
           antenna, led : out  STD_LOGIC);
end fm_xmit;

architecture Behavioral of fm_xmit is
		component clk_wiz_v3_6 is
		port
		 (-- Clock in ports
		  CLK_IN1           : in     std_logic;
		  -- Clock out ports
		  CLK_OUT1          : out    std_logic;
		  -- Status and control signals
		  RESET             : in     std_logic;
		  LOCKED            : out    std_logic
		 );
		end component;
   
   signal clk320            : std_logic;
	signal rst_in				 : std_logic;
	signal locked_int			 : std_logic;
   signal shift_ctr         : unsigned (1	downto 0) := (others => '0');
   signal phase_accumulator : unsigned (31 downto 0) := (others => '0');
   signal beep_counter      : unsigned (23 downto 0):= (others => '0'); -- gives a 305Hz beep signal
-- signal message        : std_logic_vector(33 downto 0) := "1111100011101110111000111110000000";
   signal code					 : unsigned (4 downto 0) := (others => '0');
	signal message_id 		 : unsigned (1 downto 0) := (others => '0');
--	signal message			    : std_logic_vector(33 downto 0) := "0000000000000000000000000000000000";
--	signal message  		    : std_logic_vector(33 downto 0) := "0101010101010101010101010101010101";
-- signal message  		    : std_logic_vector(135 downto 0):= "0101010101010101010101010101010101110011001100110011001100110011001111110000111100001111000011110000001010111010101110101011101010111010";
																				--	 1100110011001100110011001100110011
																				--	 1111000011110000111100001111000000
																				--	 1010111010101110101011101010111010
   signal message  		    : std_logic_vector(135 downto 0):= "0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101011111";

begin
   led<='1'; --led 0 acceso
	antenna <= std_logic(phase_accumulator(31));

  clknetwork : clk_wiz_v3_6
  port map
   (-- Clock in ports 
    CLK_IN1            => clk_in,
    -- Clock out ports
    CLK_OUT1           => clk320,
    -- Status and control signals
    RESET              => rst_in,
    LOCKED             => locked_int);


   process(clk320)
   begin
      if rising_edge(clk320) then
         if beep_counter = x"FFFFFF" then
            if shift_ctr = "00" then
               message <= message(0) & message(135 downto 1);
            end if;
            shift_ctr <= shift_ctr + 1;
         end if;      
         
         -- The constants are calculated as (desired freq)/320Mhz*2^32
         if message(0) = '1' then
            if (beep_counter(17) = '1') and (beep_counter(18) = '1')and (beep_counter(19) = '1') then
               phase_accumulator <= phase_accumulator + 1222387958; -- gives a 91075kHz signal               
            else
               phase_accumulator <= phase_accumulator + 1220374692; -- gives 90925kHz signal
            end if;
         else 
            phase_accumulator <= phase_accumulator + 1221381325; -- gives 91000kHz signal
         end if;
         
         beep_counter <= beep_counter+1;
      end if;
   end process;
end Behavioral;

