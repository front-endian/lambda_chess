# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './data'
require './board'
require './piece'
require 'tet'

class Proc
  def to_i
    self.call(proc { |x| x + 1 }, 0)
  end

  def to_a length
    result = []
    part   = self

    length.times do
      result.push(LEFT[part])
      part = RIGHT[part]
    end

    result
  end
end

class Fixnum
  def to_peano
    proc do |func, result|
      self.times { result = func.call(result) }
      result
    end
  end
end

class Array
  def to_linked_list
    self.reverse.inject(ZERO) do |previous, element|
      PAIR[element, previous]
    end
  end
end

index_array = [0,  1,  2,  3,  4,  5,  6,  7,
               8,  9,  10, 11, 12, 13, 14, 15,
               16, 17, 18, 19, 20, 21, 22, 23,
               24, 25, 26, 27, 28, 29, 30, 31,
               32, 33, 34, 35, 36, 37, 38, 39,
               40, 41, 42, 43, 44, 45, 46, 47,
               48, 49, 50, 51, 52, 53, 54, 55,
               56, 57, 58, 59, 60, 61, 62, 63]

group 'Choice Functions' do
  group 'AND' do
    assert 'returns a FIRST when given two FIRSTs' do
      AND[FIRST, FIRST][true, false]
    end

    assert 'returns a SECOND when given a FIRST and a SECOND' do
      AND[FIRST, SECOND][false, true]
    end

    assert 'returns a SECOND when given two SECONDs' do
      AND[SECOND, SECOND][false, true]
    end
  end

  group 'OR' do
    assert 'returns a FIRST when given two FIRSTs' do
      OR[FIRST, FIRST][true, false]
    end

    assert 'returns a FIRST when given a FIRST and a SECOND' do
      OR[FIRST, SECOND][true, false]
    end

    assert 'returns a SECOND when given two SECONDs' do
      OR[SECOND, SECOND][false, true]
    end
  end
end

group 'Pair Functions' do
  group 'NTH' do
    example = [:A, :B, :C].to_linked_list

    assert 'gets the first element when given 0' do
      :A == NTH[example, 0.to_peano]
    end

    assert 'gets the third element when given 2' do
      :C == NTH[example, 2.to_peano]
    end
  end

  group 'LIST_MAP' do
    assert 'maps function across board and returns a new board' do
      incremented = LIST_MAP[
                      index_array.to_linked_list,
                      64.to_peano,
                      ->(x, _) { x + 1 }
                    ].to_a(64)

      incremented == index_array.map { |x| x + 1 }
    end

    assert 'second argument gives current position index' do
      empty_board   = ([nil] * 64).to_linked_list
      given_indexes = LIST_MAP[
                        empty_board,
                        64.to_peano,
                        ->(_, i) { i.to_i }
                      ].to_a(64)

      given_indexes == index_array
    end
  end
end

