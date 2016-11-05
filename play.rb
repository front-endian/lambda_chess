# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

PLAY = ->(state, accept, reject, loss, forfit, seed) {
  IF[IS_BLACK[GET_POSITION[GET_BOARD[state], GET_FROM[state]]]][
    -> { reject[state] },
    -> {
      ADVANCE_STATE[state][
        ->(new_state) {
          ->(response) {
            IF[LEFT[response]][
              -> {
                ->(response_state) {
                  IF[ISNT_WHITE_CHECKMATE[GET_BOARD[response_state]]][
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
            BLACK_AI[new_state, seed]
          ]
        },
        -> { reject[state] }
      ]
    }
  ]
}

ISNT_WHITE_CHECKMATE = ->(board) {
  ->(king_position_vector) {
    ->(king_position) {
      IF[
        FROM_TO_REDUCE[
          king_position_vector,
          POSITION_SELECT[board, ALWAYS_FIRST],
          ->(memo, from, to) {
            IF[memo][
              -> { FIRST },
              -> {
                ISNT_INVALID[
                  KING_RULE[GET_RULE][
                    CREATE_STATE[from, to, from, to, board, ZERO, WHITE_QUEEN]
                  ]
                ]
              }
            ]
          },
          SECOND
        ]
      ][
        # King can move
        -> { FIRST },
        # King can't move
        -> {
          IS_NOT_IN_CHECK[board, king_position, GET_RULE]
        }
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
