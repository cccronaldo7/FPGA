----------------------------------------------------------------------------------
-- ��Ȩ(copyright)��
-- ��Ŀ����
-- ģ����: 
-- �ļ���: 
-- ����:   �ſ�
-- ���ܺ��ص����: 
-- ��ʼ�汾�ͷ���ʱ��: 1.00��2022-05-17
---------------------------------------------------
-- ������ʷ:
---------------------------------------------------
-- ���İ汾�͸���ʱ�䣺 
-- ������Ա����
-- ��������: �� 
-- ���İ汾�͸���ʱ�䣺 
-- ������Ա����
-- ��������: �� 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity zk_tm_entity is
port (
	reset            : in    std_logic;
	clk              : in    std_logic;

	cmd_flag_i       : in    std_logic;
	cmd_code_i       : in    std_logic_vector(7  downto 0);
	cmd_data01_i     : in    std_logic_vector(7  downto 0);
	cmd_data02_i     : in    std_logic_vector(7  downto 0);
	
	-- ϵͳ״̬�ش�
	sys_tx_flag_i    : in    std_logic;
	sys_tx_data01_i  : in    std_logic_vector(7  downto 0);
	sys_tx_data02_i  : in    std_logic_vector(7  downto 0);
	
	tm_flag_o        : out   std_logic;
	tm_code_o        : out   std_logic_vector(7  downto 0);
	tm_data01_o      : out   std_logic_vector(7  downto 0);
	tm_data02_o      : out   std_logic_vector(7  downto 0));
end zk_tm_entity;

architecture Behavioral of zk_tm_entity is


begin
	process(reset, clk)
	begin
		if (reset='1') then
			tm_flag_o   <= '0';
			tm_code_o   <= (others => '0');
			tm_data01_o <= (others => '0');
			tm_data02_o <= (others => '0');
		elsif rising_edge(clk) then
			if(sys_tx_flag_i = '1') then
				tm_flag_o   <= '1';
				tm_code_o   <= X"A0";
				tm_data01_o <= sys_tx_data01_i;
				tm_data02_o <= sys_tx_data02_i;
			elsif(cmd_flag_i = '1') then
				tm_flag_o   <= '1';
				tm_code_o   <= cmd_code_i;
				tm_data01_o <= cmd_data01_i;
				tm_data02_o <= cmd_data02_i;
			else
				tm_flag_o <= '0';
			end if;
		end if;
	end process;
	
end Behavioral;
