library ieee; 
use ieee.std_logic_1164.all;

entity Beispielrechner_System is
	generic (
	    CLKIN_PERIOD     : Real    := 10.0;
        CLKMUL           : integer := 12;
        CLKDIV           : integer := 20;
		SDI_BAUDRATE     : integer := 256_000;
		TRACE            : boolean := false;
		TRACEFILE        : string  := "trace_sim.txt";
        HEXFILE          : string  := "../Speicher/Software.hex";
        SSP_MUX_CYCLES   : integer := 60_000
	);
	port (
		CLKIN            : in  std_logic;
        
        PINS             : inout std_logic_vector(2 downto 0);
		
        -- TODO: Ergaenzen Sie externen Signale fuer die Komponente SSP (V4)

        SEG       : out std_logic_vector(7 downto 0);
        MUX       : out std_logic_vector(3 downto 0);
        -- TODO: Ergaenzen Sie externen Signale fuer die Komponente UART (V5)

		-- Serial Debug Interface
		SDI_TXD          : out std_logic;
		SDI_RXD          : in  std_logic
	);
end entity;

library ieee; 
use ieee.numeric_std.all;

architecture arch of Beispielrechner_System is
	constant SYS_FREQUENCY  : integer := Integer(Real(CLKMUL) * Real(1_000_000_000) / Real(CLKIN_PERIOD) / Real(CLKDIV) + 0.5);

	signal RST         : std_logic := '1';
    signal CLK         : std_logic;

	signal STB         : std_logic;
	signal WE          : std_logic;
	signal WRO         : std_logic;
	signal ADR         : std_logic_vector(31 downto 0);
	signal SEL         : std_logic_vector( 3 downto 0);
	signal ACK         : std_logic;
	signal DAT_O       : std_logic_vector(31 downto 0);
	signal DAT_I       : std_logic_vector(31 downto 0);

	signal IP2         : std_logic := '0';
	signal IP3         : std_logic := '0';
	signal IP4         : std_logic := '0';

	signal ROM_ACK     : std_logic;
	signal ROM_STB     : std_logic;
	signal ROM_DAT     : std_logic_vector(31 downto 0);

	signal RAM_ACK     : std_logic;
	signal RAM_STB     : std_logic;
	signal RAM_DAT     : std_logic_vector(31 downto 0);

	signal Timer_ACK   : std_logic;
	signal Timer_STB   : std_logic;
	signal Timer_DAT   : std_logic_vector(31 downto 0);

	signal GPIO_ACK    : std_logic;
	signal GPIO_STB    : std_logic;
	signal GPIO_DAT    : std_logic_vector(31 downto 0);
    signal GPIO_Pins   : std_logic_vector(2 downto 0);

    -- TODO: Ergaenzen Sie die Bussignale fuer die Komponente SSP (V4)
    signal SSP_ACK    : std_logic;
    signal SSP_STB    : std_logic;
    signal SSP_DAT    : std_logic_vector(31 downto 0);
  
    -- TODO: Ergaenzen Sie die Bussignale fuer die Komponente UART (V5)
    
