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

entity TransformInputDomain is
	 Generic ( d    : integer := 8;
				  n    : integer := 8;
				  m    : integer := 8;
				  TInv : std_logic_vector := "1001010011001010111001010110011000110011100011010101001000101001");
    Port ( x0 : in  std_logic_vector(  n-1 downto 0);
           x1 : in  std_logic_vector(  n-1 downto 0);
           x  : out std_logic_vector(d+n-1 downto 0));
end TransformInputDomain;

architecture Behavioral of TransformInputDomain is

	component MatrixMultiplication is
		 Generic (n : integer := n;
					 m : integer := m;
					 C : std_logic_vector := TInv);
		 Port ( x : in  std_logic_vector(m-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

begin

	mul_inst: MatrixMultiplication
		generic map (
			n => n,
			m => m,
			C => TInv
		)
		port map (
			x => x0,
			y => x(d+n-1 downto n)
		);

	x(n-1 downto 0) <= x1;

end Behavioral;

