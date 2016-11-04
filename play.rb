# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

PLAY = ->(state, accept, reject, loss, forfit) {
  IF[IS_BLACK[GET_POSITION[GET_BOARD[state], GET_FROM[state]]]][
    -> { reject[state] },
    -> {
      ->(move_type) {
        ADVANCE_STATE[state][
          ->(new_state) {
            ->(response) {
              IF[LEFT[response]][
                -> {
                  ->(response_state) {
                    IF[ISNT_WHITE_CHECKMATE[response_state]][
                      -> { accept[response_state] },
                      -> { loss[response_state] }
                    ]
                  }[
                    # "response_state"
                    UPDATE_LAST_FROM_TO[RIGHT[response], state]
                  ]
                },
                -> { forfit[new_state] }
              ]
            }[
              # "response"
              BLACK_AI[new_state]
            ]
          },
          -> { reject[state] }
        ]
      }[
        # "move_type"
        -> {
          GET_RULE[GET_POSITION[board, from]][board, from, to, from, to]
        }
      ]
    }
  ]
}

ISNT_WHITE_CHECKMATE = ->(board) {
  ->(king_position_vector) {
    ->(king_position) {
      FROM_TO_REDUCE[
        king_position_vector,
        BOARD_REDUCE[
          board,
          ->(memo, piece, position) {
            AND[
              NOT[IS_GREATER_OR_EQUAL[
                TWO,
                DELTA[position, king_position, RIGHT]
              ]],
              NOT[IS_GREATER_OR_EQUAL[
                TWO,
                DELTA[position, king_position, LEFT]
              ]]
            ][
              VECTOR_APPEND[memo, position],
              memo
            ]
          },
          EMPTY_VECTOR
        ],
        ->(memo, from, to) {
          IF[memo][
            -> { FIRST },
            -> {
              ISNT_INVALID[
                KING_RULE[
                  CREATE_STATE[from, to, from, to, board, ZERO, WHITE_QUEEN, ZERO]
                ]
              ]
            }
          ]
        },
        SECOND
      ]
    }[
      # "king_position"
      VECTOR_FIRST[king_position_vector]
    ]
  }[
    # "king_position_vector"
    POSITION_SELECT[
      board,
      ->(piece) {
        AND[
          IS_WHITE[piece],
          IS_EQUAL[KING_VALUE, GET_VALUE[piece]]
        ]
      }
    ]
  ]
}