begin
    ------------------------------------------------------------
    -- Clock Manager
    ------------------------------------------------------------
    Clocking: entity work.Clocking
    generic map(
        CLKIN_PERIOD => CLKIN_PERIOD,
        CLKMUL       => CLKMUL,
        CLKDIV       => CLKDIV
    )
    port map(
        clkin  => CLKIN,
        clkout => CLK,
        locked => open 
    );

  ------------------------------------------------------------
  -- Wishbone Interconnect
  ------------------------------------------------------------
    intercon_block: block is
    begin
    Decoder: process(ADR, STB)
        variable ADRV : unsigned(ADR'range);
    begin
        ROM_STB   <= '0';
        RAM_STB   <= '0';
        Timer_STB <= '0';
		GPIO_STB  <= '0';
        -- TODO: Weitere Default-Zuweisungen ergaenzen (V4, V5)
        SSP_STB <= '0';


        ADRV := unsigned(ADR);
        if    ADRV >= 16#00000000# and ADRV <= 16#000037ff# then ROM_STB   <= STB;
        elsif ADRV >= 16#00004000# and ADRV <= 16#00007fff# then RAM_STB   <= STB;
        elsif ADRV >= 16#00008000# and ADRV <= 16#00008013# then Timer_STB <= STB;
		elsif ADRV >= 16#00008100# and ADRV <= 16#0000810b# then GPIO_STB  <= STB;
        -- TODO: Weitere Adressbereiche ergaenzen (V4, V5)     
        elsif ADRV >= 16#00008200# and ADRV <= 16#0000820f# then SSP_STB  <= STB;
        end if;	  
    end process;
    
    DATA_MUX: process(
        ROM_STB,   ROM_DAT, 
        RAM_STB,   RAM_DAT,
        Timer_STB, Timer_DAT,
        GPIO_STB,  GPIO_DAT,
        -- TODO: Signale weiterer Komponenten in der Sensitivitaetsliste ergaenzen (V4, V5)
        SSP_STB,   SSP_DAT
    )

    begin
        DAT_I <= (DAT_I'range => '1'); -- Alle Bits auf Wert 'egal' setzen
        if    ROM_STB   = '1' then DAT_I <= ROM_DAT;
        elsif RAM_STB   = '1' then DAT_I <= RAM_DAT;
        elsif Timer_STB = '1' then DAT_I <= Timer_DAT;
        elsif GPIO_STB  = '1' then DAT_I <= GPIO_DAT;
        -- TODO: Signale weiterer Komponenten ergaenzen (V4, V5)
        elsif SSP_STB  = '1' then DAT_I <= SSP_DAT;
        end if;
    end process;
    
    ACK_MUX: process(
        ROM_STB,   ROM_ACK, 
        RAM_STB,   RAM_ACK,
        Timer_STB, Timer_ACK,
        GPIO_STB,  GPIO_ACK,
        -- TODO: Signale weiterer Komponenten in der Sensitivitaetsliste ergaenzen (V4, V5)
        SSP_STB,  SSP_ACK
    )
    begin
        ACK <= '1';
        IF    ROM_STB   = '1' then ACK <= ROM_ACK;
        elsif RAM_STB   = '1' then ACK <= RAM_ACK;
        elsif Timer_STB = '1' then ACK <= Timer_ACK;
        elsif GPIO_STB  = '1' then ACK <= GPIO_ACK;
        -- TODO: Signale weiterer Komponenten in der Sensitivitaetsliste ergaenzen (V4, V5)
        elsif SSP_STB  = '1' then ACK <= SSP_ACK;
        end if;
    end process;
    end block;
  
    ------------------------------------------------------------
    -- Der Prozessor
    ------------------------------------------------------------
    Processor_Inst: entity work.bsr2_processor
    generic map(  
        Reset_Vector   => x"00000000",
        AdEL_Vector    => x"00000008",
        AdES_Vector    => x"00000008",
        Sys_Vector     => x"00000008",
        RI_Vector      => x"00000008",
        IP0_Vector     => x"00000008",
        IP2_Vector     => x"00000010",
        IP3_Vector     => x"00000018",
        IP4_Vector     => x"00000020",
        SYS_FREQUENCY  => SYS_FREQUENCY,
        SDI_BAUDRATE   => SDI_BAUDRATE,
        TRACE          => TRACE,
        TRACEFILE      => TRACEFILE
    )
    port map(
        -- Clock and Reset
        CLK_I        => CLK,
        RST_O        => RST,

        -- Wishbone Master Interface
        STB_O        => STB,
        WE_O         => WE,
        WRO_O        => WRO,
        ADR_O        => ADR,
        SEL_O        => SEL,
        ACK_I        => ACK,
        DAT_O        => DAT_O,
        DAT_I        => DAT_I,

        -- Interrupt Requests
        IP2          => IP2,
        IP3          => IP3,
        IP4          => IP4,

        -- Serial Debug Interface
        SDI_TXD       => SDI_TXD,
        SDI_RXD       => SDI_RXD 
    );

    ------------------------------------------------------------
    -- ROM
    ------------------------------------------------------------
	ROM_Block: block
		signal ROM_WE : std_logic;
	begin
		ROM_WE <= WRO and WE; -- allow write access to ROM if WRO is set
		
		ROM_Inst: entity work.Memory
        generic map (
            ADR_I_WIDTH   => 14,
            BASE_ADDR     => 16#00000000#,
            HEX_FILE_NAME => HEXFILE
        )
		port map(
			CLK_I         => CLK,
			RST_I         => RST,
			STB_I         => ROM_STB,
			WE_I          => ROM_WE,
			SEL_I         => SEL,
			ADR_I         => ADR(13 downto 0),
			DAT_I         => DAT_O,
			DAT_O         => ROM_DAT,
			ACK_O         => ROM_ACK
		);
	end block;

	------------------------------------------------------------
	-- RAM
	------------------------------------------------------------
	RAM_Inst: entity work.Memory
    generic map (
        ADR_I_WIDTH   => 14,
        BASE_ADDR     => 16#00004000#,
        HEX_FILE_NAME => HEXFILE
    )
	port map(
		CLK_I        => CLK,
		RST_I        => RST,
		STB_I        => RAM_STB,
		WE_I         => WE,
		SEL_I        => SEL,
		ADR_I        => ADR(13 downto 0),
		DAT_I        => DAT_O,
		DAT_O        => RAM_DAT,
		ACK_O        => RAM_ACK
	);

    ------------------------------------------------------------
    -- Timer
    ------------------------------------------------------------
    Timer_Inst: entity work.Timer
    port map (
        CLK_I        => CLK,
        RST_I        => RST,
        STB_I        => Timer_STB,
        WE_I         => WE,
        SEL_I        => SEL,
        ADR_I        => ADR(4 downto 0),
        DAT_I        => DAT_O,
        DAT_O        => Timer_DAT,
        ACK_O        => Timer_ACK,
        IR_Tim       => IP2,
        PWM          => open
    );
    
	------------------------------------------------------------
	-- GPIO
	------------------------------------------------------------
	GPIO_inst: entity work.GPIO
    generic map(
		N=>GPIO_Pins'length
	)
    port map (
		CLK_I        => CLK,
		RST_I        => RST,
		STB_I        => GPIO_STB,
		WE_I         => WE,
		SEL_I        => SEL,
		ADR_I        => ADR(3 downto 0),
		DAT_I        => DAT_O,
		DAT_O        => GPIO_DAT,
		ACK_O        => GPIO_ACK,
		Pins         => PINS
    );    
    
    -- TODO: Instanz der Komponente SSP ergaenzen (V4)
    SSP_inst: entity work.SSP
    generic map(MUX_CYCLES => SSP_MUX_CYCLES)
    port map (
      CLK_I     => CLK,
      RST_I     => RST,
      STB_I     => SSP_STB, 
      WE_I      => WE, 
      ADR_I     => ADR(3 downto 0), 
      SEL_I     => SEL, 
      ACK_O     => SSP_ACK,
      DAT_I     => DAT_O, 
      DAT_O     => SSP_DAT,
      Seg       => SEG,
      Mux       => MUX       
    );
    -- TODO: Instanz der Komponente SSP ergaenzen (V5)
    
end architecture;
