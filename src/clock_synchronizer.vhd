--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*****************************************************************************
--
--  DESIGNER NAME:  Bruce Link
--
--      FILE NAME:  clock_synchronizer.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--    This files contains the code that will take an input as a signal 
--    and a clock reference. The signal will then be registered 2 times 
--    and sent to the output port. This file is helpful in synchronizing 
--    asynchronous inputs (ie: user inputs from switches etc.). A generic
--    is provided to allow buses to be synchronized.
--
--    All variables/signals that end with "_n" are low active.
--    All identifiers that end with "_t" are user defined types
--    All identifiers that end with "_c" are user defined constants
--
--
--*****************************************************************************
--*****************************************************************************


------------------------------------------------------------------------------
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- ||||                                                                   ||||
-- ||||                    COMPONENT PACKAGE                              ||||
-- ||||                                                                   ||||
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE clock_synchronizer_pkg IS
  COMPONENT clock_synchronizer IS
    GENERIC (
      bit_width : integer := 8
      );
    PORT (
      clock    : IN  std_logic;
      reset_n  : IN  std_logic;
      async_in : IN  std_logic_vector(bit_width-1 DOWNTO 0);
      --
      sync_out : OUT std_logic_vector(bit_width-1 DOWNTO 0)
      );
  END COMPONENT clock_synchronizer;
  
END PACKAGE clock_synchronizer_pkg;



------------------------------------------------------------------------------
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- ||||                                                                   ||||
-- ||||                    COMPONENT DESCRIPTION                          ||||
-- ||||                                                                   ||||
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY clock_synchronizer IS
  GENERIC (
    bit_width : integer := 12
    );
  PORT (
    clock    : IN  std_logic;
    reset_n  : IN  std_logic;
    async_in : IN  std_logic_vector(bit_width-1 DOWNTO 0);
    --
    sync_out : OUT std_logic_vector(bit_width-1 DOWNTO 0)
    );
END clock_synchronizer;

ARCHITECTURE behav OF clock_synchronizer IS

  SIGNAL prev_data_1 : std_logic_vector(bit_width-1 DOWNTO 0);
  SIGNAL prev_data_2 : std_logic_vector(bit_width-1 DOWNTO 0);

BEGIN

  --*************************************************************************
  --** Name: RisingEdgeDetector
  --**
  --** Description:
  --**    This process implements the double D-FF clock sync circuit
  --*************************************************************************
  double_flop : PROCESS(reset_n, clock)
  BEGIN
    IF (reset_n = '0') THEN
      prev_data_1 <= (OTHERS => '0');
      prev_data_2 <= (OTHERS => '0');
    ELSIF rising_edge(clock) THEN
      prev_data_1 <= async_in;
      prev_data_2 <= prev_data_1;
    END IF;
  END PROCESS;

  sync_out <= prev_data_2;

END behav;
