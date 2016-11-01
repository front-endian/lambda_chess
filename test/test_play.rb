# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'Play Functions' do
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

  group 'BLACK_AI' do
    assert 'flags when no moves are valid' do
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, BR,0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, WQ,0, WR],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, WR,0, BK]]
              .to_board

      expect_falsy LEFT[BLACK_AI[board, NULL_POS, NULL_POS, 1.to_peano]]
    end

    group 'give multiple valid moves' do
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, BR,0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, WQ,0, 0],
               [0, 0, 0, 0, 0, 0, WR,0],
               [0, 0, 0, 0, 0, 0, 0, BK]]
              .to_board

      result_1 = BLACK_AI[board, NULL_POS, NULL_POS, 1.to_peano]
      result_2 = BLACK_AI[board, NULL_POS, NULL_POS, 2.to_peano]


      assert 'flags when moves are valid' do
        expect_truthy LEFT[result_1]
      end

      assert 'only moves a valid piece' do
        expect_truthy SAME_POSITION[GET_FROM[RIGHT[result_1]], position(2, 3)]
      end

      assert 'finds multiple moves' do
        expect_falsy SAME_POSITION[GET_TO[RIGHT[result_1]], GET_TO[RIGHT[result_2]]]
      end
    end

    assert 'selects "to" based on "random" parameter' do
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, WQ,0, 0],
               [0, 0, 0, 0, 0, 0, WR,0],
               [BN,0, 0, 0, 0, 0, 0, BK]]
              .to_board

      result_1 = BLACK_AI[board, NULL_POS, NULL_POS, 1.to_peano]
      result_2 = BLACK_AI[board, NULL_POS, NULL_POS, 2.to_peano]

      possible_tos = [GET_TO[RIGHT[result_1]], GET_TO[RIGHT[result_2]]]

      expect_truthy(SAME_POSITION[GET_FROM[RIGHT[result_1]], position(0, 7)]) &&
      expect_truthy(SAME_POSITION[GET_FROM[RIGHT[result_2]], position(0, 7)]) &&
      possible_tos.any? { |pos| expect_truthy SAME_POSITION[pos, position(1, 5)] } &&
      possible_tos.any? { |pos| expect_truthy SAME_POSITION[pos, position(2, 6)] }
    end

    assert 'moves king out of check when needed' do
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, BN,0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, WR,0],
               [0, 0, 0, 0, 0, 0, 0 ,0],
               [0, 0, 0, 0, 0, WR,0, BK]]
              .to_board

      result_1 = RIGHT[BLACK_AI[board, NULL_POS, NULL_POS, 1.to_peano]]
      result_2 = RIGHT[BLACK_AI[board, NULL_POS, NULL_POS, 2.to_peano]]

      expect_truthy(SAME_POSITION[GET_TO[result_1], position(7, 6)]) &&
      expect_truthy(SAME_POSITION[GET_TO[result_2], position(7, 6)])
    end

    assert 'finds the best move' do
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, BP,0, 0],
               [0, 0, BN,0, 0, 0, 0, 0],
               [0, 0, 0, 0, BP,0, 0, 0],
               [0, 0, 0, WP,0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, WQ,0],
               [0, 0, 0, 0, 0, 0, WN,BK]]
              .to_board

      result_1 = RIGHT[BLACK_AI[board, NULL_POS, NULL_POS, 1.to_peano]]
      result_2 = RIGHT[BLACK_AI[board, NULL_POS, NULL_POS, 2.to_peano]]

      expect_truthy(SAME_POSITION[GET_TO[result_1], position(6, 6)]) &&
      expect_truthy(SAME_POSITION[GET_TO[result_2], position(6, 6)])
    end
  end
end
