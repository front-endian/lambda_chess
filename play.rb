# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

PLAY = ->(board, from, to, last_from, last_to, move_type, promotion) {
  ->(perform_normal_move) {

    move_type[
      # Normal Move
      # Castle Left
      # Castle Right
      # Promote
    ]
  }[
    # "perform_normal_move"
    -> {
      GET_RULE[GET_POSITION[board, from]][board, from, to, from, to]
    }
  ]
}

MAX_PIECE_TOTAL = ADD[
  MULTIPLY[PAWN_VALUE, EIGHT],
  ADD[
    MULTIPLY[KNIGHT_VALUE, TWO],
    ADD[
      MULTIPLY[BISHOP_VALUE, TWO],
      ADD[
        MULTIPLY[ROOK_VALUE, TWO],
        ADD[
          QUEEN_VALUE,
          KING_VALUE
        ]
      ]
    ]
  ]
]

SCORE = ->(board, color) {
  BOARD_REDUCE[
    board,
    ->(memo, piece, position) {
      IS_BLACK[piece][
        color[ADD, SUBTRACT],
        color[SUBTRACT, ADD]
      ][
        memo,
        GET_VALUE[piece]
      ]
    },
    MAX_PIECE_TOTAL
  ]
}

FROM_TO_REDUCE = ->(from_vector, to_vector, func, initial) {
  VECTOR_REDUCE[
    from_vector,
    ->(memo, from_position) {
      VECTOR_REDUCE[
        to_vector,
        ->(inner_memo, to_position) {
          func[inner_memo, from_position, to_position]
        },
        memo
      ]
    },
    initial
  ]
}

POSSIBLE_MOVES = ->(board, color, to_vector, last_from, last_to) {
  FROM_TO_REDUCE[
    POSITION_SELECT[board, color[IS_BLACK, IS_WHITE]],
    to_vector,
    ->(move_vector, from, to) {
      ->(move_result) {
        IF[ISNT_INVALID[move_result]][
          -> {
            ->(new_board) {
              VECTOR_APPEND[
                move_vector,
                CREATE_STATE[
                  from,
                  to,
                  from,
                  to,
                  new_board,
                  SCORE[new_board, BLACK]
                ]
              ]
            }[
              MOVE_FUNC[move_result][
                board,
                from,
                to,
                color[BLACK_QUEEN, WHITE_QUEEN]
              ]
            ]
          },
          -> { move_vector }
        ]
      }[
        # "move_result"
        GET_RULE[GET_POSITION[board, from]][
          board,
          from,
          to,
          last_from,
          last_to
        ]
      ]
    },
    EMPTY_VECTOR
  ]
}

POSSIBLE_BLACK_RESPONSES = ->(board, last_from, last_to) {
  POSSIBLE_MOVES[
    board,
    BLACK,
    POSITION_SELECT[board, ALWAYS_FIRST],
    last_from,
    last_to
  ]
}

COUNTER_RESPONSES = ->(reponses, color) {
  VECTOR_REDUCE[
    reponses,
    ->(memo, old_state) {
      # Find the highest scoring response
      VECTOR_APPEND[
        memo,
        VECTOR_REDUCE[
          # Find all possble responses
          POSSIBLE_MOVES[
            GET_BOARD[old_state],
            color,
            VECTOR_APPEND[EMPTY_VECTOR, GET_TO[old_state]],
            GET_LAST_FROM[old_state],
            GET_LAST_TO[old_state]
          ],
          ->(memo, new_state) {
            IS_GREATER_OR_EQUAL[GET_SCORE[new_state], GET_SCORE[memo]][
              color[UPDATE_STATE[memo, new_state], memo],
              color[memo, UPDATE_STATE[memo, new_state]]
            ]
          },
          old_state
        ]
      ]
    },
    EMPTY_VECTOR
  ]
}

BEST_SET_OF_STATES = ->(states) {
  VECTOR_REDUCE[
    states,
    ->(memo, state) {
      IF[IS_ZERO[VECTOR_SIZE[memo]]][
        -> { VECTOR_APPEND[memo, state] },
        -> {
          IS_EQUAL[GET_SCORE[state], GET_SCORE[VECTOR_FIRST[memo]]][
            VECTOR_APPEND[memo, state],
            IS_GREATER_OR_EQUAL[
              GET_SCORE[state],
              GET_SCORE[VECTOR_FIRST[memo]]
            ][
              VECTOR_APPEND[EMPTY_VECTOR, state],
              memo
            ]
          ]
        }
      ]
    },
    EMPTY_VECTOR
  ]
}

BEST_MOVE = ->(states, random) {
  IF[IS_ZERO[VECTOR_SIZE[states]]][
    -> { PAIR[SECOND, ZERO] },
    -> {
      ->(best) {
        PAIR[
          FIRST,
          NTH[
            VECTOR_LIST[best],
            MODULUS[random, VECTOR_SIZE[best]]
          ]
        ]
      }[
        # "best"
        BEST_SET_OF_STATES[states]
      ]
    }
  ]
}

BLACK_AI = ->(board, last_from, last_to, random) {
  BEST_MOVE[
    COUNTER_RESPONSES[
      COUNTER_RESPONSES[
        POSSIBLE_BLACK_RESPONSES[board, last_from, last_to],
        WHITE
      ],
      BLACK
    ],
    random
  ]
}
