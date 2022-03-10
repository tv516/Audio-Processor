--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*****************************************************************************
--
--  DESIGNER NAME:  Tessa Vincent
--
--       LAB NAME:  -- Lab 9: DJ Roomba 3000 
--
--      FILE NAME: dj_romba_3000
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--
--    This design will be building a simple audio processor 
--
--
-------------------------------------------------------------------------------
--
--  REVISION HISTORY
--
--  _______________________________________________________________________
-- |  DATE    | USER | Ver |  Description                                  |
-- |==========+======+=====+================================================
-- |          |      |     |
-- | 08/23/20 | XXX  | 1.0 | Created
-- |          |      |     |
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
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE dj_roomba_3000_pkg IS
  COMPONENT dj_roomba_3000 IS 
    PORT(
      clk                 : IN std_logic;
      reset               : IN std_logic;
      execute_btn         : IN std_logic;
      sync                : IN std_logic;
      --
      led                 : OUT std_logic_vector(7 DOWNTO 0);
      audio_out           : OUT std_logic_vector(15 DOWNTO 0)
      );
    END COMPONENT;
END PACKAGE dj_roomba_3000_pkg;
------------------------------------------------------------------------------
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- |||| 
-- |||| COMPONENT DESCRIPTION 
-- |||| 
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY work;
USE work.clock_synchronizer_pkg.ALL;
USE work.edge_detect_pkg.ALL;
USE work.reg_delay_pkg.ALL;

ENTITY dj_roomba_3000 IS 
  PORT(
    clk                 : IN std_logic;
    reset               : IN std_logic;
    execute_btn         : IN std_logic;
    sync                : IN std_logic;
    --
    led                 : OUT std_logic_vector(7 DOWNTO 0);
    audio_out           : OUT std_logic_vector(15 DOWNTO 0)
  );
END dj_roomba_3000;

ARCHITECTURE beh OF dj_roomba_3000 IS

  -- Instruction Memory
  COMPONENT rom_instructions
    PORT(
      address    : IN std_logic_vector (4 DOWNTO 0);
      clock      : IN std_logic  := '1';
      q          : OUT std_logic_vector (7 DOWNTO 0)
    );
  END COMPONENT;
  
  -- Data Memory
  COMPONENT rom_data
    PORT(
      address  : IN std_logic_vector (13 DOWNTO 0);
      clock    : IN std_logic  := '1';
      q        : OUT std_logic_vector (15 DOWNTO 0)
    );
  END COMPONENT;
  
  ---------------------------------------------------------------------------
  -- Defines the encoding of the state machine
  ---------------------------------------------------------------------------
  TYPE state_type_t IS (IDLE,FETCH,DECODE,EXECUTE,ERROR);
  
  ATTRIBUTE syn_encoding  : strINg;
  ATTRIBUTE syn_encoding OF state_type_t : type IS "gray, Safe";
  
  SIGNAL PresentState   : state_type_t;
  SIGNAL NextState      : state_type_t;
 ---------------------------------------------------------------------------
  -- Define your signals here
  -- Format: signal abc : <type>;
  ---------------------------------------------------------------------------
  CONSTANT  MAX_COUNT_C     : integer := 31;        
  SIGNAL data_address       : std_logic_vector(13 DOWNTO 0);
  SIGNAL instr_addr         : std_logic_vector(4 DOWNTO 0);
  SIGNAL seek_offset        : std_logic_vector(4 DOWNTO 0);
  SIGNAL seek_off_reg       : std_logic_vector(4 DOWNTO 0);
  SIGNAL instr_bus          : std_logic_vector(7 DOWNTO 0);
  SIGNAL instr_reg          : std_logic_vector(7 DOWNTO 0);
  SIGNAL count_sig          : integer RANGE 0 to MAX_COUNT_C := 0;
  SIGNAL execute_instr_en   : std_logic;
  SIGNAL exe_pb_sync_n      : std_logic;
  SIGNAL instr_cntr_en      : std_logic;
  SIGNAL instr_fetch_en     : std_logic;
  SIGNAL play_cmd           : std_logic;
  SIGNAL repeat_cmd         : std_logic;
  SIGNAL seek_cmd           : std_logic;
  SIGNAL stop_cmd           : std_logic;
  SIGNAL pause_cmd          : std_logic;
  SIGNAL valid_command      : std_logic;
  SIGNAL play_reg           : std_logic;
  SIGNAL repeat_reg         : std_logic;
  SIGNAL seek_reg           : std_logic;
  SIGNAL stop_reg           : std_logic;
  SIGNAL pause_reg          : std_logic;
  
  
  -- Constants for command decoding
  CONSTANT play_c       : std_logic_vector(1 DOWNTO 0) := "00";
  CONSTANT pause_c      : std_logic_vector(1 DOWNTO 0) := "01";
  CONSTANT seek_c       : std_logic_vector(1 DOWNTO 0) := "10";
  CONSTANT stop_c       : std_logic_vector(1 DOWNTO 0) := "11";
  
  -- Instruction bus decoding
  ALIAS cmd_funct       : std_logic_vector(1 DOWNTO 0) IS instr_reg(7 DOWNTO 6);
  ALIAS repeat_funct    : std_logic IS instr_reg(5);
  ALIAS seek_value      : std_logic_vector(4 DOWNTO 0) IS instr_reg(4 DOWNTO 0);