group 'Math Functions' do
  group 'ADD' do
    assert 'adds two numbers together' do
      11 == ADD[8.to_peano, 3.to_peano].to_i
    end

    assert 'works with zero' do
      36 == ADD[0.to_peano, 36.to_peano].to_i
    end
  end

  group 'DECREMENT' do
    assert 'subtracts one from the given number' do
      99 == DECREMENT[100.to_peano].to_i
    end

    assert 'given zero returns zero' do
      0 == DECREMENT[0.to_peano].to_i
    end
  end

  group 'SUBTRACT' do
    assert 'subtracts the second number from the first number' do
      10 == SUBTRACT[20.to_peano, 10.to_peano].to_i
    end

    assert 'floors at zero' do
      0 == SUBTRACT[3.to_peano, 5.to_peano].to_i
    end
  end

  group 'MULTIPLY' do
    assert 'multiplies two numbers together' do
      8 == MULTIPLY[2.to_peano, 4.to_peano].to_i
    end

    assert 'works with zero' do
      0 == MULTIPLY[0.to_peano, 23.to_peano].to_i
    end
  end

  group 'DIVIDE' do
    assert 'divides two integers' do
     6 == DIVIDE[30.to_peano, 5.to_peano].to_i
    end

    assert 'rounds down' do
     6 == DIVIDE[32.to_peano, 5.to_peano].to_i
    end
  end

  group 'MODULUS' do
    assert 'returns the remainder of division' do
     2 == MODULUS[12.to_peano, 5.to_peano].to_i
    end

    assert 'returns the first argument when the second argument is larger' do
     4 == MODULUS[4.to_peano, 10.to_peano].to_i
    end
  end

  group 'ABSOLUTE_DIFFERENCE' do
    assert 'returns difference when second argument is smaller' do
      7 == ABSOLUTE_DIFFERENCE[10.to_peano, 3.to_peano].to_i
    end

    assert 'returns absolute value of difference when second argument is larger' do
      18 == ABSOLUTE_DIFFERENCE[2.to_peano, 20.to_peano].to_i
    end
  end
end

group 'Comparison Functions' do
  group 'IS_ZERO' do
    assert 'returns FIRST when given zero' do
      IS_ZERO[0.to_peano][true, false]
    end

    assert 'returns SECOND when given a non-zero number' do
      IS_ZERO[9.to_peano][false, true]
    end
  end

  group 'IS_GREATER_OR_EQUAL' do
    assert 'returns FIRST when greater' do
      IS_GREATER_OR_EQUAL[2.to_peano, 1.to_peano][true, false]
    end

    assert 'returns FIRST when equal' do
      IS_GREATER_OR_EQUAL[5.to_peano, 5.to_peano][true, false]
    end

    assert 'returns SECOND when less' do
      IS_GREATER_OR_EQUAL[4.to_peano, 9.to_peano][false, true]
    end
  end

  group 'IS_EQUAL' do
    assert 'returns FIRST when equal' do
      IS_EQUAL[6.to_peano, 6.to_peano][true, false]
    end

    assert 'returns SECOND when greater' do
      IS_EQUAL[7.to_peano, 2.to_peano][false, true]
    end

    assert 'returns SECOND when less' do
      IS_EQUAL[1.to_peano, 4.to_peano][false, true]
    end
  end

  group 'COMPARE' do
    assert 'returns first option when first argument is less than the second' do
      COMPARE[2.to_peano, 9.to_peano][true, false, false]
    end

    assert 'returns second option when first argument is equal to the second' do
      COMPARE[4.to_peano, 4.to_peano][false, true, false]
    end

    assert 'returns third option when first argument is equal to the second' do
      COMPARE[8.to_peano, 3.to_peano][false, false, true]
    end
  end
end

