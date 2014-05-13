library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity topv is
    port (
        -- reset button (SW10) / active = '1'
        CPU_RESET   : in std_logic;

        -- 200MHz LVDS oscillator
        SYSCLK_N    : in std_logic;
        SYSCLK_P    : in std_logic;

        -- GPIO DIP SW (SW1) / 'on' to '1'
        GPIO_DIP_SW : in std_logic_vector(8 downto 1);
        -- GPIO SW / 'on' to '1'
        GPIO_SW_C   : in std_logic;
        GPIO_SW_E   : in std_logic;
        GPIO_SW_N   : in std_logic;
        GPIO_SW_S   : in std_logic;
        GPIO_SW_W   : in std_logic;
        -- GPIO LED / '1' to light
        GPIO_LED    : out std_logic_vector(7 downto 0);
        GPIO_LED_C  : out std_logic;
        GPIO_LED_E  : out std_logic;
        GPIO_LED_N  : out std_logic;
        GPIO_LED_S  : out std_logic;
        GPIO_LED_W  : out std_logic;

        -- UART
        USB_1_CTS   : in std_logic;
        USB_1_RTS   : out std_logic;
        USB_1_RX    : in std_logic;
        USB_1_TX    : out std_logic;

        -- LCD
        LCD_DB_LS   : inout std_logic_vector(7 downto 4);
        LCD_E_LS    : out std_logic;
        LCD_RS_LS   : out std_logic;
        LCD_RW_LS   : out std_logic;

        -- I2C
        I2C_SCL     : inout std_logic;
        I2C_SDA     : inout std_logic
    );
end topv;

architecture behavioral of topv is

component Top
    port (
        clock        : in std_logic;
        clock2x      : in std_logic;
        reset        : in std_logic;
        -- I/O
        Switch       : in std_logic_vector(7 downto 0);
        LED          : out std_logic_vector(14 downto 0);
        LCD          : out std_logic_vector(6 downto 0);
        UART_Rx      : in std_logic;
        UART_Tx      : out std_logic;
        i2c_scl      : inout std_logic;
        i2c_sda      : inout std_logic;
        Piezo        : out std_logic
    );
end component;

component clk_200_33_66
port
 (-- Clock in ports
  CLK_IN1_P         : in     std_logic;
  CLK_IN1_N         : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

signal s_clock      : std_logic;
signal s_clock2x    : std_logic;
signal s_pll_locked : std_logic;

signal s_reset : std_logic;

signal s_switch : std_logic_vector(7 downto 0);
signal s_led    : std_logic_vector(14 downto 0);
signal s_lcd    : std_logic_vector(6 downto 0);
signal s_piezo  : std_logic;

begin

processor: Top
    port map (
        clock        => s_clock,
        clock2x      => s_clock2x,
        reset        => s_reset,
        Switch       => s_switch,
        LED          => s_led,
        LCD          => s_lcd,
        UART_Rx      => USB_1_RX,
        UART_Tx      => USB_1_TX,
        i2c_scl      => I2C_SCL,
        i2c_sda      => I2C_SDA,
        Piezo        => s_piezo
    );

USB_1_RTS <= '1';

i_clock: clk_200_33_66
    port map (
        CLK_IN1_P => SYSCLK_P,
        CLK_IN1_N => SYSCLK_N,
        CLK_OUT1  => s_clock,
        CLK_OUT2  => s_clock2x,
        RESET     => CPU_RESET,
        LOCKED    => s_pll_locked
    );

s_reset <= CPU_RESET OR (NOT s_pll_locked);

s_switch <= GPIO_DIP_SW;

GPIO_LED(7 downto 0) <= s_led(7 downto 0);
GPIO_LED_C <= s_piezo; -- s_led(8);
GPIO_LED_E <= s_led(13); -- s_led(9);
GPIO_LED_N <= s_led(10);
GPIO_LED_S <= s_led(11);
GPIO_LED_W <= s_led(14); -- s_led(12);

LCD_DB_LS(7) <= s_lcd(6);
LCD_DB_LS(6) <= s_lcd(5);
LCD_DB_LS(5) <= s_lcd(4);
LCD_DB_LS(4) <= s_lcd(3);
LCD_E_LS     <= s_lcd(2);
LCD_RS_LS    <= s_lcd(1);
LCD_RW_LS    <= s_lcd(0);


end behavioral;

