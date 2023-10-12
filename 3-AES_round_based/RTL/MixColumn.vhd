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

entity MixColumn is
    Generic ( d    : integer := 8;
				  n    : integer := 8;
				  m    : integer := 8;
				  Mul2 : std_logic_vector := "0001011000000000100010110000000001000101000000000011010000000000000110100000000010011011000000000101101100000000001011010000000000000000000101100000000010001011000000000100010100000000001101000000000000011010000000001001101100000000010110110000000000101101";
				  Mul3 : std_logic_vector := "1001011000000000110010110000000001100101000000000010010000000000000100100000000010011111000000000101100100000000001011000000000000000000100101100000000011001011000000000110010100000000001001000000000000010010000000001001111100000000010110010000000000101100");
	 Port ( E1_in  : in  std_logic_vector(0 to d+n-1);
			  E2_in  : in  std_logic_vector(0 to d+n-1);
			  E3_in  : in  std_logic_vector(0 to d+n-1);
			  E4_in  : in  std_logic_vector(0 to d+n-1);
			  E1_out : out std_logic_vector(0 to d+n-1);
			  E2_out : out std_logic_vector(0 to d+n-1);
			  E3_out : out std_logic_vector(0 to d+n-1);
			  E4_out : out std_logic_vector(0 to d+n-1));
end MixColumn;

architecture Behavioral of MixColumn is

	component MatrixMultiplication is
		 Generic (n : integer := d+n;
					 m : integer := d+m;
					 C: std_logic_vector := Mul2);
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

	signal E1_by2, E2_by2, E3_by2, E4_by2 : std_logic_vector(d+n-1 downto 0);
	signal E1_by3, E2_by3, E3_by3, E4_by3 : std_logic_vector(d+n-1 downto 0);

begin

	-- mul by 2
	matrix_mul_inst0: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul2 )
		port map ( x => E1_in, y => E1_by2 );
	
	matrix_mul_inst1: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul2 )
		port map ( x => E2_in, y => E2_by2 );
		
	matrix_mul_inst2: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul2 )
		port map ( x => E3_in, y => E3_by2 );
		
	matrix_mul_inst3: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul2 )
		port map ( x => E4_in, y => E4_by2 );

	-- mul by 3
	matrix_mul_inst4: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul3 )
		port map ( x => E1_in, y => E1_by3 );
	
	matrix_mul_inst5: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul3 )
		port map ( x => E2_in, y => E2_by3 );
		
	matrix_mul_inst6: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul3 )
		port map ( x => E3_in, y => E3_by3 );
		
	matrix_mul_inst7: MatrixMultiplication
		generic map ( n => d+n, m => d+m, C => Mul3 )
		port map ( x => E4_in, y => E4_by3 );
	
	-- assemble col
	E1_out <= E1_by2 xor E2_by3 xor E3_in xor E4_in;
	E2_out <= E1_in xor E2_by2 xor E3_by3 xor E4_in;
	E3_out <= E1_in xor E2_in xor E3_by2 xor E4_by3;
	E4_out <= E1_by3 xor E2_in xor E3_in xor E4_by2;

end Behavioral;

