library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock1 is 
	port (
		clk 	: in std_logic;
		SEG 	: out std_logic_vector (6 downto 0) := (others => '1');
		DOT	: out std_logic := '1';
		DIG1 	: out std_logic := '0';
		DIG2 	: out std_logic := '0';
		DIG3 	: out std_logic := '0';
		DIG4 	: out std_logic := '0';
		led1	: out std_logic := '1';
		led2	: out std_logic := '1';
		led3	: out std_logic := '1';
		led4	: out std_logic := '1';
		btn1  : in  std_logic := '1';
		btn2  : in  std_logic := '1';
		btn3  : in  std_logic := '1';
		btn4  : in  std_logic := '1';
		nRes	: in  std_logic := '1');
	constant CLOCK_MHZ 	: integer := 50;	
	constant TICKS 		: integer := 25_000_00;
end entity;

architecture rtl of clock1 is

	signal x1,x2,x3,x4 : std_logic := '0';
	

	function GetNumber (	Digit : integer := 0) return std_logic_vector is
	begin
		case Digit is 
			when 1 	=> return "1111001";
			when 2 	=> return "0100100";
			when 3 	=> return "0110000";
			when 4 	=> return "0011001";
			when 5 	=> return "0010010";
			when 6 	=> return "0000010";
			when 7 	=> return "1011000";
			when 8 	=> return "0000000";
			when 9	=> return "0010000";
			when 0 	=> return "1000000";
			when 10	=> return "1111111";
		
			when others => return  "XXXXXXX";
		end case;
	end function;
	
	procedure LedSeconds (seconds : integer) is
	begin
		if seconds >=12 and seconds < 24 then
			led1 <= '0';
		elsif seconds >=24 and seconds < 36 then
			led2 <= '0';
		elsif seconds >= 36 and seconds < 48 then
			led3 <= '0';
		elsif seconds >= 48 and seconds < 59 then
			led4 <= '0';
		else 
			led1 <= '1';
			led2 <= '1';
			led3 <= '1';
			led4 <= '1';
		end if;

	end procedure;
								


	signal ct  : unsigned (1 downto 0) := "00";
	signal wt  : unsigned (15 downto 0) := (others => '0');
	signal sec : std_logic := '0';

	shared variable d1 : integer range 0 to 255 := 0;
	shared variable d2 : integer range 0 to 255 := 0;
	shared variable d3 : integer range 0 to 255 := 0;
	shared variable d4 : integer range 0 to 255 := 0;
	shared variable dot_on : std_logic := '1';
	
begin

	deb1 : entity work.debounce(logic) 
		port map (
			clk => clk,
			reset_n => nRes,
			button => btn1,
			result => x2);
	deb2 : entity work.debounce(logic) 
		port map (
			clk => clk,
			reset_n => nRes,
			button => btn2,
			result => x1);
		
	
	sec_counter: process(clk)
		variable counter : integer := TICKS;
	begin
		if rising_edge(clk) then
			counter := counter - 1;
			if counter = 0 then
				counter := TICKS;
				sec <= not sec;
			end if;
		end if;
	end process;
	
	
	tick_clock: process(nRes, sec) 
		variable seconds : integer range 0 to 255 := 0;
		variable msSec   : integer range 0 to 255 := 0;
		variable min : integer range 0 to 255 := 0;
		variable hour : integer range 0 to 255 := 0;
	begin
		if (nRes = '0') then
			d1 := 0;
			d2 := 0;
			d3 := 0;
			d4 := 0;
			seconds := 0;
		elsif (rising_edge(sec)) then
		
			if x1 = '0' then	
				min := min+1;
				if (min > 59) then
					min := 0;
				end if;
			end if;	
			
			if x2 = '0' then	
				hour := hour + 1;
				if (hour > 23) then
					hour := 0;
				end if;
			end if;	
			
			msSec := msSec + 1;
			if (msSec = 10) then
				seconds := seconds + 1;	
				msSec := 0;
				dot_on := not dot_on;
			end if;

			
			LedSeconds(seconds);
		
			if seconds = 60 then
				seconds := 0;
				dot_on := not dot_on;
				min := min + 1;
				if min > 59 then
					min := 0;
					hour := hour + 1;
					if hour > 23 then
						hour := 0;
					end if;
				end if;
			end if;
-- convert decimal h/min to two digits
--		d4 := hour mod 10;

		d2 := min / 10;
		d1 := min - d2*10;
		
		d4 := hour / 10;
		d3 := hour - d4*10;
		
--		d1 := min  rem 10;
--		d2 := (min - d1) / 10;
		
--		d3 := hour rem 10;
--		d4 := (hour - d3) / 10;
		


		end if;
	end process;
	

	proc1 : process(clk)

	begin
		if rising_edge(clk) then
		
			wt <= wt + 1;
			
			if wt = "0000000000000000" then
				
				ct <= ct +1;
				case ct is
					when "11" => --leftmost one
						DIG1 <= '1';
						DIG2 <= '1';
						DIG3 <= '1';
						DIG4 <= '0';
						SEG <= GetNumber(d4);
						DOT <= '1';
					when "10" =>
						DIG1 <= '1';
						DIG2 <= '1';
						DIG3 <= '0';
						DIG4 <= '1';
						SEG <= GetNumber(d3);
						DOT <= dot_on;
					when "01" =>
						DIG1 <= '1';
						DIG2 <= '0';
						DIG3 <= '1';
						DIG4 <= '1';
						SEG <= GetNumber(d2);						
						DOT <= '1';
					when "00" => 
						DIG1 <= '0';
						DIG2 <= '1';
						DIG3 <= '1';
						DIG4 <= '1';
						SEG <= GetNumber(d1);
						DOT <= '1';


				end case;
			end if;
		end if;
	end process;

end rtl;




