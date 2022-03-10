--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*****************************************************************************
--
--  DESIGNER NAME:  Tessa Vincent
--
--      FILE NAME:  delayregister.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--    This file includes the delay register
--
--*****************************************************************************
--*****************************************************************************

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE reg_delay_pkg IS 
  COMPONENT reg_delay
    GENERIC (
      ResetValue : std_logic := '0';
      DelaySize  : integer   := 4
      );
    
    PORT (
      clock : IN std_logic;
      reset_n : IN std_logic;
      data_in : IN std_logic;
      --
      data_out : OUT std_logic
      );
  END COMPONENT;
END reg_delay_pkg;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reg_delay IS 
  GENERIC (
    ResetValue : std_logic := '0';
    DelaySize  : integer   := 4
    );
    
    PORT (
      clock : IN std_logic;
      reset_n : IN std_logic;
      data_in : IN std_logic;
      --
      data_out : OUT std_logic
      );
      
END ENTITY reg_delay;

ARCHITECTURE behave OF reg_delay IS 
  SIGNAL shift_register : std_logic_vector(DelaySize-1 DOWNTO 0);
  
BEGIN 
  delay : PROCESS(reset_n, clock)
  BEGIN
    IF(reset_n ='0') THEN 
      shift_register <= (OTHERS => ResetValue);
    ELSIF(clock'EVENT AND clock = '1') THEN 
      shift_register(0) <= data_in;
      
      IF(DelaySize > 1) THEN 
        shift_register(DelaySize-1 DOWNTO 1) <=
          shift_register(DelaySize-2 DOWNTO 0);
      END IF;
    END IF;
  END PROCESS delay;
  
  data_out <= shift_register(DelaySize-1);
  
 END ARCHITECTURE behave;