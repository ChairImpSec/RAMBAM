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
use IEEE.NUMERIC_STD.all;

entity AES_Control is
	Generic ( d    : integer := 8;
				 n    : integer := 8);
	Port ( clk 		   : in  std_logic;
			 rst 		   : in  std_logic;
			 en  		   : in  std_logic;
			 take_input : out std_logic;
			 last_round : out std_logic;
			 en_round   : out std_logic;
			 rst_core   : out std_logic;
			 done  	   : out std_logic);
end AES_Control;

architecture Behavioral of AES_Control is

-- STATES --------------------------------------------------------------------
TYPE STATES IS (S_START, S_RUN, S_LAST, S_IDLE);
SIGNAL STATE : STATES;

signal cnt : unsigned(3 downto 0);

begin

    -- FSM -----------------------------------------------------------------------
    OneProcessFSM : PROCESS(CLK)
    BEGIN
		IF rising_edge(CLK) THEN	
				
			IF (rst = '1') THEN
			    take_input <= '1';
				 last_round <= '0';
				 en_round   <= '0';
				 rst_core   <= '1';
				 done       <= '0';
				 cnt			<= (others => '0');
				 STATE      <= S_START;
			ELSE
				IF (EN = '1') THEN
					-- CASE EVALUATION ---------------------------------------------------
					CASE STATE IS
						-------------------------------------------------------------------
						WHEN S_START => take_input    <= '1';
											 last_round    <= '0';
											 en_round      <= '1';
											 rst_core		<= '0';
											 done          <= '0';
											 cnt			   <= (others => '0');
											 STATE			<= S_RUN;
						-------------------------------------------------------------------
						WHEN S_RUN   => take_input		<= '0';
											 cnt			   <= cnt+1;
											 IF (cnt = 9) THEN
										 		last_round  <= '1';
										 		STATE       <= S_LAST;
										    END IF;
						-------------------------------------------------------------------
						WHEN S_LAST  => done 			<= '1';
											 last_round    <= '0';
											 en_round      <= '0';
											 STATE     		<= S_IDLE;
						-------------------------------------------------------------------
						WHEN S_IDLE  => STATE     		<= S_IDLE;
						-------------------------------------------------------------------
					END CASE;
					-----------------------------------------------------------------------
				END IF;
			END IF;
		END IF;
	END PROCESS;
   ------------------------------------------------------------------------------
	
end Behavioral;

