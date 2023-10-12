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

entity VectorMultiplicationMod is
    Generic ( n    : integer := 2;
				  poly : std_logic_vector := "100");
    Port ( x 		: in  std_logic_vector(n-1 downto 0);
           y 		: in  std_logic_vector(n-1 downto 0);
           z 		: out std_logic_vector(n-1 downto 0));
end VectorMultiplicationMod;

architecture Behavioral of VectorMultiplicationMod is

	component ShiftLeftMod is
		 Generic ( n    : integer := 2;
					  poly : std_logic_vector := "100");
		 Port ( x : in  std_logic_vector(n-1 downto 0);
				  y : out std_logic_vector(n-1 downto 0));
	end component;

	type array_results is array (integer range <>) of std_logic_vector(n-1 downto 0);

	signal array_z   : array_results(n downto 0);
	signal array_deg : array_results(n downto 0);

begin

	array_z(0)   <= (others => '0');
	array_deg(0) <= y;


	Gen: for i in 0 to n-1 generate
  
		array_z(i+1) <= (array_z(i) xor array_deg(i)) when(x(i) = '1') else array_z(i);
		
		shift_inst: ShiftLeftMod
			generic map (
				n    => n,
				poly => poly
			)
			port map (
				x => array_deg(i),
				y => array_deg(i+1)
			);

	end generate;


	z <= array_z(n);

end Behavioral;

