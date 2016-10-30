# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'Play Functions' do
  group 'PERFORM_CASTLING' do
    board = [[BR,0, 0, 0, BK,0, 0, BR],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [WR,0, 0, 0, WK,0, 0, WR]]
            .to_board

    test_castling board, board,
      perform: proc { |board, from, to| PERFORM_CASTLING[board, from, to] },
      expect:  proc { |result, king_to, rook_to, rook_from|
        assert "king was moved" do
         piece_in_position = KING_VALUE == GET_VALUE[GET_POSITION[result, king_to]]

         piece_in_position
        end

        assert "rook was moved" do
          piece_in_position = ROOK_VALUE == GET_VALUE[GET_POSITION[result, rook_to]]

          piece_in_position
        end

        assert "correct rook was moved" do
          piece_in_position = EMPTY_SPACE == GET_POSITION[result, rook_from]

          piece_in_position
        end
      }
  end

  group 'MAX_PIECE_TOTAL' do
    assert 'has the correct value' do
      MAX_PIECE_TOTAL.to_i == (GET_VALUE[BP].to_i * 8) +
                              (GET_VALUE[BN].to_i * 2) +
                              (GET_VALUE[BB].to_i * 2) +
                              (GET_VALUE[BR].to_i * 2) +
                               GET_VALUE[BQ].to_i +
                               GET_VALUE[BK].to_i
     end
  end

  group 'SCORE' do
    group 'INITIAL_BOARD has MAX_PIECE_TOTAL' do
      assert 'for black' do
        MAX_PIECE_TOTAL.to_i == SCORE[INITIAL_BOARD, BLACK].to_i
      end

      assert 'for white' do
        MAX_PIECE_TOTAL.to_i == SCORE[INITIAL_BOARD, WHITE].to_i
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
        expected =  MAX_PIECE_TOTAL.to_i - GET_VALUE[BB].to_i
        expected == SCORE[board, BLACK].to_i
      end

      assert 'the score for white goes up by that amount' do
        expected =  MAX_PIECE_TOTAL.to_i + GET_VALUE[BB].to_i
        expected == SCORE[board, WHITE].to_i
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
        expected =  MAX_PIECE_TOTAL.to_i + GET_VALUE[BQ].to_i
        expected == SCORE[board, BLACK].to_i
      end

      assert 'the score for white goes down by the black equivolent' do
        expected =  MAX_PIECE_TOTAL.to_i - GET_VALUE[BQ].to_i
        expected == SCORE[board, WHITE].to_i
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

      SCORE[one_left, BLACK].to_i > SCORE[none_left, BLACK].to_i
    end
  end
end
