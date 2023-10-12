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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity g_function is
	Generic ( d    : integer := 8;
				 n    : integer := 8;
				 m    : integer := 8;
				 TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
				 poly : std_logic_vector := "10000000000000011";
				 A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
				 Q0	: std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
			    Q1	: std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
				 Q3   : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
				 C	   : std_logic_vector := x"009b");
	Port ( g0_func_in 	: in  std_logic_vector(0 to 4*n-1);
			 g1_func_in 	: in  std_logic_vector(0 to 4*d-1);
			 rc            : in  std_logic_vector(d+n-1 downto 0);
			 randomness    : in  std_logic_vector(  223 downto 0);
			 g0_func_out 	: out std_logic_vector(0 to 4*n-1);
			 g1_func_out 	: out std_logic_vector(0 to 4*d-1));
end g_function;

architecture Behavioral of g_function is

	component Sbox is
		 Generic ( d    : integer := 8;
					  n    : integer := 8;
					  m    : integer := 8;
					  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001";
					  poly : std_logic_vector := "10000000000000011";
					  A    : std_logic_vector := "0000001000000000000010010000000011111110000000000011111100000000001010010000000000010001000000000110010000000000011010010000000000000000111011010000000000111111000000000000010000000000010010110000000000100001000000000111100100000000000000100000000000001100";
					  Q0	 : std_logic_vector := "1000111000000000000000110000000001000111000000000000111100000000001000000000000000001001000000000001110100000000000001110000000000000000111010000000000000111000000000000111010000000000111101000000000000000010000000001001001000000000110100010000000001110001";
					  Q1	 : std_logic_vector := "1011101000000000000110100000000000010000000000000011001100000000010001110000000000100111000000000010000100000000000100110000000000000000101001100000000010000010000000000010101000000000110000100000000011010001000000001100110100000000010101010000000011001001";
					  Q3	 : std_logic_vector := "1111111100000000010101010000000000110011000000000001000100000000000011110000000000000101000000000000001100000000000000010000000000000000000101000000000011110011000000001010111000000000011100010000000000101111000000001111000100000000010001000000000000111100";
					  C	 : std_logic_vector := x"009b");
		 Port ( x0 		: in std_logic_vector(n-1 downto 0);
				  x1 		: in std_logic_vector(d-1 downto 0);
				  
				  reshare0_m : in std_logic_vector(n-1 downto 0);
				  reshare1_m : in std_logic_vector(n-1 downto 0);
				  reshare2_m : in std_logic_vector(n-1 downto 0);
				  reshare3_m : in std_logic_vector(n-1 downto 0);
				  reshare4_m : in std_logic_vector(n-1 downto 0);
				  reshare5_m : in std_logic_vector(n-1 downto 0);
				  reshare6_m : in std_logic_vector(n-1 downto 0);
				  
				  z0 		: out std_logic_vector(n-1 downto 0);
				  z1 		: out std_logic_vector(d-1 downto 0));
	end component;
	
	signal g0_0_in, g0_1_in, g0_2_in, g0_3_in : std_logic_vector(0 to n-1);
	signal g1_0_in, g1_1_in, g1_2_in, g1_3_in : std_logic_vector(0 to d-1);

	signal g0_1_tmp : std_logic_vector(0 to n-1);
	signal g1_1_tmp : std_logic_vector(0 to d-1);
	
	signal g0_0_out, g0_1_out, g0_2_out, g0_3_out : std_logic_vector(0 to n-1);
	signal g1_0_out, g1_1_out, g1_2_out, g1_3_out : std_logic_vector(0 to d-1);

begin

	-- map inputs
	g0_0_in <= g0_func_in(0*n to 1*n-1);
	g0_1_in <= g0_func_in(1*n to 2*n-1);
	g0_2_in <= g0_func_in(2*n to 3*n-1);
	g0_3_in <= g0_func_in(3*n to 4*n-1);
	g1_0_in <= g1_func_in(0*d to 1*d-1);
	g1_1_in <= g1_func_in(1*d to 2*d-1);
	g1_2_in <= g1_func_in(2*d to 3*d-1);
	g1_3_in <= g1_func_in(3*d to 4*d-1);

	-- s-boxes
	Sbox_inst0: Sbox
		generic map ( d => d, n => n, m => m, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( x0 => g0_0_in, x1 => g1_0_in,  
					  reshare0_m => randomness( 7+0*56 downto  0+0*56),
					  reshare1_m => randomness(15+0*56 downto  8+0*56),
					  reshare2_m => randomness(23+0*56 downto 16+0*56),
					  reshare3_m => randomness(31+0*56 downto 24+0*56),
					  reshare4_m => randomness(39+0*56 downto 32+0*56),
					  reshare5_m => randomness(47+0*56 downto 40+0*56),
					  reshare6_m => randomness(55+0*56 downto 48+0*56),
					  z0 => g0_0_out, z1 => g1_0_out);

	Sbox_inst1: Sbox
		generic map ( d => d, n => n, m => m, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( x0 => g0_1_in, x1 => g1_1_in,  
					  reshare0_m => randomness( 7+1*56 downto  0+1*56),
					  reshare1_m => randomness(15+1*56 downto  8+1*56),
					  reshare2_m => randomness(23+1*56 downto 16+1*56),
					  reshare3_m => randomness(31+1*56 downto 24+1*56),
					  reshare4_m => randomness(39+1*56 downto 32+1*56),
					  reshare5_m => randomness(47+1*56 downto 40+1*56),
					  reshare6_m => randomness(55+1*56 downto 48+1*56),
					  z0 => g0_1_tmp, z1 => g1_1_tmp);

	Sbox_inst2: Sbox
		generic map ( d => d, n => n, m => m, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( x0 => g0_2_in, x1 => g1_2_in,  
					  reshare0_m => randomness( 7+2*56 downto  0+2*56),
					  reshare1_m => randomness(15+2*56 downto  8+2*56),
					  reshare2_m => randomness(23+2*56 downto 16+2*56),
					  reshare3_m => randomness(31+2*56 downto 24+2*56),
					  reshare4_m => randomness(39+2*56 downto 32+2*56),
					  reshare5_m => randomness(47+2*56 downto 40+2*56),
					  reshare6_m => randomness(55+2*56 downto 48+2*56),
					  z0 => g0_2_out, z1 => g1_2_out);

	Sbox_inst3: Sbox
		generic map ( d => d, n => n, m => m, TInv => TInv, poly => poly, A => A, Q0 => Q0, Q1 => Q1, Q3 => Q3, C => C )
		port map ( x0 => g0_3_in, x1 => g1_3_in,  
					  reshare0_m => randomness( 7+3*56 downto  0+3*56),
					  reshare1_m => randomness(15+3*56 downto  8+3*56),
					  reshare2_m => randomness(23+3*56 downto 16+3*56),
					  reshare3_m => randomness(31+3*56 downto 24+3*56),
					  reshare4_m => randomness(39+3*56 downto 32+3*56),
					  reshare5_m => randomness(47+3*56 downto 40+3*56),
					  reshare6_m => randomness(55+3*56 downto 48+3*56),
					  z0 => g0_3_out, z1 => g1_3_out);

	-- xor roudn constant
	g0_1_out <= g0_1_tmp xor rc(  n-1 downto 0);
	g1_1_out <= g1_1_tmp xor rc(d+n-1 downto n);
	
	-- map output
	g0_func_out <= g0_1_out & g0_2_out & g0_3_out & g0_0_out;
	g1_func_out <= g1_1_out & g1_2_out & g1_3_out & g1_0_out;

end Behavioral;

