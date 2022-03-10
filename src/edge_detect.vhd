--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*****************************************************************************
--
--  DESIGNER NAME:  Bruce Link
--
--      FILE NAME:  edge_detect.vhd
--
-- ============================================================================
--
-- DESCRIPTION 
--     
--     This files contains the code that will accept an active high signal
--     and then create a pulse when the rising edge of that input signal
--     is detected.
--
--
--     All variables/signals that end with "_n" are low active.
--     All identifiers that end with "_t" are user defined types
--     All identifiers that end with "_c" are user defined constants
--
--
--
--*****************************************************************************
--*****************************************************************************


------------------------------------------------------------------------------
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- |||| 
-- |||| COMPONENT PACKAGE
-- |||| 
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE edge_detect_pkg IS
  COMPONENT edge_detect
    PORT (
      clock       : IN  std_logic;
      reset_n     : IN  std_logic;
      DataIn      : IN  std_logic;
      --
      RisingEdge  : OUT std_logic;
      FallingEdge : OUT std_logic
      );
  END COMPONENT edge_detect;
END PACKAGE edge_detect_pkg;



------------------------------------------------------------------------------
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- |||| 
-- |||| COMPONENT DESCRIPTION 
-- |||| 
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY edge_detect IS
  PORT (
    clock       : IN  std_logic;
    reset_n     : IN  std_logic;
    DataIn      : IN  std_logic;
    --
    RisingEdge  : OUT std_logic;
    FallingEdge : OUT std_logic
    );
END ENTITY edge_detect;

ARCHITECTURE behave OF edge_detect IS

  SIGNAL PrevDataIn1 : std_logic;
  SIGNAL PrevDataIn2 : std_logic;

BEGIN

  --*************************************************************************
  --** Name: RisingEdgeDetector
  --**
  --** Description:
  --**    This process will register the input twice. The output of these
  --**    two register are used to detect the rising edge of a signal.
  --*************************************************************************
  RisingEdgeDetector : PROCESS (reset_n, clock)
  BEGIN
    IF (reset_n = '0') THEN
      PrevDataIn1 <= '0';
      PrevDataIn2 <= '0';
      RisingEdge  <= '0';
      FallingEdge <= '0';
    ELSIF (clock'event AND clock = '1') THEN
      PrevDataIn1 <= DataIn;
      PrevDataIn2 <= PrevDataIn1;
      RisingEdge  <= ((NOT PrevDataIn2) AND PrevDataIn1);
      FallingEdge <= (PrevDataIn2 AND (NOT PrevDataIn1));
    END IF;
  END PROCESS RisingEdgeDetector;



END ARCHITECTURE behave;
