# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# AI Functions

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

SCORE = ->(board) {
  BOARD_REDUCE[
    board,
    ->(memo, piece, position) {
      ADD[
        IS_BLACK[piece][
          ADD,
          SUBTRACT
        ][
          memo,
          GET_VALUE[piece]
        ],
        IF[IS_WHITE[piece]][
          -> {
            IF[IS_EQUAL[KING_VALUE, GET_VALUE[piece]]][
              -> {
                IS_NOT_IN_CHECK[board, position, GET_RULE][
                  ZERO,
                  MAX_PIECE_TOTAL
                ]
              },
              -> { ZERO }
            ]
          },
          -> { ZERO }
        ]
      ]
    },
    MAX_PIECE_TOTAL
  ]
}

FROM_TO_REDUCE = ->(possible_froms, possible_tos, func, initial) {
  VECTOR_REDUCE[
    possible_froms,
    ->(memo, from_position) {
      VECTOR_REDUCE[
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

POSSIBLE_MOVES = ->(state, color, possible_tos) {
  ->(board) {
    FROM_TO_REDUCE[
      POSITION_SELECT[board, color[IS_BLACK, IS_WHITE]],
      possible_tos,
      ->(possible_moves, from, to) {
        ADVANCE_STATE[
          CREATE_STATE[
            from,
            to,
            GET_LAST_FROM[state],
            GET_LAST_TO[state],
            board,
            SCORE[board],
            color[BLACK_QUEEN, WHITE_QUEEN],
            GET_SEED[state]
          ]
        ][
          ->(new_state) { VECTOR_APPEND[possible_moves, new_state] },
          -> { possible_moves }
        ]
      },
      EMPTY_VECTOR
    ]
  }[
    # "board"
    GET_BOARD[state]
  ]
}

POSSIBLE_BLACK_RESPONSES = ->(state) {
  POSSIBLE_MOVES[
    state,
    BLACK,
    POSITION_SELECT[
      GET_BOARD[state],
      ->(piece) { NOT[IS_BLACK[piece]] }
    ]
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
            old_state,
            color,
            VECTOR_APPEND[EMPTY_VECTOR, GET_TO[old_state]]
          ],
          ->(memo, new_state) {
            IS_GREATER_OR_EQUAL[GET_SCORE[new_state], GET_SCORE[memo]][
              color[UPDATE_ALL_BUT_FROM_TO[memo, new_state], memo],
              color[memo, UPDATE_ALL_BUT_FROM_TO[memo, new_state]]
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

BEST_MOVE = ->(states) {
  IF[IS_ZERO[VECTOR_SIZE[states]]][
    -> { PAIR[SECOND, ZERO] },
    -> {
      ->(best_vector) {
        PAIR[
          FIRST,
          NTH[
            VECTOR_LIST[best_vector],
            MODULUS[
              GET_SEED[VECTOR_FIRST[best_vector]],
              VECTOR_SIZE[best_vector]
            ]
          ]
        ]
      }[
        # "best_vector"
        BEST_SET_OF_STATES[states]
      ]
    }
  ]
}

BLACK_AI = ->(state) {
  BEST_MOVE[
    COUNTER_RESPONSES[
      COUNTER_RESPONSES[
        POSSIBLE_BLACK_RESPONSES[state],
        WHITE
      ],
      BLACK
    ]
  ]
}
