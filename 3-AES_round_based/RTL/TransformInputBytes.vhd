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

entity TransformInputBytes is
	 Generic ( bytes : integer := 16;
				  d     : integer := 8;
				  n     : integer := 8;
				  m     : integer := 8;
				  R     : std_logic_vector := "1010011101010000000101110011010000000011010010100011000100110101";
				  TInv  : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001");
    Port ( x0 					: in  std_logic_vector(bytes*n-1 downto 0);
           x1 					: in  std_logic_vector(bytes*d-1 downto 0);
           x0_transformed  : out std_logic_vector(bytes*n-1 downto 0);
			  x1_transformed  : out std_logic_vector(bytes*d-1 downto 0));
end TransformInputBytes;

architecture Behavioral of TransformInputBytes is

	component MatrixMultiplication is
		 Generic (n : integer := n;
					 m : integer := m;
					 C : std_logic_vector := R);
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

	signal x0_tmp : std_logic_vector(bytes*n-1 downto 0);
	signal x1_tmp : std_logic_vector(bytes*d-1 downto 0);

begin

	gen0: for i in 0 to bytes-1 generate
	
		mul_inst00: MatrixMultiplication
			generic map (
				n => n,
				m => m,
				C => R
			)
			port map (
				x => x0((i*n)+n-1 downto i*n),
				y => x0_tmp((i*n)+n-1 downto i*n)
			);
			
		mul_inst01: MatrixMultiplication
			generic map (
				n => n,
				m => m,
				C => R
			)
			port map (
				x => x1((i*d)+d-1 downto i*d),
				y => x1_tmp((i*d)+d-1 downto i*d)
			);
	
	end generate;

	gen1: for i in 0 to bytes-1 generate
	
		mul_inst10: MatrixMultiplication
			generic map (
				n => n,
				m => m,
				C => TInv
			)
			port map (
				x => x1_tmp((i*d)+d-1 downto i*d),
				y => x1_transformed((i*d)+d-1 downto i*d)
			);

		x0_transformed((i*n)+n-1 downto i*n) <= x0_tmp((i*n)+n-1 downto i*n);
	
	end generate;

end Behavioral;

