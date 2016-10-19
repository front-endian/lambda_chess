# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

def test_castling_to_one_side original_board:,
                              works:,
                              home_row:,
                              king:,
                              rook:,
                              king_to_column:,
                              rook_to_column:

  null_position = PAIR[ZERO, ZERO]
  king_from     = PAIR[FOUR, home_row]
  king_to       = PAIR[king_to_column, home_row]
  rook_from     = PAIR[
                    (rook_to_column == THREE) ? ZERO : SEVEN,
                    home_row
                  ]
  rook_to       = PAIR[rook_to_column, home_row]
  result        = PERFORM_CASTLING[
                    original_board,
                    king_from,
                    king_to,
                    null_position,
                    null_position
                  ]

  if works
    assert "king was moved" do
     piece_in_position = KING == GET_VALUE[GET_POSITION[result, king_to]]

     piece_in_position == works
    end

    assert "rook was moved" do
      piece_in_position = ROOK == GET_VALUE[GET_POSITION[result, rook_to]]

      piece_in_position == works
    end

    assert "correct rook was moved" do
      piece_in_position = EMPTY_SPACE == GET_POSITION[result, rook_from]

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
                                home_row:       WHITE_HOME_ROW,
                                king:           WHITE_KING,
                                rook:           WHITE_ROOK,
                                king_to_column: TWO,
                                rook_to_column: THREE
    end

    group 'castling to the right' do
      test_castling_to_one_side original_board: board,
                                works:          works,
                                home_row:       WHITE_HOME_ROW,
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
                                home_row:       BLACK_HOME_ROW,
                                king:           BLACK_KING,
                                rook:           BLACK_ROOK,
                                king_to_column: TWO,
                                rook_to_column: THREE
    end

    group 'can castle to the right' do
      test_castling_to_one_side original_board: board,
                                works:          works,
                                home_row:       BLACK_HOME_ROW,
                                king:           BLACK_KING,
                                rook:           BLACK_ROOK,
                                king_to_column: SIX,
                                rook_to_column: FIVE
    end
  end
end

