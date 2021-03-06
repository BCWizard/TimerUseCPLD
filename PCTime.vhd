LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY PCTime IS
	PORT
	(	
		CLK_4MHZ:IN STD_LOGIC;						--石英震盪器4MHZ
		CLK_160HZ:BUFFER STD_LOGIC;
		CLK_1HZ:BUFFER STD_LOGIC;					
		BUZZER:OUT STD_LOGIC;
		SWITCH:IN STD_LOGIC;
		SWITCH7D:IN STD_LOGIC;
		LEDDATAo:OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	--LED資料線輸出
		SCAN:OUT STD_LOGIC_VECTOR(3 DOWNTO 0)		--LED掃描線輸出
	);
END PCTime;

ARCHITECTURE BCWizard OF PCTime IS

SIGNAL N2,N0: INTEGER RANGE 0 TO 9 :=0;
SIGNAL N3,N1: INTEGER RANGE 0 TO 5 :=0;		

SIGNAL DCBA: INTEGER RANGE 0 TO 9;				
SIGNAL S: INTEGER RANGE 0 TO 3;	
	
Begin

Frequency160HZ:PROCESS(CLK_4MHZ)			
	VARIABLE CS: INTEGER RANGE 0 TO 6250 :=1;
    BEGIN
		IF(CLK_4MHZ'event and CLK_4MHZ='1') then	
		CS:=CS+1;								
			IF CS=6250 THEN			
			CLK_160HZ <=not CLK_160HZ;			
			CS:=0;
			END IF;
		END IF;
   END PROCESS;
   
Frequency1HZ:PROCESS(CLK_160HZ,CLK_1HZ)			
	VARIABLE CS: INTEGER RANGE 0 TO 160 :=1;
    BEGIN
		IF(CLK_160HZ'event and CLK_160HZ='1') then	
		CS:=CS+1;								
			IF CS=160 THEN			
			CLK_1HZ <=not CLK_1HZ;			
			CS:=0;
			END IF;
		END IF;
   END PROCESS;
   
--FrequencyTest1HZ:PROCESS(CLK_4MHZ)			
--	VARIABLE CS: INTEGER RANGE 0 TO 2000000 :=1;
--    BEGIN
--		IF(CLK_4MHZ'event and CLK_4MHZ='1') then	
--		CS:=CS+1;								
--			IF CS=2000000 THEN			
--			CLK_1HZ <=not CLK_1HZ;			
--			CS:=0;
--			END IF;
--		END IF;
--   END PROCESS;

UpTime:PROCESS(CLK_1HZ)
BEGIN
IF SWITCH='0' then
	N0<=0; N1<=0; N2<=0; N3<=0;
	ELSIF Rising_edge(CLK_1HZ) Then
	--SEC
		IF N0/=9 THEN		
			N0<=N0+1;						
		ELSIF N1/=5 THEN	--N0 IS 9,BUT N1 ISN'T 5
		
			N0<=0;				
			N1<=N1+1;
		ELSE
			N0<=0;
			N1<=0;
			N2<=N2+1;
		END IF;
	--MIN
		IF N2=9 AND N1=5 AND N0=9 THEN		
			N2<=0;
			N3<=N3+1;
		ELSIF N3=6 THEN
			N0<=0; N1<=0; N2<=0; N3<=0;					
		END IF;
	END IF;

--IF Rising_edge(CLK_1HZ) Then
--	--SEC
--		IF N0/=9 THEN		
--			N0<=N0+1;						
--		ELSIF N1/=5 THEN	--N0 IS 9,BUT N1 ISN'T 5
--		
--			N0<=0;				
--			N1<=N1+1;
--		ELSE
--			N0<=0;
--			N1<=0;
--			N2<=N2+1;
--		END IF;
--	--MIN
--		IF N2=9 THEN		
--			N2<=0;
--			N3<=N3+1;
--		ELSIF N3=6 THEN
--			N0<=0; N1<=0; N2<=0; N3<=0;					
--		END IF;
--	END IF;
	
	IF Rising_edge(CLK_160HZ) Then		
		S<=S+1;
	END IF;
	
	CASE S IS						
		WHEN 0 => SCAN <= "1110"; DCBA <=N0;
		WHEN 1 => SCAN <= "1101"; DCBA <=N1;
		WHEN 2 => SCAN <= "1011"; DCBA <=N2;
		WHEN 3 => SCAN <= "0111"; DCBA <=N3;
	END CASE;
	
	IF SWITCH7D='1' THEN
		SCAN <="1111";
	END IF;
	
END PROCESS;

BUZZERcontrol:PROCESS(CLK_160HZ,CLK_1HZ)			
BEGIN
	IF N3>2 then	
		BUZZER<='0';
	ELSE
		BUZZER<='1';		
	END IF;
END PROCESS;

--RESET:PROCESS(CLK_160HZ,CLK_1HZ)			
--BEGIN
--	IF SWITCH='1' then	
--		N0<=0; N1<=0; N2<=0; N3<=0;
--	END IF;
--END PROCESS;

WITH DCBA SELECT		
	LEDDATAo <= "1101111" WHEN 9, 		--gfe dcba
				"1111111" WHEN 8,
				"0000111" WHEN 7,
				"1111101" WHEN 6,
				"1101101" WHEN 5,
				"1100110" WHEN 4,
				"1001111" WHEN 3,
				"1011011" WHEN 2,
				"0000110" WHEN 1,
				"0111111" WHEN OTHERS;

END BCWizard;