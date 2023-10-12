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

entity TB_Mutliplication is
end TB_Mutliplication;

architecture Behavioral of TB_Mutliplication is

	component Circuit is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
					  T    : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011";
					  poly : std_logic_vector := "10000000000000011");
		 Port ( clk 	: in std_logic;
				  rst 	: in std_logic;
				  en_in  : in std_logic;
				  en_out : in std_logic;
				  x0 		: in  std_logic_vector(n-1 downto 0);
				  x1 		: in  std_logic_vector(n-1 downto 0);
				  y0 		: in  std_logic_vector(n-1 downto 0);
				  y1 		: in  std_logic_vector(n-1 downto 0);
				  z0 		: out std_logic_vector(n-1 downto 0);
				  z1 		: out std_logic_vector(n-1 downto 0));
	end component;

	signal   clk        : std_logic;
	constant clk_period : time := 10 ns;
	
	signal x0, x1, y0, y1, z0, z1 : std_logic_vector(7 downto 0);

begin

   uut: Circuit
		generic map (
			d    => 8,
			n    => 8,
			m    => 8,
			TInv => "1001010011001010111001010110011000110011100011010101001000101001",
			T    => "1011110101011110001011111010101001010101100101111111011001111011",
			poly => "10000000000000011"
		)
		port map (
			clk 	 => clk,
			rst 	 => '0',
			en_in  => '1',
			en_out => '1',
			x0 	 => x0,
			x1 	 => x1,
			y0 	 => y0,
			y1 	 => y1,
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

		x0 <= x"1c";
		x1 <= x"19";
		y0 <= x"f4";
		y1 <= x"fe";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"24";
		x1 <= x"21";
		y0 <= x"57";
		y1 <= x"5d";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"a7";
		x1 <= x"a2";
		y0 <= x"6a";
		y1 <= x"60";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"ba";
		x1 <= x"bf";
		y0 <= x"f0";
		y1 <= x"fa";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"0c";
		x1 <= x"09";
		y0 <= x"ed";
		y1 <= x"e7";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"5e";
		x1 <= x"5b";
		y0 <= x"c0";
		y1 <= x"ca";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"a8";
		x1 <= x"ad";
		y0 <= x"34";
		y1 <= x"3e";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"7b";
		x1 <= x"7e";
		y0 <= x"d6";
		y1 <= x"dc";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"61";
		x1 <= x"64";
		y0 <= x"5c";
		y1 <= x"56";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

		x0 <= x"47";
		x1 <= x"42";
		y0 <= x"e0";
		y1 <= x"ea";

		wait for clk_period*2;
		assert (z0 xor z1) = x"22"
		report "error" severity failure;

      wait;
   end process;

end Behavioral;

