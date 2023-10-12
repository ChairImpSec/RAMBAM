 -- 
 -- Copyright (c) 2023, Daniel Lammers, Amir Moradi, Nicolai Müller, Aein Rezaei Shahmirzadi
 -- 
 -- All rights reserved.
 -- 
 -- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 -- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 -- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 -- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTERS BE LIABLE FOR ANY
 -- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 -- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 -- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 -- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 -- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 -- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 -- 
 -- Please see LICENSE and README for license and further instructions.
 -- 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity TB_SBox is
end TB_SBox;

architecture Behavioral of TB_SBox is

	component Circuit is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
					  T    : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011";
					  poly : std_logic_vector := "10000000000000011";
					  A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
					  Q0	 : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
					  Q1	 : std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
					  Q3	 : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
					  C	 : std_logic_vector := x"009b");
		 Port ( clk 	: in std_logic;
				  rst 	: in std_logic;
				  en_in  : in std_logic;
				  en_out : in std_logic;
				  x0 		: in  std_logic_vector(n-1 downto 0);
				  x1 		: in  std_logic_vector(n-1 downto 0);
				  
				  reshare0_m : in  std_logic_vector(n-1 downto 0);
				  reshare1_m : in  std_logic_vector(n-1 downto 0);
				  reshare2_m : in  std_logic_vector(n-1 downto 0);
				  reshare3_m : in  std_logic_vector(n-1 downto 0);
				  reshare4_m : in  std_logic_vector(n-1 downto 0);
				  reshare5_m : in  std_logic_vector(n-1 downto 0);
				  reshare6_m : in  std_logic_vector(n-1 downto 0);
				  
				  z0 		: out std_logic_vector(n-1 downto 0);
				  z1 		: out std_logic_vector(n-1 downto 0));
	end component;

	signal   clk        : std_logic;
	constant clk_period : time := 10 ns;
	
	signal x0, x1, z0, z1 : std_logic_vector(8-1 downto 0);

	signal reshare0_m, reshare1_m, reshare2_m, reshare3_m, reshare4_m, reshare5_m, reshare6_m : std_logic_vector(8-1 downto 0);

begin

   uut: Circuit
		generic map (
			d    => 8,
			n    => 8,
			m    => 8,
			TInv => "1001010011001010111001010110011000110011100011010101001000101001",
			T    => "1011110101011110001011111010101001010101100101111111011001111011",
			poly => "10000000000000011",
			A    => "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100",
		   Q0	  => "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001",
		   Q1	  => "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001",
		   Q3	  => "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100",
		   C	  => x"009b"
		)
		port map (
			clk 	 => clk,
			rst 	 => '0',
			en_in  => '1',
			en_out => '1',
			x0 	 => x0,
			x1 	 => x1,

		   reshare0_m => reshare0_m,
		   reshare1_m => reshare1_m,
		   reshare2_m => reshare2_m,
		   reshare3_m => reshare3_m,
		   reshare4_m => reshare4_m,
		   reshare5_m => reshare5_m,
		   reshare6_m => reshare6_m,

			z0 	 => z0,
			z1 	 => z1
		);		
		
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	stim_proc: process
   begin		
		
		wait for 100 ns;
      
		-- inputs can change here
		x0 <= x"00";
		x1 <= x"00";
		
		reshare0_m <= x"03";
		reshare1_m <= x"5e";
		reshare2_m <= x"00";
		reshare3_m <= x"8d";
		reshare4_m <= x"00";
		reshare5_m <= x"c9";
		reshare6_m <= x"3a";
		
		wait for clk_period*10;
		assert (z0 xor z1) = x"9b"
		report "error" severity failure;
		
		x0 <= x"cb";
		x1 <= x"cb";
		
		reshare0_m <= x"10";
		reshare1_m <= x"34";
		reshare2_m <= x"28";
		reshare3_m <= x"71";
		reshare4_m <= x"01";
		reshare5_m <= x"39";
		reshare6_m <= x"05";
		
		wait for clk_period*2;
		assert (z0 xor z1) = x"9b"
		report "error" severity failure;

		x0 <= x"e0";
		x1 <= x"e1";
		
		reshare0_m <= x"10";
		reshare1_m <= x"34";
		reshare2_m <= x"28";
		reshare3_m <= x"71";
		reshare4_m <= x"01";
		reshare5_m <= x"39";
		reshare6_m <= x"05";

		wait for clk_period*2;
		assert (z0 xor z1) = x"9f"
		report "error" severity failure;

		x0 <= x"c9";
		x1 <= x"df";
		
		reshare0_m <= x"10";
		reshare1_m <= x"34";
		reshare2_m <= x"28";
		reshare3_m <= x"71";
		reshare4_m <= x"01";
		reshare5_m <= x"39";
		reshare6_m <= x"05";

		wait for clk_period*2;
		assert (z0 xor z1) = x"cc"
		report "error" severity failure;

		x0 <= x"f2";
		x1 <= x"39";

		reshare0_m <= x"00";
		reshare1_m <= x"00";
		reshare2_m <= x"00";
		reshare3_m <= x"00";
		reshare4_m <= x"00";
		reshare5_m <= x"00";
		reshare6_m <= x"00";

		wait for clk_period*2;
		assert (z0 xor z1) = x"df"
		report "error" severity failure;

		x0 <= x"86";
		x1 <= x"94";

		reshare0_m <= x"00";
		reshare1_m <= x"00";
		reshare2_m <= x"00";
		reshare3_m <= x"00";
		reshare4_m <= x"00";
		reshare5_m <= x"00";
		reshare6_m <= x"00";

		wait for clk_period*2;
		assert (z0 xor z1) = x"d9"
		report "error" severity failure;
		
		x0 <= x"a7";
		x1 <= x"84";

		reshare0_m <= x"00";
		reshare1_m <= x"00";
		reshare2_m <= x"00";
		reshare3_m <= x"00";
		reshare4_m <= x"00";
		reshare5_m <= x"00";
		reshare6_m <= x"00";

		wait for clk_period*2;
		assert (z0 xor z1) = x"75"
		report "error" severity failure;
		
      wait;
   end process;

end Behavioral;

