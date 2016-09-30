# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './data'
require './board'
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
