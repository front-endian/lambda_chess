# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require './test_setup'
require './../data'
require './../pieces'
require './../board'
require './../play'
require 'tet'

def test_castling_to_one_side original_board:,
                              works:,
                              row:,
                              king:,
                              rook:,
                              king_to_column:,
                              rook_to_column:

  null_pos  = PAIR[ZERO, ZERO]
  king_from = PAIR[FOUR, row]
  king_to   = PAIR[king_to_column, row]
  rook_from = PAIR[rook_to_column == THREE ? ZERO : SEVEN, row]
  rook_to   = PAIR[rook_to_column, row]
  result    = PERFORM_CASTLING[original_board, king_from, king_to, null_pos, null_pos]

  if works
    assert "king was moved" do
     piece_in_position = TO_MOVED_PIECE[king].to_i ==
                         GET_POSITION[result, king_to].to_i

     piece_in_position == works
    end

    assert "rook was moved" do
      piece_in_position = TO_MOVED_PIECE[rook].to_i ==
                          GET_POSITION[result, rook_to].to_i

      piece_in_position == works
    end

    assert "correct rook was moved" do
      piece_in_position = 0 == GET_POSITION[result, rook_from].to_i

      piece_in_position == works
    end
  else
    assert "board remains the same" do
     result == original_board
    end
  end
end

def test_castling board, works
  null_pos = PAIR[ZERO, ZERO]

  group 'with a white king' do
    group 'castling to the left' do
      test_castling_to_one_side original_board: board,
                                works:          works,
                                row:            WHITE_HOME_ROW,
                                king:           WHITE_KING,
                                rook:           WHITE_ROOK,
                                king_to_column: TWO,
                                rook_to_column: THREE
    end

    group 'castling to the right' do
      test_castling_to_one_side original_board: board,
                                works:          works,
                                row:            WHITE_HOME_ROW,
                                king:           WHITE_KING,
                                rook:           WHITE_ROOK,
                                king_to_column: SIX,
                                rook_to_column: FIVE
    end
  end

  group 'with a black king' do
    group 'can castle to the left' do
      test_castling_to_one_side original_board: board,
                                works:          works,
                                row:            BLACK_HOME_ROW,
                                king:           BLACK_KING,
                                rook:           BLACK_ROOK,
                                king_to_column: TWO,
                                rook_to_column: THREE
    end

    group 'can castle to the right' do
      test_castling_to_one_side original_board: board,
                                works:          works,
                                row:            BLACK_HOME_ROW,
                                king:           BLACK_KING,
                                rook:           BLACK_ROOK,
                                king_to_column: SIX,
                                rook_to_column: FIVE
    end
  end
end

group 'Play Functions' do
  group 'PERFORM_CASTLING' do
    bk = BLACK_KING.to_i
    br = BLACK_ROOK.to_i
    bp = BLACK_PAWN.to_i

    wk = WHITE_KING.to_i
    wr = WHITE_ROOK.to_i
    wp = WHITE_PAWN.to_i

    group 'path is free' do
      board = [br,0, 0, 0, bk,0, 0, br,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               wr,0, 0, 0, wk,0, 0, wr]
              .map(&:to_peano)
              .to_linked_list

      test_castling board, true
    end

    group 'path is blocked' do
      board = [br,0, bp,0, bk,0, bp,br,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0,
               wr,0, wp,0, wk,0, wp,wr]
              .map(&:to_peano)
              .to_linked_list

      test_castling board, false
    end

    group 'king has moved' do
      mbk = TO_MOVED_PIECE[BLACK_KING].to_i
      mwk = TO_MOVED_PIECE[WHITE_KING].to_i

      board = [br,0, 0, 0, mbk,0, 0, br,
               0, 0, 0, 0, 0,  0, 0, 0,
               0, 0, 0, 0, 0,  0, 0, 0,
               0, 0, 0, 0, 0,  0, 0, 0,
               0, 0, 0, 0, 0,  0, 0, 0,
               0, 0, 0, 0, 0,  0, 0, 0,
               0, 0, 0, 0, 0,  0, 0, 0,
               wr,0, 0, 0, mwk,0, 0, wr]
              .map(&:to_peano)
              .to_linked_list

      test_castling board, false
    end

    group 'rook has moved' do
      mbr = TO_MOVED_PIECE[BLACK_ROOK].to_i
      mwr = TO_MOVED_PIECE[WHITE_ROOK].to_i

      board = [mbr,0, 0, 0, bk,0, 0, mbr,
               0,  0, 0, 0, 0, 0, 0, 0,
               0,  0, 0, 0, 0, 0, 0, 0,
               0,  0, 0, 0, 0, 0, 0, 0,
               0,  0, 0, 0, 0, 0, 0, 0,
               0,  0, 0, 0, 0, 0, 0, 0,
               0,  0, 0, 0, 0, 0, 0, 0,
               mwr,0, 0, 0, wk,0, 0, mwr]
              .map(&:to_peano)
              .to_linked_list

      test_castling board, false
    end
  end
end
