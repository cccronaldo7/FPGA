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

entity protect_entity is
port (
	reset               : in     std_logic;
	clk                 : in     std_logic;

	drive_fault_i       : in     std_logic;
	
	drive_fault_o       : out    std_logic);
end protect_entity;

architecture Behavioral of protect_entity is

	signal vol_phase : std_logic_vector(20 downto 0);
	
	-- �˲�ģ��
	component flt_entity
	generic (INIT : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		clks_i     : in    std_logic;
		length_i   : in    std_logic_vector(15 downto 0);

		i          : in    std_logic;
		o          : out   std_logic);
	end component;
	
	signal bit1_c1 : std_logic;
	signal flt_length : std_logic_vector(15 downto 0);  -- �˲����
	
	signal drive_fault_s : std_logic;
	
	component edge_entity
	generic (INIT  : std_logic := '0');
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		i          : in    std_logic;

		r          : out   std_logic;
		f          : out   std_logic);
	end component;
	
begin
	
	---------------------------------------------------------------------
	-------------------------    �� ֵ �� ��    -------------------------
	---------------------------------------------------------------------
	bit1_c1 <= '1';
	flt_length <= X"03E8";  -- �˲����20us

	-- �����˲�ģ��
	flt_inst : flt_entity
	generic map (INIT=>'0')
	port map (
		reset        => reset, 
		clk          => clk, 

		clks_i       => bit1_c1, 
		length_i     => flt_length, 

		i            => drive_fault_i, 

		o            => drive_fault_s);
	
	edge_inst1 : edge_entity
	generic map (INIT => '1')
	port map(
		reset      => reset,
		clk        => clk,

		i          => drive_fault_s,

		r          => open,
		f          => drive_fault_o);
	
end Behavioral;
