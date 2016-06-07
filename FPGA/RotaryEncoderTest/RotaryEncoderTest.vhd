--**********************************************************************
-- Copyright 2013 by XESS Corp <http://www.xess.com>.
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--**********************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.CommonPckg.all;
use work.ClkGenPckg.all;
use work.LedDigitsPckg.all;
use work.SyncToClockPckg.all;
use work.HostIoPckg.all;
use work.RotaryEncoderPckg.all;

entity RotaryEncoderTest is
  port (
    clk_i        : in  std_logic;
    rotEnc1A_i   : in  std_logic;        -- Rotary encoder 1 phase 1 output.
    rotEnc1B_i   : in  std_logic;        -- Rotary encoder 1 phase 2 output.
    rotEnc1Btn_i : in  std_logic;        -- Rotary encoder 1 pushbutton.
    rotEnc2A_i   : in  std_logic;        -- Rotary encoder 2 phase 1 output.
    rotEnc2B_i   : in  std_logic;        -- Rotary encoder 2 phase 2 output.
    rotEnc2Btn_i : in  std_logic;        -- Rotary encoder 2 pushbutton.
    led_o        : out std_logic_vector (7 downto 0)
    );
end entity;

architecture arch of RotaryEncoderTest is
  signal clk_s          : std_logic;
  signal accumulator1_s : std_logic_vector(31 downto 0);
  signal accumulator2_s : std_logic_vector(31 downto 0);
  signal accu1accu2_s   : std_logic_vector(31 downto 0);
  signal buttons_s      : std_logic_vector(1 downto 0);
  signal dummy1_s       : std_logic_vector(0 downto 0);
  signal dummy2_s       : std_logic_vector(0 downto 0);
  signal dummy3_s       : std_logic_vector(0 downto 0);
  signal inShiftDr_s, drck_s, tdi_s, tdo1_s, tdo2_s, tdo3_s: std_logic;
begin

  clkgen0 : ClkGen
    generic map (BASE_FREQ_G => 12.0, CLK_MUL_G => 25, CLK_DIV_G => 3)
    port map (i              => clk_i, o => clk_s);

  rot1 : RotaryEncoderWithCounter
    generic map (ALLOW_ROLLOVER_G => true, INITIAL_CNT_G => 0)
    port map (
      clk_i => clk_s,
      a_i   => rotEnc1A_i,
      b_i   => rotEnc1B_i,
      cnt_o => accumulator1_s
      );

  rot2 : RotaryEncoderWithCounter
    generic map (ALLOW_ROLLOVER_G => true, INITIAL_CNT_G => 0)
    port map (
      clk_i => clk_s,
      a_i   => rotEnc2A_i,
      b_i   => rotEnc2B_i,
      cnt_o => accumulator2_s
      );

  accu1accu2_s <= accumulator2_s(15 downto 0) & accumulator1_s(15 downto 0);
  leds0 : LedHexDisplay
    port map (
      clk_i          => clk_s,
      hexAllDigits_i => accu1accu2_s,
      ledDrivers_o   => led_o
      );

  bscan0 : BscanToHostIo
    generic map( FPGA_DEVICE_G => SPARTAN6 )
    port map(
      inShiftDr_o => inShiftDr_s,
      drck_o      => drck_s,
      tdi_o       => tdi_s,
      tdoa_i      => tdo1_s,
      tdob_i      => tdo2_s,
      tdoc_i      => tdo3_s
      );

  rot1hostio : HostIoToDut
    generic map ( ID_G => "00000001" )
    port map (
      inShiftDr_i     => inShiftDr_s,
      drck_i          => drck_s,
      tdi_i           => tdi_s,
      tdo_o           => tdo1_s,
      vectorFromDut_i => accumulator1_s,
      vectorToDut_o   => dummy1_s
      );

  rot2hostio : HostIoToDut
    generic map ( ID_G => "00000010" )
    port map (
      inShiftDr_i     => inShiftDr_s,
      drck_i          => drck_s,
      tdi_i           => tdi_s,
      tdo_o           => tdo2_s,
      vectorFromDut_i => accumulator2_s,
      vectorToDut_o   => dummy2_s
      );

  buttons_s <= rotEnc1Btn_i & rotEnc2Btn_i;
  buttons : HostIoToDut
    generic map ( ID_G => "00000011" )
    port map (
      inShiftDr_i     => inShiftDr_s,
      drck_i          => drck_s,
      tdi_i           => tdi_s,
      tdo_o           => tdo3_s,
      vectorFromDut_i => buttons_s,
      vectorToDut_o   => dummy3_s
    );

end architecture;

