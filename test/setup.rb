# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require 'tet'
require_relative './../data'
require_relative './../board'
require_relative './../pieces'
require_relative './../ai'
require_relative './../play'

class Proc
  def to_i
    call proc { |x| x + 1 }, 0
  end

  def list_to_a length
    result = []
    part   = self

    length.times do
      result.push(LEFT[part])
      part = RIGHT[part]
    end

    result
  end

  def vector_to_a
    VECTOR_LIST[self].list_to_a(VECTOR_SIZE[self].to_i)
  end

  def board_to_a
    self.list_to_a(8)
        .map { |row|
          row.list_to_a(8).map { |piece|
            GET_VALUE[piece].to_i + IS_BLACK[piece][KING_VALUE.to_i, 0]
          }
        }.flatten
  end

  def position_to_a
    [LEFT[self].to_i, RIGHT[self].to_i]
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

  def to_vector
    reverse.inject(EMPTY_VECTOR) do |previous, element|
      VECTOR_APPEND[previous, element]
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

def test_castling_to_one_side board:,
                              home_row:,
                              king:,
                              rook:,
                              king_to_column:,
                              rook_to_column:,
                              perform:,
                              expect:

  king_from     = PAIR[FOUR, home_row]
  king_to       = PAIR[king_to_column, home_row]
  rook_from     = PAIR[
                    (rook_to_column == THREE) ? ZERO : SEVEN,
                    home_row
                  ]
  rook_to       = PAIR[rook_to_column, home_row]
  result        = perform.call(board, king_from, king_to)

  expect.call(result, king_to, rook_to, rook_from)
end

def test_castling black_board, white_board, perform:, expect:
  null_pos = PAIR[ZERO, ZERO]

  group 'with a white king' do
    assert 'castling to the left' do
      test_castling_to_one_side board:          white_board,
                                home_row:       SEVEN,
                                king:           WHITE_KING,
                                rook:           WHITE_ROOK,
                                king_to_column: TWO,
                                rook_to_column: THREE,
                                perform:        perform,
                                expect:         expect
    end

    assert 'castling to the right' do
      test_castling_to_one_side board:          white_board,
                                home_row:       SEVEN,
                                king:           WHITE_KING,
                                rook:           WHITE_ROOK,
                                king_to_column: SIX,
                                rook_to_column: FIVE,
                                perform:        perform,
                                expect:         expect
    end
  end

  group 'with a black king' do
    assert 'can castle to the left' do
      test_castling_to_one_side board:          black_board,
                                home_row:       ZERO,
                                king:           BLACK_KING,
                                rook:           BLACK_ROOK,
                                king_to_column: TWO,
                                rook_to_column: THREE,
                                perform:        perform,
                                expect:         expect
    end

    assert 'can castle to the right' do
      test_castling_to_one_side board:          black_board,
                                home_row:       ZERO,
                                king:           BLACK_KING,
                                rook:           BLACK_ROOK,
                                king_to_column: SIX,
                                rook_to_column: FIVE,
                                perform:        perform,
                                expect:         expect
    end
  end
end

def expect_truthy func
  func[true, false]
end

def expect_falsy func
  func[false, true]
end

def expect_valid result
  result[true, false, false, false, false]
end

def expect_invalid result
  result[false, true, false, false, false]
end

def expect_en_passant result
  result[false, false, true, false, false]
end

def expect_castle result
  result[false, false, false, true, false]
end

NULL_POS = PAIR[ZERO, ZERO]

INDEX_ARRAY = [0,  1,  2,  3,  4,  5,  6,  7,
               8,  9,  10, 11, 12, 13, 14, 15,
               16, 17, 18, 19, 20, 21, 22, 23,
               24, 25, 26, 27, 28, 29, 30, 31,
               32, 33, 34, 35, 36, 37, 38, 39,
               40, 41, 42, 43, 44, 45, 46, 47,
               48, 49, 50, 51, 52, 53, 54, 55,
               56, 57, 58, 59, 60, 61, 62, 63]

 BP = BLACK_PAWN
 BR = BLACK_ROOK
 BN = BLACK_KNIGHT
 BB = BLACK_BISHOP
 BQ = BLACK_QUEEN
 BK = BLACK_KING
MBP = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}[BLACK_PAWN]
MBR = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}[BLACK_ROOK]
MBN = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}[BLACK_KNIGHT]
MBB = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}[BLACK_BISHOP]
MBQ = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}[BLACK_QUEEN]
MBK = ->(piece) {
  MAKE_PIECE[GET_COLOR[piece], GET_VALUE[piece], GET_OCCUPIED[piece], MOVED]
}[BLACK_KING]

 WP = WHITE_PAWN
 WR = WHITE_ROOK
 WN = WHITE_KNIGHT
 WB = WHITE_BISHOP
 WQ = WHITE_QUEEN
 WK = WHITE_KING
MWP = MAKE_PIECE[GET_COLOR[WHITE_PAWN], GET_VALUE[WHITE_PAWN], GET_OCCUPIED[WHITE_PAWN], MOVED]
MWR = MAKE_PIECE[GET_COLOR[WHITE_ROOK], GET_VALUE[WHITE_ROOK], GET_OCCUPIED[WHITE_ROOK], MOVED]
MWN = MAKE_PIECE[GET_COLOR[WHITE_KNIGHT], GET_VALUE[WHITE_KNIGHT], GET_OCCUPIED[WHITE_KNIGHT], MOVED]
MWB = MAKE_PIECE[GET_COLOR[WHITE_BISHOP], GET_VALUE[WHITE_BISHOP], GET_OCCUPIED[WHITE_BISHOP], MOVED]
MWQ = MAKE_PIECE[GET_COLOR[WHITE_QUEEN], GET_VALUE[WHITE_QUEEN], GET_OCCUPIED[WHITE_QUEEN], MOVED]
MWK = MAKE_PIECE[GET_COLOR[WHITE_KING], GET_VALUE[WHITE_KING], GET_OCCUPIED[WHITE_KING], MOVED]
