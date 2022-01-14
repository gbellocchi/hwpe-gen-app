-- -------------------------------------------------------------------------------
-- This file has been automatically generated by the Caph compiler (version 2.8.4d)
-- from file main.cph, on 2018-05-11 at 12:39:30, by <unknown>
-- For more information, see : http://caph.univ-bpclermont.fr
-- -------------------------------------------------------------------------------

library ieee,work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.edgeDetectionOk_globals.all;

entity remove_2x2 is
   port (
    in_size_empty: in std_logic;
    in_size: in std_logic_vector(5 downto 0);
    in_size_rd: out std_logic;
    in_pel_empty: in std_logic;
    in_pel: in std_logic_vector(7 downto 0);
    in_pel_rd: out std_logic;
    out_pel_full: in std_logic;
    out_pel: out std_logic_vector(7 downto 0);
    out_pel_wr: out std_logic;
    clock: in std_logic;
    reset: in std_logic
    );
end remove_2x2;

architecture FSM of remove_2x2 is
    type t_enum3 is (IDLE,DROP,WORK);
    signal state : t_enum3;
    signal n_state : t_enum3;
    signal en_state : boolean;
    signal max : unsigned(5 downto 0);
    signal n_max : unsigned(5 downto 0);
    signal en_max : boolean;
    signal line : unsigned(5 downto 0);
    signal n_line : unsigned(5 downto 0);
    signal en_line : boolean;
    signal cnt : unsigned(5 downto 0);
    signal n_cnt : unsigned(5 downto 0);
    signal en_cnt : boolean;
begin
  comb: process(in_size, in_size_empty, in_pel, in_pel_empty, out_pel_full, cnt, line, max, state)
    variable p_p : unsigned(7 downto 0);
    variable p_s : unsigned(5 downto 0);
  begin
    -- in_size.rdy, state=IDLE / p_s=in_size, state:=DROP, max:=p_s-1
    if in_size_empty='0' and state=IDLE then
      p_s := from_std_logic_vector(in_size,6);
      in_size_rd <= '1';
      n_state <= DROP;
      en_state <= true;
      n_max <= (p_s) - (to_unsigned(1,6));
      en_max <= true;
      out_pel <= (others => 'X');
      out_pel_wr <= '0';
      in_pel_rd <= '0';
      n_line <= line;
      en_line <= false;
      n_cnt <= cnt;
      en_cnt <= false;
    -- in_pel.rdy, state=DROP, cnt < max / p_p=in_pel, state:=DROP, cnt:=cnt+1
    elsif in_pel_empty='0' and state=DROP and ((cnt) < (max)) then
      p_p := from_std_logic_vector(in_pel,8);
      in_pel_rd <= '1';
      n_state <= DROP;
      en_state <= true;
      n_cnt <= (cnt) + (to_unsigned(1,6));
      en_cnt <= true;
      out_pel <= (others => 'X');
      out_pel_wr <= '0';
      in_size_rd <= '0';
      n_max <= max;
      en_max <= false;
      n_line <= line;
      en_line <= false;
    -- in_pel.rdy, state=DROP / p_p=in_pel, state:=WORK, cnt:=0, line:=line+1
    elsif in_pel_empty='0' and state=DROP then
      p_p := from_std_logic_vector(in_pel,8);
      in_pel_rd <= '1';
      n_state <= WORK;
      en_state <= true;
      n_cnt <= to_unsigned(0,6);
      en_cnt <= true;
      n_line <= (line) + (to_unsigned(1,6));
      en_line <= true;
      out_pel <= (others => 'X');
      out_pel_wr <= '0';
      in_size_rd <= '0';
      n_max <= max;
      en_max <= false;
    -- in_pel.rdy, state=WORK, cnt < 1 && line < max + 1 / p_p=in_pel, state:=WORK, cnt:=cnt+1
    elsif in_pel_empty='0' and state=WORK and (((cnt) < (to_unsigned(1,6))) AND ((line) < ((max) + (to_unsigned(1,6))))) then
      p_p := from_std_logic_vector(in_pel,8);
      in_pel_rd <= '1';
      n_state <= WORK;
      en_state <= true;
      n_cnt <= (cnt) + (to_unsigned(1,6));
      en_cnt <= true;
      out_pel <= (others => 'X');
      out_pel_wr <= '0';
      in_size_rd <= '0';
      n_max <= max;
      en_max <= false;
      n_line <= line;
      en_line <= false;
    -- in_pel.rdy, state=WORK, cnt < max && line < max + 1, out_pel.rdy / p_p=in_pel, state:=WORK, wr(out_pel,p_p), cnt:=cnt+1
    elsif in_pel_empty='0' and state=WORK and (((cnt) < (max)) AND ((line) < ((max) + (to_unsigned(1,6))))) and out_pel_full='0' then
      p_p := from_std_logic_vector(in_pel,8);
      in_pel_rd <= '1';
      n_state <= WORK;
      en_state <= true;
      out_pel <= std_logic_vector(p_p);
      out_pel_wr <= '1';
      n_cnt <= (cnt) + (to_unsigned(1,6));
      en_cnt <= true;
      in_size_rd <= '0';
      n_max <= max;
      en_max <= false;
      n_line <= line;
      en_line <= false;
    -- in_pel.rdy, state=WORK, line < max, out_pel.rdy / p_p=in_pel, state:=WORK, wr(out_pel,p_p), cnt:=0, line:=line+1
    elsif in_pel_empty='0' and state=WORK and ((line) < (max)) and out_pel_full='0' then
      p_p := from_std_logic_vector(in_pel,8);
      in_pel_rd <= '1';
      n_state <= WORK;
      en_state <= true;
      out_pel <= std_logic_vector(p_p);
      out_pel_wr <= '1';
      n_cnt <= to_unsigned(0,6);
      en_cnt <= true;
      n_line <= (line) + (to_unsigned(1,6));
      en_line <= true;
      in_size_rd <= '0';
      n_max <= max;
      en_max <= false;
    -- in_pel.rdy, state=WORK, out_pel.rdy / p_p=in_pel, state:=IDLE, wr(out_pel,p_p), cnt:=0, line:=0
    elsif in_pel_empty='0' and state=WORK and out_pel_full='0' then
      p_p := from_std_logic_vector(in_pel,8);
      in_pel_rd <= '1';
      n_state <= IDLE;
      en_state <= true;
      out_pel <= std_logic_vector(p_p);
      out_pel_wr <= '1';
      n_cnt <= to_unsigned(0,6);
      en_cnt <= true;
      n_line <= to_unsigned(0,6);
      en_line <= true;
      in_size_rd <= '0';
      n_max <= max;
      en_max <= false;
    else
      in_size_rd <= '0';
      in_pel_rd <= '0';
      out_pel_wr <= '0';
      out_pel <= (others => 'X');
      en_state <= false;
      en_max <= false;
      en_line <= false;
      en_cnt <= false;
      n_state <= state;
      n_max <= max;
      n_line <= line;
      n_cnt <= cnt;
    end if;
  end process;
  seq: process(clock, reset)
  begin
    if (reset='0') then
      state <= IDLE;
      max <= "000000";
      line <= "000000";
      cnt <= "000000";
    elsif rising_edge(clock) then
      if ( en_state ) then
        state <= n_state after 1 ns;
      end if;
      if ( en_max ) then
        max <= n_max after 1 ns;
      end if;
      if ( en_line ) then
        line <= n_line after 1 ns;
      end if;
      if ( en_cnt ) then
        cnt <= n_cnt after 1 ns;
      end if;
    end if;
  end process;
end FSM;
