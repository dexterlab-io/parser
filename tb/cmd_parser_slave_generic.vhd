-- ======================================================================
--  DexterLab™
--  Copyright (c) DexterLab
--  Released as free example code for educational and non-commercial use.
--  No warranty is provided. Use at your own risk.
--  © 2026 DexterLab
-- ======================================================================
--  File: cmd_parser_slave_generic.vhd
--  Author: Dexter
--  Date: 2026-09-08
--  Version: 1.0
-- ======================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.cmd_cfg.all;
use work.cmd_cmd_pkg.all;
use work.cmd_pkg.all;
use work.cmd_math_pkg.all;

entity cmd_parser_slave_generic is
    port (
        clk        : in  std_logic;
        resetn     : in  std_logic;

        interrupts : out std_logic_vector(7 downto 0);

        -- Comandi dal parser
        cmd_valid  : in  std_logic;
        cmd_ready  : out std_logic;
        cmd        : in  t_cmd_out;

        -- Risposte verso il parser
        rsp_valid  : out t_rsp_in;

        -- Handshake dal parser (non usato)
        rsp_ready  : in  t_rsp_out
    );
end entity;

architecture rtl of cmd_parser_slave_generic is

    --------------------------------------------------------------------
    -- CHECK AXI: 4k boundary + burst semantics
    --------------------------------------------------------------------
    signal s_4k_check_ok    : std_logic := '1';
    signal s_burst_check_ok : std_logic := '1';

    --------------------------------------------------------------------
    -- REGISTRI 0WS
    --------------------------------------------------------------------
    signal s_reg0, s_reg1, s_reg2, s_reg3 : std_logic_vector(31 downto 0) := (others => '0');
    signal s_reg4, s_reg5, s_reg6, s_reg7 : std_logic_vector(31 downto 0) := (others => '0');

    --------------------------------------------------------------------
    -- RAM
    --------------------------------------------------------------------
    signal s_ram_cs   : std_logic := '0';
    signal s_ram_we   : std_logic := '0';
    signal s_ram_addr : unsigned(9 downto 0) := (others => '0');
    signal s_ram_wstrb : std_logic_vector(3 downto 0);
    signal s_ram_din  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ram_dout : std_logic_vector(31 downto 0);

    signal s_ram_read_valid : std_logic := '0';
    signal s_ram_ready      : std_logic := '0';
    signal s_ram_cmd_addr   : unsigned(9 downto 0) := (others => '0');

    --------------------------------------------------------------------
    -- WRITE STATE
    --------------------------------------------------------------------
    signal s_wr_active : std_logic := '0';
    signal s_wr_addr   : unsigned(31 downto 0) := (others => '0');
    signal s_wr_len    : integer := 0;
    signal s_wr_index  : integer := 0;
    signal s_bresp     : std_logic_vector(7 downto 0) := (others => '0');

    --------------------------------------------------------------------
    -- READ STATE
    --------------------------------------------------------------------
    signal s_rd_active      : std_logic := '0';
    signal s_rd_addr        : unsigned(31 downto 0) := (others => '0');
    signal s_rd_total_beats : integer := 0;
    signal s_rd_cmd_left    : integer := 0;
    signal s_rd_data_left   : integer := 0;
    signal s_rresp          : std_logic_vector(7 downto 0) := (others => '0');

    --------------------------------------------------------------------
    -- REGISTRI 0WS (combinatori)
    --------------------------------------------------------------------
    signal s_reg_ready_comb : std_logic;
    signal s_reg_data_comb  : std_logic_vector(31 downto 0);

    --------------------------------------------------------------------
    -- RAM CONTROL
    --------------------------------------------------------------------
    signal s_ram_cs_next    : std_logic;
    signal s_ram_we_next    : std_logic;
    signal s_ram_addr_next  : unsigned(9 downto 0);
    signal s_ram_wstrb_next : std_logic_vector(3 downto 0);
    signal s_ram_din_next   : std_logic_vector(31 downto 0);

    signal s_rvalid_ram : std_logic;

    --------------------------------------------------------------------
    -- FIFO SIGNALS
    --------------------------------------------------------------------
    signal s_fifo_in_data   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_fifo_in_valid  : std_logic := '0';
    signal s_fifo_in_ready  : std_logic;

    signal s_fifo_out_data  : std_logic_vector(31 downto 0);
    signal s_fifo_out_valid : std_logic;
    signal s_fifo_out_ready : std_logic;

    --------------------------------------------------------------------
    -- FSM
    --------------------------------------------------------------------
    type t_state is (
        S_IDLE,
        S_WRITE,
        S_WRITE_DONE,
        S_READ,
        S_DONE
    );
    signal s_state : t_state := S_IDLE;

    --------------------------------------------------------------------
    -- RISPOSTA (registri)
    --------------------------------------------------------------------
    signal s_rsp_valid     : std_logic := '0';
    signal s_rsp_last      : std_logic := '0';
    signal s_rsp_data      : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_rsp_id        : std_logic_vector(C_ID_WIDTH-1 downto 0) := (others => '0');
    signal s_rsp_err_valid : std_logic := '0';
    signal s_rsp_err_code  : std_logic_vector(7 downto 0) := (others => '0');
    signal s_rsp_err_info  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_rsp_err_id    : std_logic_vector(C_ID_WIDTH-1 downto 0) := (others => '0');