BEGIN
  -- Execute clock sync
  CLKSYNCEXE : clock_synchronizer 
    GENERIC MAP (
      bit_width => 1
      )
    PORT MAP(
    clock       =>  clk,
    reset_n     =>  not reset,
    async_in(0) => not execute_btn,
    sync_out(0) =>  exe_pb_sync_n
    );

  -- Execute edge detect
  EXEPBSYNC   : edge_detect
    PORT MAP(
    clock       =>  clk,
    reset_n     =>  not reset,
    Datain      =>  exe_pb_sync_n,
    RisingEdge  =>  open,
    FallingEdge =>  execute_instr_en
	);
  -- Instr Address Generator
	ADDGEN	: PROCESS(reset,clk) IS 
	BEGIN	
		IF(reset = '1') THEN 
			 count_sig <= 0; 
	  ELSIF (rising_edge(clk)) THEN 
			IF(instr_cntr_en = '1') then
				count_sig <= count_sig + 1;
			END IF;
		END IF;
	END PROCESS ADDGEN;
	
  instr_addr <= std_logic_vector(to_unsigned(count_sig,instr_addr'length));
  
	-- Insturction rom
	rom_inst : rom_instructions 
	PORT MAP (
		clock	 => clk,
		address	 => instr_addr,
		q	 => instr_bus
	);
  
  -- Register Enable
	REGISTER_ENABLE : PROCESS(clk)
  BEGIN 
    IF rising_edge(clk)THEN 
      IF(reset = '1')THEN
        instr_reg <= (others => '0');
      ELSIF(instr_fetch_en = '1')THEN 
        instr_reg <= instr_bus;
      END IF; 
    END IF;
  END PROCESS REGISTER_ENABLE;

  --  FSM
  --  This process will update the present state signal to the next state
  --  at the rising edge of the clock. When rest is asserted, the present
  --  state is reset to the IDLE state.
  UpdatePresent : PROCESS(clk,reset)
  BEGIN 
    IF(reset = '1') THEN 
      PresentState <=  IDLE;
    ELSIF (rising_edge(clk)) THEN 
      PresentState <= NextState;
    END IF;
  END PROCESS UpdatePresent;

  FindNextState : PROCESS (PresentState, execute_instr_en,valid_command)
  BEGIN  
    CASE PresentState IS 
      WHEN IDLE =>
        instr_fetch_en <= '1';
        instr_cntr_en <= '0';
      IF(execute_instr_en = '1')THEN
        NextState   <= FETCH;
      ELSE
        NextState <= IDLE;
      END IF;
      
      WHEN FETCH =>
        instr_fetch_en <= '0';
        instr_cntr_en  <= '1';
        NextState   <= DECODE;
        
      WHEN DECODE =>
        instr_fetch_en <= '0';
        instr_cntr_en  <= '0';
        IF(cmd_funct = play_c or cmd_funct = pause_c or cmd_funct = seek_c or cmd_funct = stop_c) THEN
          NextState   <= EXECUTE;
        ELSE
          NextState   <= ERROR;
        END IF;
      
      WHEN ERROR =>
        instr_fetch_en <= '0';
        instr_cntr_en  <= '0';
       NextState   <= FETCH;
       
      WHEN EXECUTE =>
        instr_fetch_en <= '0';
        instr_cntr_en  <= '0';
       NextState   <= IDLE;
      END CASE;
    END PROCESS;
    
  -- Decoder Process 
  DECODEPROCESS : PROCESS(PresentState,cmd_funct,repeat_funct,clk )
  BEGIN 
	IF rising_edge(clk) THEN
      IF(PresentState = DECODE) THEN
        play_cmd <= '0';
        pause_cmd <= '0';
        stop_cmd <= '0';
        seek_cmd <= '0';
        repeat_cmd <= '0';
        valid_command <= '0';
        IF(cmd_funct = play_c) THEN 
          play_cmd <= '1';
          valid_command <= '1';
          IF(repeat_funct = '1') THEN
            repeat_cmd <= '1';
          END IF;
        ELSIF(cmd_funct = pause_c) THEN 
          pause_cmd<= '1';
           valid_command <= '1';
        ELSIF(cmd_funct = stop_c) THEN
          stop_cmd <= '1';
           valid_command <= '1';
         ELSIF(cmd_funct = seek_c) THEN
         seek_cmd <= '1';
          seek_offset <= seek_value;
        END IF;
        ELSE
        play_cmd  <= '0';
        pause_cmd <= '0';
        stop_cmd <= '0';
        seek_cmd <= '0';
        repeat_cmd <= '0';
        seek_offset <= (others => '0');
        valid_command <= '0';
      END IF;
	  END IF;
  END PROCESS;
        
  -- Register Process
  REGPROCESS  : PROCESS(clk)
  BEGIN
  IF rising_edge(clk)THEN
      IF(reset = '1') THEN
        play_reg  <= '0'; 
        stop_reg   <= '0';
        repeat_reg <= '0';
        seek_reg   <= '0';
		pause_reg <= '0';
        seek_off_reg <= (others => '0');
	ELSIF(PresentState = EXECUTE) THEN
	  play_reg    <= play_cmd ;
	  stop_reg    <= stop_cmd;
	  repeat_reg  <= repeat_cmd;
	  pause_reg   <= pause_cmd;
	  seek_reg    <= seek_cmd;
	  seek_off_reg <= seek_offset;
        END IF;
      END IF;
  END PROCESS;
  
  -- Data Address Generator
  PROCESS(clk,reset)
  BEGIN 
    IF (reset = '1') THEN 
      data_address <= (OTHERS => '0');
    ELSIF (clk'event and clk = '1') THEN
      IF (sync = '1') THEN
        IF(play_reg = '1' AND repeat_reg = '1') THEN 
        data_address <= std_logic_vector(unsigned(data_address) + 1 );
        ELSIF(play_reg = '1' AND repeat_reg = '0') THEN
          IF(data_address < "11111111111111")THEN
            data_address <= std_logic_vector(unsigned(data_address) + 1 );
          END IF;
        ELSIF(stop_reg = '1') THEN
            data_address <= (others => '0');
        ELSIF(seek_reg = '1')THEN
            data_address <= (seek_off_reg &"000000000");
        ELSIF(pause_reg = '1')THEN
            data_address <= data_address;
      END IF;
    END IF;
    END IF;
  END PROCESS;
  
  -- Data Rom
  u_rom_data_inst : rom_data
  PORT MAP (
    address    => data_address,
    clock      => clk,
    q          => audio_out
  );
    
  led <= "000" &pause_reg &play_reg &repeat_reg &seek_reg &stop_reg;
END beh;