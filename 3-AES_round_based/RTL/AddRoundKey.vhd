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

entity AddRoundKey is
   Generic ( d    : integer := 8;
				 n    : integer := 8);
	Port ( x0 		: in  std_logic_vector(16*n-1 downto 0);
          x1 		: in  std_logic_vector(16*d-1 downto 0);
			 key0 	: in  std_logic_vector(16*n-1 downto 0);
          key1 	: in  std_logic_vector(16*d-1 downto 0);
			 z0      : out std_logic_vector(16*n-1 downto 0);
			 z1      : out std_logic_vector(16*d-1 downto 0));	  
end AddRoundKey;

architecture Behavioral of AddRoundKey is

begin

	z0 <= x0 xor key0;
	z1 <= x1 xor key1;

end Behavioral;