begin

    interrupts <= (others => '0');


    --------------------------------------------------------------------
    -- RAM
    --------------------------------------------------------------------
    u_ram : entity work.ram_sync_wstrb
        generic map (
            g_depth    => 2048,
            g_aw       => 10,
            g_cde_file => "ram_init.cde"
        )
        port map (
            clk   => clk,
            cs    => s_ram_cs,
            we    => s_ram_we,
            addr  => std_logic_vector(s_ram_addr),
            wstrb => s_ram_wstrb,
            din   => s_ram_din,
            dout  => s_ram_dout
        );

    --------------------------------------------------------------------
    -- FIFO
    --------------------------------------------------------------------
    u_fifo : entity work.gen_fifo
        generic map (
            gen_width => 32,
            gen_depth => 256
        )
        port map (
            clk          => clk,
            rstn         => resetn,
            s_in_tdata   => s_fifo_in_data,
            s_in_tvalid  => s_fifo_in_valid,
            s_in_tready  => s_fifo_in_ready,
            m_out_tdata  => s_fifo_out_data,
            m_out_tvalid => s_fifo_out_valid,
            m_out_tready => s_fifo_out_ready
        );

	--------------------------------------------------------------------
	-- Processo asincrono: verifica crossing 4k boundary
	--------------------------------------------------------------------
	boundary_check_proc : process(cmd)
		variable start_addr     : unsigned(31 downto 0);
		variable end_addr       : unsigned(31 downto 0);
		variable next_4k        : unsigned(31 downto 0);
		variable burst_len_live : integer;
		variable beat_bytes     : integer;
	begin
		-- Default: nessun errore
		s_4k_check_ok <= '1';

		-- Se non è burst, o è FIFO (indirizzo fisso), non c'è crossing
		if cmd.cmd_burst = '0' or cmd.cmd_fifo = '1' then
			s_4k_check_ok <= '1';

		else
			-- clamp(1..256)
			if cmd.cmd_len < 1 then
				burst_len_live := 1;
			elsif cmd.cmd_len > 256 then
				burst_len_live := 256;
			else
				burst_len_live := cmd.cmd_len;
			end if;

			beat_bytes := C_DATA_WIDTH / 8;

			start_addr := unsigned(cmd.cmd_addr);
			end_addr   := start_addr + to_unsigned(burst_len_live * beat_bytes, 32);

			-- Usa la tua funzione
			next_4k := next_4k_boundary(cmd.cmd_addr);

			-- AXI: crossing se end_addr > next_4k
			if end_addr > next_4k then
				s_4k_check_ok <= '0';
			else
				s_4k_check_ok <= '1';
			end if;
		end if;
	end process;

	--------------------------------------------------------------------
	-- Processo asincrono: verifica semantica del burst
	--------------------------------------------------------------------
	burst_check_proc : process(cmd)
		variable burst_len_live : integer;
		variable beat_bytes     : integer;
		variable addr_int       : integer;
	begin
		-- Default: OK
		s_burst_check_ok <= '1';

		-- clamp(1..256)
		if cmd.cmd_len < 1 then
			burst_len_live := 1;
		elsif cmd.cmd_len > 256 then
			burst_len_live := 256;
		else
			burst_len_live := cmd.cmd_len;
		end if;

		beat_bytes := C_DATA_WIDTH / 8;
		addr_int   := to_integer(unsigned(cmd.cmd_addr));

		-- SINGLE → nessun check
		if cmd.cmd_burst = '0' then
			s_burst_check_ok <= '1';

		-- FIFO (FIXED burst) → indirizzo fisso, nessun check
		elsif cmd.cmd_fifo = '1' then
			s_burst_check_ok <= '1';

		-- INCR e WRAP → indirizzo deve essere allineato al beat
		elsif (addr_int mod beat_bytes) /= 0 then
			s_burst_check_ok <= '0';

		-- WRAP → lunghezza deve essere potenza di due
		elsif cmd.cmd_wrap = '1' then
			if not (burst_len_live = 2 or
					burst_len_live = 4 or
					burst_len_live = 8 or
					burst_len_live = 16 or
					burst_len_live = 32 or
					burst_len_live = 64 or
					burst_len_live = 128 or
					burst_len_live = 256) then
				s_burst_check_ok <= '0';
			else
				s_burst_check_ok <= '1';
			end if;

		-- INCR valido
		else
			s_burst_check_ok <= '1';
		end if;
	end process;

	REG_READ_COMB : process(
		s_rd_active,
		s_rd_addr,
		s_reg0, s_reg1, s_reg2, s_reg3,
		s_reg4, s_reg5, s_reg6, s_reg7
	)
	begin
		s_reg_ready_comb <= '0';
		s_reg_data_comb  <= (others => '0');

		if s_rd_active = '1' and s_rd_addr < x"00000020" then
			s_reg_ready_comb <= '1';

			case s_rd_addr(4 downto 2) is
				when "000" => s_reg_data_comb <= s_reg0;
				when "001" => s_reg_data_comb <= s_reg1;
				when "010" => s_reg_data_comb <= s_reg2;
				when "011" => s_reg_data_comb <= s_reg3;
				when "100" => s_reg_data_comb <= s_reg4;
				when "101" => s_reg_data_comb <= s_reg5;
				when "110" => s_reg_data_comb <= s_reg6;
				when "111" => s_reg_data_comb <= s_reg7;
				when others => s_reg_data_comb <= (others => '0');
			end case;
		end if;
	end process REG_READ_COMB;

	RAM_CONTROL : process(
		s_wr_active,
		s_wr_addr,
		s_rd_active,
		s_rd_addr,
		s_rd_cmd_left,
		s_rd_total_beats,
		s_ram_cmd_addr,
		s_ram_addr,
		cmd,
		cmd_valid
	)
		variable v_cs    : std_logic;
		variable v_we    : std_logic;
		variable v_addr  : unsigned(9 downto 0);
		variable v_din   : std_logic_vector(31 downto 0);
		variable v_wstrb : std_logic_vector(3 downto 0);   -- ⭐ nuovo

		variable wrap_beats    : unsigned(9 downto 0);
		variable wrap_mask_idx : unsigned(9 downto 0);
		variable base_idx      : unsigned(9 downto 0);
		variable offset_idx    : unsigned(9 downto 0);
	begin
		v_cs    := '0';
		v_we    := '0';
		v_addr  := s_ram_addr;
		v_din   := (others => '0');

		-- ⭐ finché t_cmd_out non contiene WSTRB, usiamo sempre "1111"
		v_wstrb := (others => '1');

		--------------------------------------------------------------------
		-- WRITE su RAM
		--------------------------------------------------------------------
		if s_wr_active = '1' and
		s_wr_addr >= x"00001000" and s_wr_addr <= x"00002FFF" then

			v_cs   := '1';
			v_we   := '1';
			v_addr := unsigned(s_wr_addr(11 downto 2));
			v_din  := std_logic_vector(cmd.cmd_data(s_wr_index));
			v_wstrb := cmd.cmd_wstrb;

		--------------------------------------------------------------------
		-- READ da RAM
		--------------------------------------------------------------------
		elsif s_rd_active = '1' and
			s_rd_addr >= x"00001000" and s_rd_addr <= x"00002FFF" and
			s_rd_cmd_left > 0 then

			v_cs := '1';
			v_we := '0';

			if s_rd_cmd_left = s_rd_total_beats then
				v_addr := unsigned(s_rd_addr(11 downto 2));
			else
				if cmd.cmd_burst = '0' then
					v_addr := s_ram_cmd_addr;
				else
					if cmd.cmd_wrap = '0' then
						v_addr := s_ram_cmd_addr + 1;
					else
						wrap_beats    := resize(unsigned(to_unsigned(cmd.cmd_len, 10)), 10);
						wrap_mask_idx := not (wrap_beats - 1);
						base_idx      := unsigned(s_rd_addr(11 downto 2)) and wrap_mask_idx;
						offset_idx    := s_ram_cmd_addr - base_idx;
						offset_idx    := (offset_idx + 1) mod wrap_beats;
						v_addr        := base_idx + offset_idx;
					end if;
				end if;
			end if;
		end if;

		s_ram_cs_next    <= v_cs;
		s_ram_we_next    <= v_we;
		s_ram_addr_next  <= v_addr;
		s_ram_din_next   <= v_din;
		s_ram_wstrb_next <= v_wstrb;   -- ⭐ nuovo
	end process RAM_CONTROL;



	RAM_PROC : process(clk, resetn)
	begin
		if resetn = '0' then
			s_ram_cs         <= '0';
			s_ram_we         <= '0';
			s_ram_addr       <= (others => '0');
			s_ram_din        <= (others => '0');
			s_ram_wstrb      <= (others => '0');   -- ⭐ reset WSTRB
			s_ram_read_valid <= '0';
			s_ram_ready      <= '0';
			s_ram_cmd_addr   <= (others => '0');

		elsif rising_edge(clk) then
			s_ram_cs    <= s_ram_cs_next;
			s_ram_we    <= s_ram_we_next;
			s_ram_addr  <= s_ram_addr_next;
			s_ram_din   <= s_ram_din_next;
			s_ram_wstrb <= s_ram_wstrb_next;       -- ⭐ registrazione WSTRB

			if s_ram_cs_next = '1' and s_ram_we_next = '0' then
				s_ram_cmd_addr <= s_ram_addr_next;
			end if;

			s_ram_read_valid <= s_ram_cs_next and (not s_ram_we_next);
			s_ram_ready      <= s_ram_read_valid;
		end if;
	end process RAM_PROC;

	s_rvalid_ram <= s_ram_ready and s_rd_active;

	FIFO_READ_READY : process(s_rd_active, s_rd_addr)
	begin
		if s_rd_active = '1' and s_rd_addr = x"00003100" then
			s_fifo_out_ready <= '1';
		else
			s_fifo_out_ready <= '0';
		end if;
	end process FIFO_READ_READY;

	FSM_MAIN : process(clk, resetn)
		variable wrap_size  : unsigned(31 downto 0);
		variable wrap_mask  : unsigned(31 downto 0);
		variable wrap_base  : unsigned(31 downto 0);
		variable offset     : unsigned(31 downto 0);
		variable v_valid    : std_logic;
	begin
		if resetn = '0' then
			s_state          <= S_IDLE;
			cmd_ready        <= '1';

			s_wr_active      <= '0';
			s_wr_len         <= 0;
			s_wr_index       <= 0;
			s_wr_addr        <= (others => '0');
			s_bresp          <= (others => '0');

			s_rd_active      <= '0';
			s_rd_addr        <= (others => '0');
			s_rd_total_beats <= 0;
			s_rd_cmd_left    <= 0;
			s_rd_data_left   <= 0;
			s_rresp          <= (others => '0');

			s_fifo_in_valid  <= '0';
			s_fifo_in_data   <= (others => '0');

			s_rsp_valid      <= '0';
			s_rsp_last       <= '0';
			s_rsp_data       <= (others => '0');
			s_rsp_id         <= (others => '0');
			s_rsp_err_valid  <= '0';
			s_rsp_err_code   <= (others => '0');
			s_rsp_err_info   <= (others => '0');
			s_rsp_err_id     <= (others => '0');

		elsif rising_edge(clk) then

			-- consumo errore (il parser lo guarda, non lo modula)
			if s_rsp_err_valid = '1' then
				-- lo teniamo a 1 solo per un ciclo
				s_rsp_err_valid <= '0';
			end if;

			-- default per ogni ciclo
			s_fifo_in_valid <= '0';
			s_rsp_valid     <= '0';
			s_rsp_last      <= '0';

			case s_state is

				----------------------------------------------------------------
				-- IDLE: accetto un nuovo comando
				----------------------------------------------------------------
				when S_IDLE =>
					cmd_ready <= '1';

					if cmd_valid = '1' then
						cmd_ready       <= '0';
						s_rsp_id        <= std_logic_vector(cmd.cmd_id);
						s_rsp_err_id    <= std_logic_vector(cmd.cmd_id);
						s_rsp_err_info  <= std_logic_vector(cmd.cmd_addr);

						----------------------------------------------------------------
						-- ⭐ CHECK 4K BOUNDARY
						----------------------------------------------------------------
						if s_4k_check_ok = '0' then
							s_rsp_valid     <= '1';
							s_rsp_last      <= '1';
							s_rsp_err_valid <= '1';
							s_rsp_err_code  <= std_logic_vector(to_unsigned(6,8)); -- BOUNDARY_ERR
							s_rsp_data      <= (others => '0');

							s_state <= S_DONE;

						----------------------------------------------------------------
						-- ⭐ CHECK BURST SEMANTICS
						----------------------------------------------------------------
						elsif s_burst_check_ok = '0' then
							s_rsp_valid     <= '1';
							s_rsp_last      <= '1';
							s_rsp_err_valid <= '1';
							s_rsp_err_code  <= std_logic_vector(to_unsigned(7,8)); -- BURST_ERR
							s_rsp_data      <= (others => '0');

							s_state <= S_DONE;

						----------------------------------------------------------------
						-- ⭐ Se tutto OK → dispatch WRITE / READ
						----------------------------------------------------------------
						elsif cmd.cmd_write = '1' then
							------------------------------------------------------------
							-- WRITE
							------------------------------------------------------------
							s_wr_active <= '1';
							s_wr_addr   <= unsigned(cmd.cmd_addr);
							s_wr_len    <= cmd.cmd_len;
							s_wr_index  <= 0;

							-- DECERR se indirizzo fuori range
							if (unsigned(cmd.cmd_addr) < x"00000020") or
							(unsigned(cmd.cmd_addr) >= x"00001000" and unsigned(cmd.cmd_addr) <= x"00002FFF") or
							(unsigned(cmd.cmd_addr) = x"00003000") then
								s_bresp <= x"00";  -- OKAY
							else
								s_bresp <= x"03";  -- DECERR
							end if;

							s_state <= S_WRITE;

						else
							------------------------------------------------------------
							-- READ
							------------------------------------------------------------
							s_rd_active      <= '1';
							s_rd_addr        <= unsigned(cmd.cmd_addr);

							-- clamp AXI-style
							if cmd.cmd_len < 1 then
								s_rd_total_beats <= 1;
								s_rd_cmd_left    <= 1;
								s_rd_data_left   <= 1;
							elsif cmd.cmd_len > 256 then
								s_rd_total_beats <= 256;
								s_rd_cmd_left    <= 256;
								s_rd_data_left   <= 256;
							else
								s_rd_total_beats <= cmd.cmd_len;
								s_rd_cmd_left    <= cmd.cmd_len;
								s_rd_data_left   <= cmd.cmd_len;
							end if;

							if (unsigned(cmd.cmd_addr) < x"00000020") or
							(unsigned(cmd.cmd_addr) >= x"00001000" and unsigned(cmd.cmd_addr) <= x"00002FFF") or
							(unsigned(cmd.cmd_addr) = x"00003100") then
								s_rresp <= x"00";  -- OKAY
							else
								s_rresp <= x"03";  -- DECERR
							end if;

							s_state <= S_READ;
						end if;
					end if;

				----------------------------------------------------------------
				-- WRITE: eseguo la write e mando telemetria su rsp_valid/rsp_data
				----------------------------------------------------------------
				when S_WRITE =>
					if s_wr_active = '1' then

						----------------------------------------------------------------
						-- FIFO WRITE @ 0x00003000
						----------------------------------------------------------------
						if s_wr_addr = x"00003000" then
							if s_fifo_in_ready = '0' then
								s_bresp <= x"02";  -- SLVERR
							else
								s_fifo_in_data  <= std_logic_vector(cmd.cmd_data(s_wr_index));
								s_fifo_in_valid <= '1';
								s_bresp         <= x"00";
							end if;

						----------------------------------------------------------------
						-- REGISTRI 0WS
						----------------------------------------------------------------
						elsif s_wr_addr < x"00000020" then
							case s_wr_addr(4 downto 2) is
								when "000" => s_reg0 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "001" => s_reg1 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "010" => s_reg2 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "011" => s_reg3 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "100" => s_reg4 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "101" => s_reg5 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "110" => s_reg6 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when "111" => s_reg7 <= std_logic_vector(cmd.cmd_data(s_wr_index));
								when others => null;
							end case;

						----------------------------------------------------------------
						-- RAM WRITE @ 0x00001000–0x00002FFF
						----------------------------------------------------------------
						elsif s_wr_addr >= x"00001000" and s_wr_addr <= x"00002FFF" then
							-- già gestito da RAM_CONTROL (cs/we/addr/din)
							null;

						else
							s_bresp <= x"03"; -- DECERR
						end if;

						----------------------------------------------------------------
						-- TELEMETRIA WRITE verso il parser
						----------------------------------------------------------------
						s_rsp_valid <= '1';
						s_rsp_data  <= std_logic_vector(cmd.cmd_data(s_wr_index));
						s_rsp_id    <= std_logic_vector(cmd.cmd_id);

						if s_wr_index = s_wr_len - 1 then
							s_rsp_last <= '1';
						else
							s_rsp_last <= '0';
						end if;

						----------------------------------------------------------------
						-- avanzamento burst WRITE
						----------------------------------------------------------------
						if s_wr_index < s_wr_len - 1 then
							s_wr_index <= s_wr_index + 1;

							-- avanzamento indirizzo WRITE
							if cmd.cmd_fifo = '1' then
								-- FIFO: indirizzo fisso
								null;

							elsif cmd.cmd_burst = '0' then
								-- single beat: indirizzo fisso
								null;

							else
								-- burst normale
								if cmd.cmd_wrap = '0' then
									s_wr_addr <= s_wr_addr + 4;
								else
									wrap_size := to_unsigned(s_wr_len * 4, 32);
									wrap_mask := not (wrap_size - 1);
									wrap_base := unsigned(cmd.cmd_addr) and wrap_mask;
									offset    := (s_wr_addr + 4) - wrap_base;
									offset    := offset mod wrap_size;
									s_wr_addr <= wrap_base + offset;
								end if;
							end if;

						else
							s_wr_active <= '0';
							s_state     <= S_WRITE_DONE;
						end if;
					end if;

				----------------------------------------------------------------
				-- WRITE_DONE: fine comando write, emulo bresp con rsp_err_valid
				----------------------------------------------------------------
				when S_WRITE_DONE =>
					s_rsp_err_valid <= '1';
					s_rsp_err_code  <= s_bresp;
					s_state         <= S_DONE;

				----------------------------------------------------------------
				-- READ: produco dati e allineo rsp_err_valid all'ultimo beat
				----------------------------------------------------------------
				when S_READ =>

					-- tracking RAM commands
					if s_ram_cs_next = '1' and s_ram_we_next = '0' and
					s_rd_cmd_left > 0 then
						s_rd_cmd_left <= s_rd_cmd_left - 1;
					end if;

					----------------------------------------------------------------
					-- selezione sorgente dati
					----------------------------------------------------------------
					v_valid := '0';

					if s_rd_addr < x"00000020" then
						v_valid := s_reg_ready_comb;

					elsif s_rd_addr >= x"00001000" and s_rd_addr <= x"00002FFF" then
						v_valid := s_rvalid_ram;

					elsif s_rd_addr = x"00003100" then
						v_valid := s_fifo_out_valid;

					else
						v_valid := '1';  -- indirizzo invalido → dato zero + DECERR
					end if;

					----------------------------------------------------------------
					-- produzione dati READ (nessun uso di rsp_ready)
					----------------------------------------------------------------
					if v_valid = '1' and s_rd_data_left > 0 then

						if s_rd_addr = x"00003100" then
							----------------------------------------------------------------
							-- FIFO READ
							----------------------------------------------------------------
							if s_fifo_out_valid = '0' then
								s_rresp    <= x"02";  -- SLVERR
								s_rsp_data <= (others => '0');
							else
								s_rresp    <= x"00";  -- OKAY
								s_rsp_data <= s_fifo_out_data;
							end if;

						else
							----------------------------------------------------------------
							-- REGISTRI + RAM + indirizzi invalidi
							----------------------------------------------------------------
							if s_rd_addr < x"00000020" then
								s_rsp_data <= s_reg_data_comb;
								s_rresp    <= x"00";

							elsif s_rd_addr >= x"00001000" and s_rd_addr <= x"00002FFF" then
								s_rsp_data <= s_ram_dout;
								s_rresp    <= x"00";

							else
								s_rsp_data <= (others => '0');
								s_rresp    <= x"03";  -- DECERR
							end if;
						end if;

						s_rsp_valid <= '1';
						s_rsp_id    <= std_logic_vector(cmd.cmd_id);

						if s_rd_data_left = 1 then
							----------------------------------------------------------------
							-- ultimo beat READ → rsp_last + rsp_err_valid
							----------------------------------------------------------------
							s_rsp_last      <= '1';
							s_rsp_err_valid <= '1';
							s_rsp_err_code  <= s_rresp;

							s_rd_data_left  <= 0;
							s_rd_active     <= '0';
							s_state         <= S_DONE;

						else
							s_rd_data_left <= s_rd_data_left - 1;

							-- avanzamento indirizzo READ
							if cmd.cmd_fifo = '1' then
								-- FIFO: indirizzo fisso
								null;

							elsif cmd.cmd_burst = '0' then
								-- single beat: indirizzo fisso
								null;

							else
								-- burst normale
								if cmd.cmd_wrap = '0' then
									s_rd_addr <= s_rd_addr + 4;
								else
									wrap_size := to_unsigned(s_rd_total_beats * 4, 32);
									wrap_mask := not (wrap_size - 1);
									wrap_base := unsigned(cmd.cmd_addr) and wrap_mask;
									offset    := (s_rd_addr + 4) - wrap_base;
									offset    := offset mod wrap_size;
									s_rd_addr <= wrap_base + offset;
								end if;
							end if;
						end if;
					end if;

				----------------------------------------------------------------
				-- DONE: fine comando, rialzo cmd_ready
				----------------------------------------------------------------
				when S_DONE =>
					cmd_ready <= '1';
					s_state   <= S_IDLE;

			end case;
		end if;
	end process FSM_MAIN;

	OUTPUT_MAP : process(
		s_rsp_valid,
		s_rsp_last,
		s_rsp_data,
		s_rsp_id,
		s_rsp_err_valid,
		s_rsp_err_code,
		s_rsp_err_info,
		s_rsp_err_id
	)
	begin
		rsp_valid.rsp_valid     <= s_rsp_valid;
		rsp_valid.rsp_last      <= s_rsp_last;
		rsp_valid.rsp_data      <= s_rsp_data;
		rsp_valid.rsp_id        <= s_rsp_id;

		rsp_valid.rsp_err_valid <= s_rsp_err_valid;
		rsp_valid.rsp_err_code  <= s_rsp_err_code;
		rsp_valid.rsp_err_info  <= s_rsp_err_info;
		rsp_valid.rsp_err_id    <= s_rsp_err_id;
	end process OUTPUT_MAP;

end architecture;