group 'Play Functions' do
  group 'PERFORM_CASTLING' do
    group 'path is free' do
      board = [[BR,0, 0, 0, BK,0, 0, BR],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [WR,0, 0, 0, WK,0, 0, WR]]
              .to_board

      test_castling board, true
    end

    group 'path is blocked' do
      board = [[BR,0, BP,0, BK,0, BP,BR],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [WR,0, WP,0, WK,0, WP,WR]]
              .to_board

      test_castling board, false
    end

    group 'king has moved' do
      board = [[BR,0, 0, 0, MBK,0, 0, BR],
               [0, 0, 0, 0, 0,  0, 0, 0],
               [0, 0, 0, 0, 0,  0, 0, 0],
               [0, 0, 0, 0, 0,  0, 0, 0],
               [0, 0, 0, 0, 0,  0, 0, 0],
               [0, 0, 0, 0, 0,  0, 0, 0],
               [0, 0, 0, 0, 0,  0, 0, 0],
               [WR,0, 0, 0, MWK,0, 0, WR]]
              .to_board

      test_castling board, false
    end

    group 'rook has moved' do
      board = [[MBR,0, 0, 0, BK,0, 0, MBR],
               [0,  0, 0, 0, 0, 0, 0, 0],
               [0,  0, 0, 0, 0, 0, 0, 0],
               [0,  0, 0, 0, 0, 0, 0, 0],
               [0,  0, 0, 0, 0, 0, 0, 0],
               [0,  0, 0, 0, 0, 0, 0, 0],
               [0,  0, 0, 0, 0, 0, 0, 0],
               [MWR,0, 0, 0, WK,0, 0, MWR]]
              .to_board

      test_castling board, false
    end

    group 'when king is in check' do
      board = [[BR,0, 0, 0, BK,0, 0, BR],
               [0, 0, 0, 0, WR,0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, BR,0, 0, 0],
               [WR,0, 0, 0, WK,0, 0, WR]]
              .to_board

      test_castling board, false
    end

    group 'when king is moving into check' do
      board = [[BR,0, 0, 0, BK,0, 0, BR],
               [0, 0, WR,0, 0, 0, WR,0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, BR,0, 0, 0, BR,0],
               [WR,0, 0, 0, WK,0, 0, WR]]
              .to_board

      test_castling board, false
    end

    group 'when king is moving past check' do
      board = [[BR,0, 0, 0, BK,0, 0, BR],
               [0, 0, 0, WR,0, WR,0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, BR,0, BR,0, 0],
               [WR,0, 0, 0, WK,0, 0, WR]]
              .to_board

      test_castling board, false
    end
  end

  group 'MAX_UNMOVED_SCORE' do
    assert 'has the correct value' do
      MAX_UNMOVED_SCORE.to_i == (GET_VALUE[BP].to_i * 8) +
                                (GET_VALUE[BN].to_i * 2) +
                                (GET_VALUE[BB].to_i * 2) +
                                (GET_VALUE[BR].to_i * 2) +
                                 GET_VALUE[BQ].to_i +
                                 GET_VALUE[BK].to_i
     end
  end

  group 'SCORE' do
    group 'INITIAL_BOARD has MAX_UNMOVED_SCORE' do
      assert 'for black' do
        MAX_UNMOVED_SCORE.to_i == SCORE[INITIAL_BOARD, FOR_BLACK].to_i
      end

      assert 'for white' do
        MAX_UNMOVED_SCORE.to_i == SCORE[INITIAL_BOARD, FOR_WHITE].to_i
      end
    end

    group 'if a black piece is taken' do
      board = [[BR,BN,0, BQ,BK,BB,BN,BR],
               [BP,BP,BP,BP,BP,BP,BP,BP],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [WP,WP,WP,WP,WP,WP,WP,WP],
               [WR,WN,WB,WQ,WK,WB,WN,WR]]
              .to_board

      assert 'the score for black goes down by that amount' do
        expected =  MAX_UNMOVED_SCORE.to_i - GET_VALUE[BB].to_i
        expected == SCORE[board, FOR_BLACK].to_i
      end

      assert 'the score for white goes up by that amount' do
        expected =  MAX_UNMOVED_SCORE.to_i + GET_VALUE[BB].to_i
        expected == SCORE[board, FOR_WHITE].to_i
      end
    end

    group 'if a white piece is taken' do
      board = [[BR,BN,BB,BQ,BK,BB,BN,BR],
               [BP,BP,BP,BP,BP,BP,BP,BP],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [WP,WP,WP,WP,WP,WP,WP,WP],
               [WR,WN,WB,0, WK,WB,WN,WR]]
              .to_board

      assert 'the score for black goes up by the black equivolent' do
        expected =  MAX_UNMOVED_SCORE.to_i + GET_VALUE[BQ].to_i
        expected == SCORE[board, FOR_BLACK].to_i
      end

      assert 'the score for white goes down by the black equivolent' do
        expected =  MAX_UNMOVED_SCORE.to_i - GET_VALUE[BQ].to_i
        expected == SCORE[board, FOR_WHITE].to_i
      end
    end

    assert 'does not bottom out' do
      one_left = [[0, 0, 0, 0, 0, 0, 0, 0],
                  [BP,0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [WP,WP,WP,WP,WP,WP,WP,WP],
                  [WR,WN,WB,WQ,WK,WB,WN,WR]]
                 .to_board

      none_left = [[0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [0, 0, 0, 0, 0, 0, 0, 0],
                   [WP,WP,WP,WP,WP,WP,WP,WP],
                   [WR,WN,WB,WQ,WK,WB,WN,WR]]
                  .to_board

      SCORE[one_left, FOR_BLACK].to_i > SCORE[none_left, FOR_BLACK].to_i
    end
  end
end
