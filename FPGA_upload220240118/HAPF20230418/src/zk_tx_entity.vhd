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

entity zk_tx_entity is
port (
	reset            : in    std_logic;
	clk              : in    std_logic;

	tx_flag_i        : in    std_logic;
	tx_code_i        : in    std_logic_vector(7  downto 0);
	tx_data01_i      : in    std_logic_vector(7  downto 0);
	tx_data02_i      : in    std_logic_vector(7  downto 0);

	txd_end_o        : out   std_logic;  -- ���ͽ�����־
	txd_o            : out   std_logic);
end zk_tx_entity;

architecture Behavioral of zk_tx_entity is
	-- ����״̬
	signal tm_sof, tm_en, tm_end : std_logic;  -- ң���־
	signal tx_sof, tx_eof : std_logic;  -- ң���־
	signal tx_cnt, tx_dat : std_logic_vector(7  downto 0);

	-- ������ʹ��ģ��
	component dff_entity
	port (
		reset      : in    std_logic;
		clk        : in    std_logic;

		ce         : in    std_logic;
		clr        : in    std_logic;

		o          : out   std_logic);
	end component;

	-- ���ڷ���ģ��
	component sci_tx_entity
	generic (DIV_N : std_logic_vector(15 downto 0) := X"0063";  SUM_FLAG : std_logic_vector(1 downto 0) := "11");
	port (
		reset      : in  std_logic;
		clk        : in  std_logic;

		tx_sof_i   : in  std_logic;
		tx_dat_i   : in  std_logic_vector(7  downto 0);

		txd_eof_o  : out std_logic;
		txd_o      : out std_logic);
	end component;

begin
	-- ����״̬
	process(reset, clk)
	begin
		if (reset='1') then
			tm_sof   <= '0';
		elsif rising_edge(clk) then
			if (tm_end='1') then
				tm_sof   <= '0';
			elsif (tx_flag_i='1') then
				tm_sof   <= '1';
			else
				tm_sof   <= '0';
			end if;
		end if;
	end process;
	---------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------         ң �� �� �� ��            -------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------
	dff_inst1 : dff_entity port map (reset=>reset, clk=>clk, ce=>tm_sof, clr=>tm_end, o=>tm_en);

	-- ��֡ң�����
	process(reset, clk)
	begin
		if (reset='1') then
			tx_cnt <= (others=>'0');
		elsif rising_edge(clk) then
			if (tm_en='0') then
				tx_cnt <= (others=>'0');
			else
				if (tx_eof='1') then
					tx_cnt <= tx_cnt + '1';
				end if;
			end if;
		end if;
	end process;

	-- �ֽڷ���
	process(reset, clk)
	begin
		if (reset='1') then
			tx_sof <= '0';
			tx_dat <= (others=>'0');
		elsif rising_edge(clk) then
			if (tm_sof='1') then
				tx_sof <= '1';
				tx_dat <= X"EB";
			elsif (tx_eof='1' and tm_en='1') then
				case tx_cnt is
					when X"00"  =>
					    tx_sof <= '1';
						tx_dat <= X"90";
					when X"01"  =>
					    tx_sof <= '1';
						tx_dat <= tx_code_i;
					when X"02"  =>
						tx_sof <= '1';
						tx_dat <= tx_data01_i;
					when X"03"  =>
					    tx_sof <= '1';
						tx_dat <= tx_data02_i;
					when others =>
						tx_sof <= '0';
						tx_dat <= (others=>'0');
				end case;
			else
				tx_sof <= '0';
			end if;
		end if;
	end process;

	-- ��������
	process(reset, clk)
	begin
		if (reset='1') then
			tm_end <= '0';
		elsif rising_edge(clk) then
			if (tx_eof='1') then
			    if (tx_cnt=X"04") then
					tm_end <= '1';
				else
					tm_end <= '0';
				end if;
			else
				tm_end <= '0';
			end if;
		end if;
	end process;

	---------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------   ������115200����У��    -------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------

	-- ң��֡��115200����У�� 00AD
	tx_inst1 : sci_tx_entity
	generic map (DIV_N=>X"01B2", SUM_FLAG=>"00")
	port map (
		reset        => reset,
		clk          => clk, 

		tx_sof_i     => tx_sof, 
		tx_dat_i     => tx_dat, 

		txd_eof_o    => tx_eof, 
		txd_o        => txd_o);

	txd_end_o <= tm_end;

end Behavioral;
