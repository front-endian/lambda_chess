# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# AI Functions

$FROM_TO_REDUCE = ->(possible_froms, possible_tos, func, initial) {
  $VECTOR_REDUCE[
    possible_froms,
    ->(memo, from_position) {
      $VECTOR_REDUCE[
        possible_tos,
        ->(inner_memo, to_position) {
          func[inner_memo, from_position, to_position]
        },
        memo
      ]
    },
    initial
  ]
}

$POSSIBLE_MOVES = ->(state, color, possible_tos) {
  ->(board) {
    $FROM_TO_REDUCE[
      $POSITION_SELECT[board, color[$IS_BLACK, $IS_WHITE]],
      possible_tos,
      ->(possible_moves, from, to) {
        $ADVANCE_STATE[
          $CREATE_STATE[
            from,
            to,
            $GET_LAST_FROM[state],
            $GET_LAST_TO[state],
            board,
            ZERO,
            color[$BLACK_QUEEN, $WHITE_QUEEN]
          ]
        ][
          ->(new_state) { $VECTOR_APPEND[possible_moves, new_state] },
          -> { possible_moves }
        ]
      },
      $EMPTY_VECTOR
    ]
  }[
    # "board"
    $GET_BOARD[state]
  ]
}

$BLACK_AI = ->(state, seed) {
  ->(result) {
    IF[LEFT[result]][
      -> {
        $ADVANCE_STATE[$UPDATE_ALL_BUT_FROM_TO_PROMOTION[RIGHT[result], state]][
          ->(new_state) { PAIR[FIRST, new_state] },
          -> { PAIR[SECOND, ZERO] }
        ]
      },
      -> { result }
    ]
  }[
    # "result"
    ->(states) {
      IF[IS_ZERO[$VECTOR_SIZE[states]]][
        -> { PAIR[SECOND, ZERO] },
        -> {
          ->(best_vector) {
            PAIR[
              FIRST,
              $NTH[
                $VECTOR_LIST[best_vector],
                $MODULUS[seed, $VECTOR_SIZE[best_vector]]
              ]
            ]
          }[
            # "best_vector"
            $VECTOR_REDUCE[
              states,
              ->(memo, state) {
                IF[IS_ZERO[$VECTOR_SIZE[memo]]][
                  -> { $VECTOR_APPEND[memo, state] },
                  -> {
                    IS_EQUAL[$GET_SCORE[state], $GET_SCORE[$VECTOR_FIRST[memo]]][
                      $VECTOR_APPEND[memo, state],
                      IS_GREATER_OR_EQUAL[
                        $GET_SCORE[state],
                        $GET_SCORE[$VECTOR_FIRST[memo]]
                      ][
                        $VECTOR_APPEND[$EMPTY_VECTOR, state],
                        memo
                      ]
                    ]
                  }
                ]
              },
              $EMPTY_VECTOR
            ]
          ]
        }
      ]
    }[
      $VECTOR_REDUCE[
        $POSSIBLE_MOVES[
          state,
          $BLACK,
          $POSITION_SELECT[
            $GET_BOARD[state],
            ->(piece) { NOT[$IS_BLACK[piece]] }
          ]
        ],
        ->(memo, old_state) {
          # Find the highest scoring response
          $VECTOR_APPEND[
            memo,
            $VECTOR_REDUCE[
              # Find all possble responses
              $POSSIBLE_MOVES[
                old_state,
                $WHITE,
                $VECTOR_APPEND[$EMPTY_VECTOR, $GET_TO[old_state]]
              ],
              ->(memo, new_state) {
                IS_GREATER_OR_EQUAL[$GET_SCORE[new_state], $GET_SCORE[memo]][
                  memo,
                  $UPDATE_ALL_BUT_FROM_TO_PROMOTION[memo, new_state]
                ]
              },
              old_state
            ]
          ]
        },
        $EMPTY_VECTOR
      ]
    ]
  ]
}
