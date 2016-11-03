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
              ->(response_state) {
                IF[LEFT[response]][
                  -> {
                    IF[IS_WHITE_CHECKMATE[response_state]][
                      -> { loss[response_state] },
                      -> { accept[response_state] }
                    ]
                  },
                  -> { forfit[response_state] }
                ]
              }[
                # "response_state"
                UPDATE_LAST_FROM_TO[RIGHT[response], state]
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

IS_WHITE_CHECKMATE = ->(_) { SECOND }
