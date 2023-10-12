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

entity TransformOutputDomain is
	 Generic ( d : integer := 8;
				  n : integer := 8;
				  m : integer := 8;
				  T : std_logic_vector := "1011110101011110001011111010101001010101100101111111011001111011");
    Port ( x  : in  std_logic_vector(d+n-1 downto 0);
           x0 : out std_logic_vector(  n-1 downto 0);
           x1 : out std_logic_vector(  n-1 downto 0));
end TransformOutputDomain;

architecture Behavioral of TransformOutputDomain is

	component MatrixMultiplication is
		 Generic (n : integer := n;
					 m : integer := m;
					 C : std_logic_vector := T);
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

begin

	mul_inst: MatrixMultiplication
		generic map (
			n => n,
			m => m,
			C => T
		)
		port map (
			x => x(d+n-1 downto n),
			y => x1
		);

	 x0 <= x(n-1 downto 0);

end Behavioral;

