--------------------------------------------------
-- ��Ȩ(copyright)�����ҵ��ܱ任����ƹ��̼����о�����(NECC)
-- ��Ŀ��:
-- ģ����:  
-- �ļ���:
-- ����:  �ſ�
-- ���ܺ��ص����: 
-- ��ʼ�汾�ͷ���ʱ��: 1.00��2022-03-30
---------------------------------------------------
-- ������ʷ:
---------------------------------------------------
-- ���İ汾�͸���ʱ�䣺 
-- ������Ա�� 
-- ��������:  
-- ���İ汾�͸���ʱ�䣺 
-- ������Ա����
-- ��������: �� 
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity dsp_intf_entity is
port (
	reset               : in     std_logic;
	clk                 : in     std_logic;

	dsp_cs_i            : in     std_logic;                         -- Ƭѡ
	dsp_wr_i            : in     std_logic;                         -- дʹ��
	dsp_rd_i            : in     std_logic;                         -- ��ʹ��       
	dsp_addr_i          : in     std_logic_vector(7  downto 0);     -- ��ַ����
	
	vol_phase_i         : in     std_logic_vector(15 downto 0);     -- ������ѹ��λ
	sys_opera_i         : in     std_logic_vector(15 downto 0);     -- ϵͳ����
	
	dsp_data_io         : inout  std_logic_vector(15 downto 0);     -- ��������
	
	cmd_flag_o          : out    std_logic;                         -- ָ�������־λ
	cmd_addr_o          : out    std_logic_vector(7  downto 0);     -- ָ�������ַ
	cmd_data_o          : out    std_logic_vector(15 downto 0));    -- ָ���������
end dsp_intf_entity;

architecture Behavioral of dsp_intf_entity is

	signal data01, data02, data03, data04, data05 : std_logic_vector(15 downto 0);
	signal data06, data07, data08, data09, data10 : std_logic_vector(15 downto 0);
	signal data11, data12, data13, data14, data15 : std_logic_vector(15 downto 0);
	signal data16, data17, data18, data19, data20 : std_logic_vector(15 downto 0);
	signal dsp_din, dsp_dout : std_logic_vector(15 downto 0);
	
	component edge_entity
	generic (INIT  : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		i          : in    std_logic;

		r          : out   std_logic;
		f          : out   std_logic);
	end component;
	
	signal rd_en, wr_en     : std_logic;
	signal rd_en_r, wr_en_r : std_logic;
	signal rd_en_f, wr_en_f : std_logic;
	
	signal dsp_data : std_logic_vector(15 downto 0);
    signal dsp_addr : std_logic_vector(7 downto 0);
	
	component syn_entity
	generic (INIT : std_logic := '0';  LEVEL : std_logic := '1');
	port (
		reset    : in    std_logic;
		clk      : in    std_logic;

		i        : in    std_logic;
		o        : out   std_logic);
	end component;
	
	signal wr_en_s : std_logic;
	signal wr_en_s_f : std_logic;
	
	signal rd_en_s : std_logic;
	signal rd_en_s_f : std_logic;
	
