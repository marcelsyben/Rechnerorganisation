-----------------------------------------------------------------
-- dataflow fifo
-- (c) Prof. B.Lang, HS Osnabrück
-----------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DF_Fifo is
  generic ( 
    DataSize    : integer; 
    AddressSize : integer
  );
  port(
    -- commons
    Clock     : in  std_logic;                              -- clock
    Reset     : in  std_logic;                              -- synchronous reset
    -- input side
    valid_in  : in  std_logic;                              -- valid control input for data_in
    data_in   : in  std_logic_vector (DataSize-1 downto 0); -- Data input
    ready_in  : out std_logic;                              -- ready to input
    -- output side
    valid_out : out std_logic;                              -- valid control output for data_out
    data_out  : out std_logic_vector (DataSize-1 downto 0); -- Data output
    ready_out : in  std_logic                               -- ready from output
  );
end DF_Fifo;

library IEEE;
use IEEE.numeric_std.all;

architecture arch of DF_Fifo is
  signal WCNT:        unsigned(AddressSize downto 0) := (others=>'0');
  signal RCNT:        unsigned(AddressSize downto 0) := (others=>'0');
  signal WriteOK:     std_logic;
  signal ReadOK:      std_logic;
  signal WriteEnable: std_logic;
  signal ReadEnable:  std_logic;
  signal WaitRead:    std_logic;
  signal b_en:        std_logic;
  signal out_valid_i: std_logic := '0';
  signal Level_i:     unsigned(AddressSize downto 0);
begin
  Mem: block
    type mem_type is array ( (2**AddressSize)-1 downto 0 ) of std_logic_vector(DataSize-1 downto 0);
    signal mem : mem_type;
  begin
    MEM_PROC: process(Clock)
    begin
      if rising_edge(Clock) then
      
        if WriteEnable='1' then
          mem(to_integer(WCNT(AddressSize-1 downto 0))) <= data_in;
        end if;
        
        if ReadEnable = '1' then
          data_out <= mem(to_integer(RCNT(AddressSize-1 downto 0)));
        end if;
        
      end if;        
    end process;
  end block;

  valid_out <= out_valid_i;
  WaitRead <= out_valid_i and not (ready_out);

  Sync_Proc: process (Clock)
  begin
    if rising_edge(Clock) then
      if Reset='1' then
        WCNT <= (others => '0');
        RCNT <= (others => '0');
        out_valid_i <= '0';
      else
        if WriteEnable='1' then
          WCNT <= WCNT + 1;
        end if;
        if ReadEnable='1' then
          RCNT <= RCNT + 1;
        end if;
        if WaitRead='0' then
          out_valid_i <= ReadOK;
        end if;
      end if;
    end if;
  end process;
  
  Level_i     <= WCNT - RCNT;
    
  WriteOK     <= not Level_i(AddressSize);
  WriteEnable <= '1' when WriteOK='1' and valid_in='1' else '0';
  ready_in    <= WriteOK;

  ReadOK      <= '1' when Level_i /= 0 else '0';
  ReadEnable  <= '1' when ReadOK='1' and WaitRead='0' else '0';  
end arch;