group 'Board Functions' do
  group 'POSITION_TO_INDEX' do
    assert 'translates X/Y pair into an array index' do
      POSITION_TO_INDEX[PAIR[2.to_peano, 4.to_peano]].to_i == 34
    end

    assert 'works with zero' do
      POSITION_TO_INDEX[PAIR[6.to_peano, 0.to_peano]].to_i == 6
    end
  end

  group 'INDEX_TO_POSITION' do
    assert 'translates array index into an X/Y pair' do
      30 == POSITION_TO_INDEX[INDEX_TO_POSITION[30.to_peano]].to_i
    end

    assert 'works with zero' do
      0 == POSITION_TO_INDEX[INDEX_TO_POSITION[0.to_peano]].to_i
    end
  end

  group 'DISTANCE' do
    position_1 = PAIR[2.to_peano, 10.to_peano]
    position_2 = PAIR[5.to_peano, 15.to_peano]
    expected   = [3, 5]

    assert 'returns distance of the X and Y coordinates' do
      result = DISTANCE[position_1, position_2]

      expected == [LEFT[result], RIGHT[result]].map(&:to_i)
    end

    assert 'argument order does not matter' do
      result = DISTANCE[position_2, position_1]

      expected == [LEFT[result], RIGHT[result]].map(&:to_i)
    end
  end

  group 'GET_POSITION' do
    assert 'gets data at the given position' do
      board = [:A, :B, :C].to_linked_list

      :B == GET_POSITION[board, PAIR[1.to_peano, 0.to_peano]]
    end
  end

  group 'FREE_PATH' do
    center = PAIR[3.to_peano, 3.to_peano]

    def shifted delta_x, delta_y
      PAIR[(3 + delta_x).to_peano, (3 + delta_y).to_peano]
    end

    group 'returns FIRST if there are no pieces in the way' do
      example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 1, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0]
                      .map(&:to_peano)
                      .to_linked_list

      assert 'horizontally' do
        FREE_PATH[example_board, center, shifted(3, 0), DECREMENT][true, false]
      end

      assert 'vertically' do
        FREE_PATH[example_board, center, shifted(0, -3), DECREMENT][true, false]
      end

      assert 'diagonally' do
        FREE_PATH[example_board, center, shifted(-3, 3), DECREMENT][true, false]
      end
    end

    group 'if the only piece in the way is at the TO location' do
      group 'returns FIRST if told to DECREMENT length' do
        assert 'horizontally' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           7, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(-3, 0), DECREMENT][true, false]
        end

        assert 'vertically' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(0, 4), DECREMENT][true, false]
        end

        assert 'diagonally' do
          example_board = [0, 0, 0, 0, 0, 0, 7, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(3, -3), DECREMENT][true, false]
        end
      end

      group 'returns SECOND if told to not alter the length' do
        assert 'horizontally' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           7, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(-3, 0), IDENTITY][false, true]
        end

        assert 'vertically' do
          example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(0, 4), IDENTITY][false, true]
        end

        assert 'diagonally' do
          example_board = [0, 0, 0, 0, 0, 0, 7, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 7, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0,
                           0, 0, 0, 0, 0, 0, 0, 0]
                          .map(&:to_peano)
                          .to_linked_list

          FREE_PATH[example_board, center, shifted(3, -3), IDENTITY][false, true]
        end
      end
    end

    group 'returns SECOND if there is a piece in the way' do
      assert 'horizontally' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 7, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

        FREE_PATH[example_board, center, shifted(4, 0), DECREMENT][false, true]
      end

      assert 'vertically' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

        FREE_PATH[example_board, center, shifted(0, -3), DECREMENT][false, true]
      end

      assert 'diagonally' do
        example_board = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 7, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 7, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

        FREE_PATH[example_board, center, shifted(-3, 3), DECREMENT][false, true]
      end
    end
  end

  group 'MOVE' do
    from  = PAIR[2.to_peano, 2.to_peano]
    to    = PAIR[3.to_peano, 7.to_peano]
    moved = MOVE[index_array.to_linked_list, from, to]

    assert 'moves the piece at the "from" position to the "to" position' do
      GET_POSITION[moved, to].to_i == index_array[POSITION_TO_INDEX[from].to_i]
    end

    assert 'puts a zero in the "from" position' do
      GET_POSITION[moved, from].to_i == 0
    end
  end

  group 'INITIAL_BOARD' do
    assert 'is initialized to the correct values' do
      INITIAL_BOARD.to_a(64).map(&:to_i) == [5,  3,  4,  9,  10, 4,  3,  5,
                                             1,  1,  1,  1,  1,  1,  1,  1,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             0,  0,  0,  0,  0,  0,  0,  0,
                                             11, 11, 11, 11, 11, 11, 11, 11,
                                             15, 13, 14, 19, 20, 14, 13, 15]
    end
  end
end

