# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

require_relative './setup'

group 'Play' do
  def same_board board_a, board_b
    board_a.board_to_a == board_b.board_to_a
  end

  def safe_position_to_a object
    object.is_a?(Array) ? object : object.position_to_a
  end

  def same_position position_a, position_b
    safe_position_to_a(position_a) == safe_position_to_a(position_b)
  end

  def return_type type
    proc { |new_state| { state: new_state, type: type } }
  end

  def make_state board, move, last_move = [[0, 0], [0, 0]], promotion: WHITE_QUEEN
    CREATE_STATE[
      position(*move.first),
      position(*move.last),
      position(*last_move.first),
      position(*last_move.last),
      board,
      ZERO,
      promotion
    ]
  end

  def perform_move board, from, to
    NORMAL_MOVE[board, position(*from), position(*to), nil]
  end

  def black_response board, from, to, seed: 1
    GET_BOARD[
      RIGHT[
        BLACK_AI[
          make_state(
            perform_move(board, from, to),
            [from, to],
            [from, to]
          ),
          seed.to_peano
        ]
      ]
    ]
  end

  def perform_play type, state, seed
    PLAY[
      state,
      return_type(:accept),
      return_type(:reject),
      return_type(:loss),
      return_type(:forfit),
      seed.to_peano
    ].tap { |result|
      assert "#{type} proc is called" do
        result[:type] == type
      end
    }[:state]
  end

  def expect_accept initial_state, result_board, seed: 1
    result = perform_play(:accept, initial_state, seed)

    assert 'board updated correctly' do
      same_board(result_board, GET_BOARD[result])
    end

    assert '"last_from" is set to "from"' do
      same_position(GET_FROM[initial_state], GET_LAST_FROM[result])
    end

    assert '"last_to" is set to "to"' do
      same_position(GET_TO[initial_state], GET_LAST_TO[result])
    end
  end

  def expect_reject initial_state, seed: 1
    result = perform_play(:reject, initial_state, seed)

    assert 'board is unchanged' do
      same_board(GET_BOARD[initial_state], GET_BOARD[result])
    end

    assert '"last_from" is unchanged' do
      same_position(GET_LAST_FROM[initial_state], GET_LAST_FROM[result])
    end

    assert '"last_to" is unchanged' do
      same_position(GET_LAST_TO[initial_state], GET_LAST_TO[result])
    end
  end

  def expect_end type, initial_state, result_board, seed: 1
    result = perform_play(type, initial_state, seed)

    assert 'board is updated' do
      same_board(result_board, GET_BOARD[result])
    end
  end

  group 'moving an empty space' do
    expect_reject make_state(INITIAL_BOARD, [[0, 3], [1, 4]])
  end

  group 'moving a black piece' do
    expect_reject make_state(INITIAL_BOARD, [[1, 1], [1, 2]])
  end

  group 'capturing self' do
    expect_reject make_state(INITIAL_BOARD, [[2, 6], [2, 6]])
  end

  group 'valid move' do
    from = [2, 6]
    to   = [2, 5]

    expect_accept(
      make_state(INITIAL_BOARD, [from, to]),
      black_response(INITIAL_BOARD, from, to)
    )
  end

  group 'both can castle' do
    from = [4, 7]
    to   = [6, 7]

    board = [[BR,0, 0, 0, BK,0, 0, BR],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [BP,BP,BP,BP,BP,BP,BP,BP],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [WR,0, 0, 0, WK,0, 0, WR]]
            .to_board

    result = [[BR,0, 0, 0, 0, BR,BK,0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [BP,BP,BP,BP,BP,BP,BP,BP],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [WR,0, 0, 0, 0, WR,WK,0]]
             .to_board

    expect_accept make_state(board, [from, to]), result, seed: 8
  end

  group 'causing checkmate' do
    from  = [5, 3]
    to    = [6, 3]
    board = [[0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, WR,0, 0],
             [0, 0, 0, 0, 0, WN,0, 0],
             [0, 0, 0, 0, 0, 0, 0, 0],
             [WR,0, 0, 0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0, 0, 0, BK]]
            .to_board

    expect_end(
      :forfit,
      make_state(board, [from, to]),
      perform_move(board, from, to)
    )
  end

  group 'being forced into checkmate' do
    from       = [5, 7]
    to         = [6, 7]
    black_from = [5, 5]
    black_to   = [6, 5]
    board      = [[0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, BP,BR],
                  [0, 0, 0, 0, 0, BR,0, 0],
                  [0, 0, 0, 0, BN,BR,0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, WK,0, 0]]
                 .to_board

    expect_end(
      :loss,
      make_state(board, [from, to]),
      perform_move(
        perform_move(board, from, to),
        black_from,
        black_to
      )
    )
  end

  group 'white en passant' do
    from      = [4, 3]
    to        = [3, 2]
    last_from = [3, 1]
    last_to   = [3, 3]
    board     = [[0, 0, 0, 0,  0,  0, 0, 0],
                 [0, 0, 0, 0,  0,  0, 0, 0],
                 [0, 0, 0, 0,  0,  0, 0, 0],
                 [0, 0, 0, MBP,MWP,0, 0, 0],
                 [0, 0, 0, 0,  0,  0, 0, 0],
                 [0, 0, 0, 0,  0,  0, 0, 0],
                 [0, 0, 0, 0,  0,  0, BK,0],
                 [0, WK,0, 0,  0,  0, 0, 0]]
                .to_board

    result = [[0, 0, 0, 0,  0, 0, 0, 0],
              [0, 0, 0, 0,  0, 0, 0, 0],
              [0, 0, 0, MWP,0, 0, 0, 0],
              [0, 0, 0, 0,  0, 0, 0, 0],
              [0, 0, 0, 0,  0, 0, 0, 0],
              [0, 0, 0, 0,  0, 0, BK,0],
              [0, 0, 0, 0,  0, 0, 0, 0],
              [0, WK,0, 0,  0, 0, 0, 0]]
             .to_board

    expect_accept make_state(board, [from, to], [last_from, last_to]), result
  end

  group 'black en passant' do
    from      = [3, 6]
    to        = [3, 4]
    board     = [[0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, 0, BP,0, 0, 0],
                 [0, 0, 0, 0, 0, 0, 0, 0],
                 [0, 0, 0, WP,0, 0, WK,0],
                 [0, BK,0, 0, 0, 0, 0, 0]]
                .to_board

    result = [[0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, 0, 0],
              [0, 0, 0, BP,0, 0, 0, 0],
              [0, 0, 0, 0, 0, 0, WK,0],
              [0, BK,0, 0, 0, 0, 0, 0]]
             .to_board

    expect_accept make_state(board, [from, to]), result
  end
end
