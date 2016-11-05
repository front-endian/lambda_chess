# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'AI Functions' do
  group 'BLACK_AI' do
    def run_black_ai board, seed
      BLACK_AI[
        CREATE_STATE[
          NULL_POS,
          NULL_POS,
          NULL_POS,
          NULL_POS,
          board,
          0.to_peano,
          0.to_peano
        ],
        seed.to_peano
      ]
    end

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

      expect_falsy LEFT[run_black_ai(board, 1)]
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

      result_1 = run_black_ai(board, 1)
      result_2 = run_black_ai(board, 2)


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

    assert 'selects "to" based on "seed" parameter' do
      board = [[0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, WQ,0, 0],
               [0, 0, 0, 0, 0, 0, WR,0],
               [BN,0, 0, 0, 0, 0, 0, BK]]
              .to_board

      result_1 = run_black_ai(board, 1)
      result_2 = run_black_ai(board, 2)

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

      result_1 = RIGHT[run_black_ai(board, 1)]
      result_2 = RIGHT[run_black_ai(board, 2)]

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

      result_1 = RIGHT[run_black_ai(board, 1)]
      result_2 = RIGHT[run_black_ai(board, 2)]

      expect_truthy(SAME_POSITION[GET_TO[result_1], position(6, 6)]) &&
      expect_truthy(SAME_POSITION[GET_TO[result_2], position(6, 6)])
    end

    assert 'prefers putting white into check' do
      board = [[WK,0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, BP,0, 0, 0, 0, 0, 0],
               [0, BR,0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0],
               [0, 0, 0, 0, 0, 0, 0, 0]]
              .to_board

      result = RIGHT[run_black_ai(board, 1)]

      expect_truthy SAME_POSITION[GET_TO[result], position(0, 5)]
    end
  end
end