group 'Piece Functions' do
  nothing_surrounding = [0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 7, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0,
                         0, 0, 0, 0, 0, 0, 0, 0]
                        .map(&:to_peano)
                        .to_linked_list

  surrounded = [0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 7, 7, 7, 0, 0,
                0, 0, 0, 7, 7, 7, 0, 0,
                0, 0, 0, 7, 7, 7, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0, 0]
               .map(&:to_peano)
               .to_linked_list

  def test_movement board, should, func, delta_x, delta_y
    func[
      board,
      PAIR[4.to_peano, 4.to_peano],
      PAIR[
        (4 + delta_x).to_peano,
        (4 + delta_y).to_peano
      ]
    ][
      should,
      !should
    ]
  end

  def horizontal_movement board, delta, should, func
    group "can#{' not' unless should}" do
      assert 'left' do
        test_movement board, should, func, -delta, 0
      end

      assert 'right' do
        test_movement board, should, func, delta, 0
      end

      assert 'up' do
        test_movement board, should, func, 0, delta
      end

      assert 'down' do
        test_movement board, should, func, 0, -delta
      end
    end
  end

  def diagonal_movement board, delta, should, func
    group "can#{' not' unless should}" do
      assert 'up + left' do
        test_movement board, should, func, -delta, delta
      end

      assert 'up + right' do
        test_movement board, should, func, delta, delta
      end

      assert 'down + left' do
        test_movement board, should, func, -delta, -delta
      end

      assert 'down + right' do
        test_movement board, should, func, -delta, -delta
      end
    end
  end

  group 'ROOK' do
    horizontal_movement nothing_surrounding, 3, true,  ROOK
    diagonal_movement   nothing_surrounding, 3, false, ROOK

    group 'if a piece is in the way' do
      horizontal_movement surrounded, 3, false,  ROOK
    end
  end

  group 'BISHOP' do
    horizontal_movement nothing_surrounding, 3, false, BISHOP
    diagonal_movement   nothing_surrounding, 3, true,  BISHOP

    group 'if a piece is in the way' do
      diagonal_movement surrounded, 3, false,  BISHOP
    end
  end

  group 'KING' do
    horizontal_movement nothing_surrounding, 1, true, KING
    diagonal_movement   nothing_surrounding, 1, true, KING

    assert 'cannot move more than one' do
      KING[
        nothing_surrounding,
        PAIR[4.to_peano, 4.to_peano],
        PAIR[2.to_peano, 4.to_peano]
      ][false, true]
    end

    assert 'cannot move arbitrarily' do
      KING[
        nothing_surrounding,
        PAIR[4.to_peano, 4.to_peano],
        PAIR[3.to_peano, 6.to_peano]
      ][false, true]
    end
  end

  group 'KNIGHT' do
    def knights_moves board
      assert 'can make knights moves' do
        [
          [ 2,  1], [ 1,  2],
          [-2,  1], [-1,  2],
          [ 2, -1], [ 1, -2],
          [-2, -1], [-1, -2]
        ].map do |pair|
          pair.map { |x| (x + 4).to_peano }
        end
        .all? do |pair|
          KNIGHT[
            board,
            PAIR[4.to_peano, 4.to_peano],
            PAIR[*pair]
          ][
            true,
            false
          ]
        end
      end
    end

    knights_moves nothing_surrounding

    group 'if a piece is in the way' do
      knights_moves surrounded
    end

    assert 'cannot move elsewhere' do
      KNIGHT[
        nothing_surrounding,
        PAIR[4.to_peano, 4.to_peano],
        PAIR[-4.to_peano, 7.to_peano]
      ][false, true]
    end
  end

  group 'PAWN' do
    starting_board = [0, 0, 0, 0, 0, 0, 0, 0,
                      0, 1, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 11,0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0]
                     .map(&:to_peano)
                     .to_linked_list

    group 'can move forward by one' do
      assert 'white' do
        PAWN[
          starting_board,
          PAIR[4.to_peano, 6.to_peano],
          PAIR[4.to_peano, 5.to_peano]
        ][
          true,
          false
        ]
      end

      assert 'black' do
        PAWN[
          starting_board,
          PAIR[1.to_peano, 1.to_peano],
          PAIR[1.to_peano, 2.to_peano]
        ][
          true,
          false
        ]
      end
    end

    group 'can move forward by two on the first move' do
      assert 'white' do
        PAWN[
          starting_board,
          PAIR[4.to_peano, 6.to_peano],
          PAIR[4.to_peano, 4.to_peano]
        ][
          true,
          false
        ]
      end

      assert 'black' do
        PAWN[
          starting_board,
          PAIR[1.to_peano, 1.to_peano],
          PAIR[1.to_peano, 3.to_peano]
        ][
          true,
          false
        ]
      end
    end

    group 'cannot move forward by two on subsequent moves' do
      later_board = [0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     0, 1, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 11,0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0,
                     0, 0, 0, 0, 0, 0, 0, 0]
                    .map(&:to_peano)
                    .to_linked_list

      assert 'white' do
        PAWN[
          later_board,
          PAIR[4.to_peano, 5.to_peano],
          PAIR[4.to_peano, 3.to_peano]
        ][
          false,
          true
        ]
      end

      assert 'black' do
        PAWN[
          later_board,
          PAIR[1.to_peano, 2.to_peano],
          PAIR[1.to_peano, 4.to_peano]
        ][
          false,
          true
        ]
      end
    end

    group 'cannot move backwards' do
      assert 'white' do
        PAWN[
          starting_board,
          PAIR[4.to_peano, 6.to_peano],
          PAIR[4.to_peano, 7.to_peano]
        ][
          false,
          true
        ]
      end

      assert 'black' do
        PAWN[
          starting_board,
          PAIR[1.to_peano, 1.to_peano],
          PAIR[1.to_peano, 0.to_peano]
        ][
          false,
          true
        ]
      end
    end

    group 'cannot move diagonally' do
      assert 'white' do
        PAWN[
          starting_board,
          PAIR[4.to_peano, 6.to_peano],
          PAIR[5.to_peano, 5.to_peano]
        ][
          false,
          true
        ]
      end

      assert 'black' do
        PAWN[
          starting_board,
          PAIR[1.to_peano, 1.to_peano],
          PAIR[0.to_peano, 2.to_peano]
        ][
          false,
          true
        ]
      end
    end

    group 'can capture forward diagonally' do
      capture_board = [0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 1, 0, 0, 0, 0, 0, 0,
                       7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 7, 0, 0,
                       0, 0, 0, 0, 11,0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0]
                      .map(&:to_peano)
                      .to_linked_list

      assert 'white' do
        PAWN[
          capture_board,
          PAIR[4.to_peano, 5.to_peano],
          PAIR[5.to_peano, 4.to_peano]
        ][
          true,
          false
        ]
      end

      assert 'black' do
        PAWN[
          capture_board,
          PAIR[1.to_peano, 2.to_peano],
          PAIR[0.to_peano, 3.to_peano]
        ][
          true,
          false
        ]
      end
    end

    group 'cannot capture backwards diagonally' do
      capture_board = [0, 0, 0, 0, 0, 0, 0, 0,
                       7, 0, 0, 0, 0, 0, 0, 0,
                       0, 1, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 11,0, 0, 0,
                       0, 0, 0, 0, 0, 7, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0]
                      .map(&:to_peano)
                      .to_linked_list

      assert 'white' do
        PAWN[
          capture_board,
          PAIR[4.to_peano, 5.to_peano],
          PAIR[5.to_peano, 6.to_peano]
        ][
          false,
          true
        ]
      end

      assert 'black' do
        PAWN[
          capture_board,
          PAIR[1.to_peano, 2.to_peano],
          PAIR[0.to_peano, 1.to_peano]
        ][
          false,
          true
        ]
      end
    end
  end
end