begin

	dsp_din <= dsp_data_io;
	dsp_data_io <= dsp_dout;
	
	rd_en <= dsp_cs_i or dsp_rd_i;
	wr_en <= dsp_cs_i or dsp_wr_i;
	
	--------------------- д����(FPGAʱ����) ---------------------
    --------------------- ָ�����(FPGAʱ����) ---------------------	
	-- FPGAʱ����ͬ��
	syn_inst1 : syn_entity
	generic map (INIT=>'1', LEVEL=>'1')
	port map (
		reset  => reset, 
		clk    => clk,
		
		i      => wr_en,
		o      => wr_en_s);
	
	wr_edge_inst1 : edge_entity
	generic map (INIT => '1')
	port map(
		reset      => reset,
		clk        => clk,

		i          => wr_en_s,

		r          => open,
		f          => wr_en_s_f);
		
	process(reset, clk)
	begin
		if (reset='1') then
			data01 <= (others=>'0'); data02 <= (others=>'0');
			data03 <= (others=>'0'); data04 <= (others=>'0');
			data05 <= (others=>'0'); data06 <= (others=>'0');
			data07 <= (others=>'0'); data08 <= (others=>'0');
			data09 <= (others=>'0'); data10 <= (others=>'0');
			data11 <= (others=>'0'); data12 <= (others=>'0');
			data13 <= (others=>'0'); data14 <= (others=>'0');
			data15 <= (others=>'0'); data16 <= (others=>'0');
		elsif rising_edge(clk) then
			if (wr_en_s_f = '1') then
				case dsp_addr_i is
					when X"00" => data01 <= dsp_din;
					when X"01" => data02 <= dsp_din;
					when X"02" => data03 <= dsp_din;
					when X"03" => data04 <= dsp_din;
					when X"04" => data05 <= dsp_din;
					when X"05" => data06 <= dsp_din;
					when X"06" => data07 <= dsp_din;
					when X"07" => data08 <= dsp_din;
					when X"08" => data09 <= dsp_din;
					when X"09" => data10 <= dsp_din;
					when X"0A" => data11 <= dsp_din;
					when X"0B" => data12 <= dsp_din;
					when X"0C" => data13 <= dsp_din;
					when X"0D" => data14 <= dsp_din;
					when X"0E" => data15 <= dsp_din;
					when X"0F" => data16 <= dsp_din;
					when others   => null;
				end case;
			end if;
		end if;
	end process;
	
	-- ָ�����
	process(reset, clk)
	begin
		if (reset='1') then
			cmd_flag_o <= '0';
			cmd_addr_o <= (others => '0');
			cmd_data_o <= (others => '0');
		elsif rising_edge(clk) then
			if (wr_en_s_f = '1') then
				cmd_flag_o <= '1';
				cmd_addr_o <= dsp_addr_i;
				cmd_data_o <= dsp_din;
			else
				cmd_flag_o <= '0';
			end if;
		end if;
	end process;
	
	
	--------------------- ������(FPGAʱ����) ---------------------
	syn_inst2 : syn_entity
	generic map (INIT=>'1', LEVEL=>'1')
	port map (
		reset  => reset, 
		clk    => clk,
		
		i      => rd_en,
		o      => rd_en_s);
	
	rd_edge_inst1 : edge_entity
	generic map (INIT => '1')
	port map(
		reset      => reset,
		clk        => clk,

		i          => rd_en_s,

		r          => open,
		f          => rd_en_s_f);
	
	process(reset, clk)
	begin
		if (reset='1') then
			dsp_data <= (others=>'Z');
		elsif rising_edge(clk) then
			if (rd_en_s_f = '1') then
				case dsp_addr_i is
					when X"00" => dsp_data <= data01;
					when X"01" => dsp_data <= data02;
					when X"02" => dsp_data <= data03;
					when X"03" => dsp_data <= data04;
					when X"04" => dsp_data <= data05;
					when X"05" => dsp_data <= data06;
					when X"06" => dsp_data <= data07;
					when X"07" => dsp_data <= data08;
					when X"08" => dsp_data <= data09;
					when X"09" => dsp_data <= data10;
					when X"0A" => dsp_data <= data11;
					when X"0B" => dsp_data <= data12;
					when X"0C" => dsp_data <= data13;
					when X"0D" => dsp_data <= data14;
					when X"0E" => dsp_data <= data15;
					when X"0F" => dsp_data <= data16;
					when X"10" => dsp_data <= vol_phase_i;
					when X"11" => dsp_data <= sys_opera_i;
					when others   => dsp_data <= X"0000";
				end case;
			end if;
		end if;
	end process;
	
	dsp_dout <= dsp_data when (rd_en_s='0') else (others=>'Z');
	
end Behavioral;
