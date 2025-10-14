library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_pkg.all;

entity alu is
  generic ( N : integer := 32 );
  port(
    A  : in  std_logic_vector(N-1 downto 0);
    B  : in  std_logic_vector(N-1 downto 0);
    OP : in  std_logic_vector(3 downto 0);
    Y  : out std_logic_vector(N-1 downto 0);
    Z  : out std_logic;  -- zero
    C  : out std_logic;  -- carry / ~borrow en SUB
    V  : out std_logic;  -- overflow
    Nf : out std_logic   -- negativo
  );
end entity;

architecture alu_arq of alu is
  function clog2(n: integer) return integer is
    variable r: integer := 0; variable v: integer := n-1;
  begin
    while v > 0 loop r := r + 1; v := v / 2; end loop;
    if r = 0 then return 1; else return r; end if;
  end function;
  constant SHW : integer := clog2(N);

  signal add_ext : unsigned(N downto 0);
  signal sub_ext : unsigned(N downto 0);
  signal y_next  : std_logic_vector(N-1 downto 0);
  signal c_next  : std_logic := '0';
  signal v_next  : boolean := false;
  signal shamt   : integer range 0 to N-1;
begin
  add_ext <= unsigned('0' & A) + unsigned('0' & B);
  sub_ext <= unsigned('0' & A) + unsigned('0' & (not B)) + 1;

  shamt <= to_integer(unsigned(B(SHW-1 downto 0)));

  process(A,B,OP,add_ext,sub_ext,shamt)
    variable As : signed(N-1 downto 0);
    variable Bs : signed(N-1 downto 0);
    variable Yv : std_logic_vector(N-1 downto 0);
    variable Cv : std_logic := '0';
    variable Vv : boolean := false;
  begin
    As := signed(A);
    Bs := signed(B);
    Yv := (others => '0'); Cv := '0'; Vv := false;

    case OP is
      when OP_ADD =>
        Yv := std_logic_vector(add_ext(N-1 downto 0));
        Cv := add_ext(N);
        Vv := (A(N-1)=B(N-1)) and (Yv(N-1)/=A(N-1));

      when OP_SUB =>
        Yv := std_logic_vector(sub_ext(N-1 downto 0));
        Cv := sub_ext(N);
        Vv := (A(N-1)/=B(N-1)) and (Yv(N-1)/=A(N-1));

      when OP_AND => Yv := A and B;
      when OP_OR  => Yv := A or  B;
      when OP_XOR => Yv := A xor B;

      when OP_SLL =>
        Yv := std_logic_vector(shift_left(unsigned(A), shamt));

      when OP_SRL =>
        Yv := std_logic_vector(shift_right(unsigned(A), shamt));

      when OP_SRA =>
        Yv := std_logic_vector(shift_right(signed(A), shamt));

      when OP_SLT =>
        if As < Bs then Yv := (others => '0'); Yv(0) := '1'; else Yv := (others => '0'); end if;

      when OP_SLTU =>
        if unsigned(A) < unsigned(B) then Yv := (others => '0'); Yv(0) := '1'; else Yv := (others => '0'); end if;

      when others =>
        Yv := (others => '0');
    end case;

    y_next <= Yv;
    c_next <= Cv;
    v_next <= Vv;
  end process;

  Y  <= y_next;
  C  <= c_next;
  V  <= '1' when v_next else '0';
  Z  <= '1' when (unsigned(y_next) = 0) else '0';
  Nf <= y_next(N-1);
end architecture;
