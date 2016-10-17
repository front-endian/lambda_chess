# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require 'tet'
require './../data'
require './../board'
require './../pieces'
require './../play'

class Proc
  def to_i
    call proc { |x| x + 1 }, 0
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
      times { result = func.call(result) }
      result
    end
  end
end

class Array
  def to_linked_list
    reverse.inject(ZERO) do |previous, element|
      PAIR[element, previous]
    end
  end

  def to_board
    map do |row|
      row.map do |piece|
        piece.is_a?(Proc) ? piece : EMPTY_SPACE
      end.to_linked_list
    end.to_linked_list
  end
end

def position x, y
  PAIR[x.to_peano, y.to_peano]
end

def shift_position position, delta_x, delta_y
  PAIR[
     (LEFT[position].to_i + delta_x).to_peano,
    (RIGHT[position].to_i + delta_y).to_peano
  ]
end

def expect_truthy func
  func[true, false]
end

def expect_falsy func
  func[false, true]
end

def expect_valid result
  result[true, false, false]
end

def expect_invalid result
  result[false, true, false]
end

def expect_en_passant result
  result[false, false, true]
end

INDEX_ARRAY = [0,  1,  2,  3,  4,  5,  6,  7,
               8,  9,  10, 11, 12, 13, 14, 15,
               16, 17, 18, 19, 20, 21, 22, 23,
               24, 25, 26, 27, 28, 29, 30, 31,
               32, 33, 34, 35, 36, 37, 38, 39,
               40, 41, 42, 43, 44, 45, 46, 47,
               48, 49, 50, 51, 52, 53, 54, 55,
               56, 57, 58, 59, 60, 61, 62, 63]

INDEX_BOARD = [[0,  1,  2,  3,  4,  5,  6,  7],
               [8,  9,  10, 11, 12, 13, 14, 15],
               [16, 17, 18, 19, 20, 21, 22, 23],
               [24, 25, 26, 27, 28, 29, 30, 31],
               [32, 33, 34, 35, 36, 37, 38, 39],
               [40, 41, 42, 43, 44, 45, 46, 47],
               [48, 49, 50, 51, 52, 53, 54, 55],
               [56, 57, 58, 59, 60, 61, 62, 63]]

 BP = BLACK_PAWN
 BR = BLACK_ROOK
 BN = BLACK_KNIGHT
 BB = BLACK_BISHOP
 BQ = BLACK_QUEEN
 BK = BLACK_KING
MBP = TO_MOVED_PIECE[BLACK_PAWN]
MBR = TO_MOVED_PIECE[BLACK_ROOK]
MBN = TO_MOVED_PIECE[BLACK_KNIGHT]
MBB = TO_MOVED_PIECE[BLACK_BISHOP]
MBQ = TO_MOVED_PIECE[BLACK_QUEEN]
MBK = TO_MOVED_PIECE[BLACK_KING]

 WP = WHITE_PAWN
 WR = WHITE_ROOK
 WN = WHITE_KNIGHT
 WB = WHITE_BISHOP
 WQ = WHITE_QUEEN
 WK = WHITE_KING
MWP = TO_MOVED_PIECE[WHITE_PAWN]
MWR = TO_MOVED_PIECE[WHITE_ROOK]
MWN = TO_MOVED_PIECE[WHITE_KNIGHT]
MWB = TO_MOVED_PIECE[WHITE_BISHOP]
MWQ = TO_MOVED_PIECE[WHITE_QUEEN]
MWK = TO_MOVED_PIECE[WHITE_KING]
