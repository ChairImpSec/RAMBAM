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

entity TransformOutputBytes is
	 Generic ( bytes : integer := 16;
				  d     : integer := 8;
				  n     : integer := 8;
				  m     : integer := 8;
				  RInv  : std_logic_vector := "1011001101101011001110000010101101110110000000110001100100010001";
				  T 	  : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011");
    Port ( z0_transformed : in  std_logic_vector(bytes*n-1 downto 0);
           z1_transformed : in  std_logic_vector(bytes*d-1 downto 0);
           z0  			  : out std_logic_vector(bytes*n-1 downto 0);
			  z1  			  : out std_logic_vector(bytes*d-1 downto 0));
end TransformOutputBytes;

architecture Behavioral of TransformOutputBytes is

	component MatrixMultiplication is
		 Generic (n : integer := n;
					 m : integer := m;
					 C : std_logic_vector := T);
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

	signal z0_tmp : std_logic_vector(bytes*n-1 downto 0);
	signal z1_tmp : std_logic_vector(bytes*d-1 downto 0);

begin

	gen0: for i in 0 to bytes-1 generate
	
		mul_inst00: MatrixMultiplication
			generic map (
				n => n,
				m => m,
				C => T
			)
			port map (
				x => z1_transformed((i*8)+7 downto i*8),
				y => z1_tmp((i*8)+7 downto i*8)
			);

		z0_tmp((i*8)+7 downto i*8) <= z0_transformed((i*8)+7 downto i*8);
	
	end generate;

	gen1: for i in 0 to bytes-1 generate
	
		mul_inst10: MatrixMultiplication
			generic map (
				n => n,
				m => m,
				C => RInv
			)
			port map (
				x => z0_tmp((i*8)+7 downto i*8),
				y => z0((i*8)+7 downto i*8)
			);
			
		mul_inst11: MatrixMultiplication
			generic map (
				n => n,
				m => m,
				C => RInv
			)
			port map (
				x => z1_tmp((i*8)+7 downto i*8),
				y => z1((i*8)+7 downto i*8)
			);
	
	end generate;

end Behavioral;

