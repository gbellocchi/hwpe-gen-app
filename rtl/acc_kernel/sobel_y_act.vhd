-- -------------------------------------------------------------------------------
-- This file has been automatically generated by the Caph compiler (version 2.8.4d)
-- from file main.cph, on 2018-05-11 at 16:30:56, by <unknown>
-- For more information, see : http://caph.univ-bpclermont.fr
-- -------------------------------------------------------------------------------

library ieee,work;
use ieee.std_logic_1164.all;
use work.core.all;
use work.data_types.all;
use ieee.numeric_std.all;
use work.all;
use work.edgeDetectionOk_globals.all;

entity sobel_y is
   port (
    pel00_empty: in std_logic;
    pel00: in std_logic_vector(7 downto 0);
    pel00_rd: out std_logic;
    pel01_empty: in std_logic;
    pel01: in std_logic_vector(7 downto 0);
    pel01_rd: out std_logic;
    pel02_empty: in std_logic;
    pel02: in std_logic_vector(7 downto 0);
    pel02_rd: out std_logic;
    pel10_empty: in std_logic;
    pel10: in std_logic_vector(7 downto 0);
    pel10_rd: out std_logic;
    pel11_empty: in std_logic;
    pel11: in std_logic_vector(7 downto 0);
    pel11_rd: out std_logic;
    pel12_empty: in std_logic;
    pel12: in std_logic_vector(7 downto 0);
    pel12_rd: out std_logic;
    pel20_empty: in std_logic;
    pel20: in std_logic_vector(7 downto 0);
    pel20_rd: out std_logic;
    pel21_empty: in std_logic;
    pel21: in std_logic_vector(7 downto 0);
    pel21_rd: out std_logic;
    pel22_empty: in std_logic;
    pel22: in std_logic_vector(7 downto 0);
    pel22_rd: out std_logic;
    out_pel_full: in std_logic;
    out_pel: out std_logic_vector(13 downto 0);
    out_pel_wr: out std_logic;
    clock: in std_logic;
    reset: in std_logic
    );
end sobel_y;

architecture FSM of sobel_y is
begin
  comb: process(pel00, pel00_empty, pel01, pel01_empty, pel02, pel02_empty, pel10, pel10_empty, pel11, pel11_empty, pel12, pel12_empty, pel20, pel20_empty, pel21, pel21_empty, pel22, pel22_empty, out_pel_full)
    variable p_p00 : unsigned(7 downto 0);
    variable p_p01 : unsigned(7 downto 0);
    variable p_p02 : unsigned(7 downto 0);
    variable p_p10 : unsigned(7 downto 0);
    variable p_p11 : unsigned(7 downto 0);
    variable p_p12 : unsigned(7 downto 0);
    variable p_p20 : unsigned(7 downto 0);
    variable p_p21 : unsigned(7 downto 0);
    variable p_p22 : unsigned(7 downto 0);
  begin
    -- pel22.rdy, pel21.rdy, pel20.rdy, pel12.rdy, pel11.rdy, pel10.rdy, pel02.rdy, pel01.rdy, pel00.rdy, out_pel.rdy / p_p22=pel22, p_p21=pel21, p_p20=pel20, p_p12=pel12, p_p11=pel11, p_p10=pel10, p_p02=pel02, p_p01=pel01, p_p00=pel00, wr(out_pel,(p_p00 : signed<14>)+(p_p01 : signed<14>)*2+(p_p02 : signed<14>)-(p_p20 : signed<14>)+2*(p_p21 : signed<14>)+(p_p22 : signed<14>))
    if pel22_empty='0' and pel21_empty='0' and pel20_empty='0' and pel12_empty='0' and pel11_empty='0' and pel10_empty='0' and pel02_empty='0' and pel01_empty='0' and pel00_empty='0' and out_pel_full='0' then
      p_p22 := from_std_logic_vector(pel22,8);
      pel22_rd <= '1';
      p_p21 := from_std_logic_vector(pel21,8);
      pel21_rd <= '1';
      p_p20 := from_std_logic_vector(pel20,8);
      pel20_rd <= '1';
      p_p12 := from_std_logic_vector(pel12,8);
      pel12_rd <= '1';
      p_p11 := from_std_logic_vector(pel11,8);
      pel11_rd <= '1';
      p_p10 := from_std_logic_vector(pel10,8);
      pel10_rd <= '1';
      p_p02 := from_std_logic_vector(pel02,8);
      pel02_rd <= '1';
      p_p01 := from_std_logic_vector(pel01,8);
      pel01_rd <= '1';
      p_p00 := from_std_logic_vector(pel00,8);
      pel00_rd <= '1';
      out_pel <= std_logic_vector((((conv_signed(p_p00,14)) + (mul(conv_signed(p_p01,14),to_signed(2,14)))) + (conv_signed(p_p02,14))) - (((conv_signed(p_p20,14)) + (mul(to_signed(2,14),conv_signed(p_p21,14)))) + (conv_signed(p_p22,14))));
      out_pel_wr <= '1';
    else
      pel00_rd <= '0';
      pel01_rd <= '0';
      pel02_rd <= '0';
      pel10_rd <= '0';
      pel11_rd <= '0';
      pel12_rd <= '0';
      pel20_rd <= '0';
      pel21_rd <= '0';
      pel22_rd <= '0';
      out_pel_wr <= '0';
      out_pel <= (others => 'X');
    end if;
  end process;
  seq: process(clock, reset)
  begin
    if (reset='0') then
    elsif rising_edge(clock) then
    end if;
  end process;
end FSM;
