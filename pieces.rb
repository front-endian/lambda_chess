# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Piece Helper Functions

VALID      = ->(valid, invalid, en_passant) { valid }
INVALID    = ->(valid, invalid, en_passant) { invalid }
EN_PASSANT = ->(valid, invalid, en_passant) { en_passant }

BASIC_CHECKS = ->(rule) {
  ->(board, from, to, last_from, last_to) {
    IF[
      # Cannot capture own color
      COLOR_SWITCH[GET_POSITION[board, from]][
        IS_BLACK[GET_POSITION[board, to]],
        IS_WHITE[GET_POSITION[board, to]],
        SECOND
      ]
    ][
      -> { INVALID },
      -> { rule[board, from, to, last_from, last_to] }
    ]
  }
}

STRAIGHT_LINE_RULE = ->(rule) {
  BASIC_CHECKS[
    ->(board, from, to, last_from, last_to) {
      IF[rule[DELTA[from, to, LEFT], DELTA[from, to, RIGHT]]][
        -> {
          FREE_PATH[board, from, to, DECREMENT][
            VALID,
            INVALID
          ]
        },
        -> { INVALID }
      ]
    }
  ]
}

# Piece Rules

ROOK_RULE = STRAIGHT_LINE_RULE[
  ->(delta_x, delta_y) {
    OR[
      IS_ZERO[delta_x],
      IS_ZERO[delta_y]
    ]
  }
]

BISHOP_RULE = STRAIGHT_LINE_RULE[
  ->(delta_x, delta_y) {
    IS_EQUAL[delta_x, delta_y]
  }
]

QUEEN_RULE = BASIC_CHECKS[
  ->(board, from, to, last_from, last_to) {
    ->(follows_rule) {
      OR[
        follows_rule[ROOK_RULE],
        follows_rule[BISHOP_RULE]
      ][
        VALID,
        INVALID
      ]
    }[
      # "follows_rule"
      ->(rule) {
        rule[board, from, to, last_from, last_to][
          FIRST,
          SECOND,
          SECOND
        ]
      }
    ]
  }
]

IS_NOT_IN_CHECK = ->(board, from, to) {
  ->(after_move) {
    BOARD_REDUCE[
      after_move,
      ->(memo, piece, position) {
        IF[
          OR[
            IS_EMPTY[piece],
            SAME_POSITION[position, to]
          ]
        ][
          # If this is the king under test or an empty space
          -> { memo },
          # If this is another piece
          -> {
            IF[memo][
              -> {
                GET_RULE[piece][after_move, position, to, from, to][
                  SECOND,
                  FIRST,
                  SECOND
                ]
              },
              -> { SECOND }
            ]
          }
        ]
      },
      FIRST
    ]
  }[
    # "after_move"
    MOVE[board, from, to]
  ]
}

KING_RULE = BASIC_CHECKS[
  ->(board, from, to, last_from, last_to) {
    # Wrap in an IF to prevent expensive check when unnecessary
    IF[
      AND[
        IS_GREATER_OR_EQUAL[ONE, DELTA[from, to, LEFT]],
        IS_GREATER_OR_EQUAL[ONE, DELTA[from, to, RIGHT]]
      ]
    ][
      # Only moving one space in any direction
      -> {
        IS_NOT_IN_CHECK[board, from, to][
          # Not moving into check
          VALID,
          # Not moving into check
          INVALID
        ]
      },
      # Moving more than one space in any direction
      -> { INVALID }
    ]
  }
]

KNIGHT_RULE = BASIC_CHECKS[
  ->(_, from, to, last_from, last_to) {
    ->(delta_x, delta_y) {
      OR[
        AND[
          IS_EQUAL[TWO, delta_x],
          IS_EQUAL[ONE, delta_y]
        ],
        AND[
          IS_EQUAL[ONE, delta_x],
          IS_EQUAL[TWO, delta_y]
        ]
      ][
        VALID,
        INVALID
      ]
    }[
      # "delta_x"
      DELTA[from, to, LEFT],
      # "delta_y"
      DELTA[from, to, RIGHT]
    ]
  }
]

PAWN_RULE = BASIC_CHECKS[
  ->(board, from, to, last_from, last_to) {
    ->(pawn_is_black, from_y, to_y) {
      IF[
         pawn_is_black[
          IS_ZERO[SUBTRACT[from_y, to_y]],
          IS_ZERO[SUBTRACT[to_y, from_y]]
        ]
      ][
        # If moving forward
        -> {
          ->(vertical_movement) {
            IF[IS_EQUAL[ONE, vertical_movement]][
              # If moving vertically one
              -> {
                ->(horizontal_movement) {
                  IF[IS_ZERO[horizontal_movement]][
                    # If not moving horizontally
                    -> {
                      # Performing a normal move
                      IS_EMPTY[GET_POSITION[board, to]][VALID, INVALID]
                    },
                    # If moving horizontally
                    -> {
                      IF[IS_EQUAL[ONE, horizontal_movement]][
                        # If moving horizontally one
                        -> {
                          IF[IS_EMPTY[GET_POSITION[board, to]]][
                            # Not performing a normal capture
                            -> {
                              ->(last_moved) {
                                FIVE_CONDITIONS_MET[
                                  FIRST,
                                  # Position behind "to" is "last_to"
                                  SAME_POSITION[
                                    last_to,
                                    PAIR[LEFT[to], from_y]
                                  ],
                                  # "last_moved" is a pawn
                                  HAS_VALUE[last_moved, PAWN_VALUE],
                                  # "last_moved" is the opposite color
                                  pawn_is_black[IS_WHITE, IS_BLACK][last_moved],
                                  # "last_moved" moved forward two
                                  IS_EQUAL[
                                    DELTA[last_from, last_to, RIGHT],
                                    TWO
                                  ]
                                ][
                                  EN_PASSANT,
                                  INVALID
                                ]
                              }[
                                # "last_moved"
                                GET_POSITION[board, last_to]
                              ]
                            },
                            # Performing a normal capture
                            -> { VALID }
                          ]
                        },
                        # If moving horizontally more than
                        -> { INVALID }
                      ]
                    }
                  ]
                }[
                  # "horizontal_movement"
                  DELTA[from, to, LEFT],
                ]
              },
              # If not moving vertically one
              -> {
                IF[IS_EQUAL[TWO, vertical_movement]][
                  # If moving vertically two
                  -> {
                    IF[IS_ZERO[DELTA[from, to, LEFT]]][
                      # If not moving horizontally
                      -> {
                        AND[
                          IS_EMPTY[GET_POSITION[board, to]],
                          AND[
                            # One space ahead of pawn is free
                            IS_EMPTY[
                              GET_POSITION[
                                board,
                                PAIR[
                                  LEFT[to],
                                  CHANGE_FUNC[from, to, RIGHT][from_y]
                                ]
                              ]
                            ],
                            # Pawn has not moved yet
                            NOT[IS_MOVED[GET_POSITION[board, from]]]
                          ]
                        ][
                          VALID,
                          INVALID
                        ]
                      },
                      # If moving horizontally
                      -> { INVALID }
                    ]
                  },
                  # If not moving vertically two
                  -> { INVALID }
                ]
              }
            ]
          }[
            # "vertical_movement"
            DELTA[from, to, RIGHT]
          ]
        },
        # If not moving forward
        -> { INVALID }
      ]
    }[
      # "pawn_is_black"
      IS_BLACK[GET_POSITION[board, from]],
      # "from_y"
      RIGHT[from],
      # "to_y"
      RIGHT[to]
    ]
  }
]

GET_RULE = ->(piece) {
  ->(piece_value) {
    IS_EQUAL[piece_value, PAWN_VALUE][
      PAWN_RULE,
    IS_EQUAL[piece_value, ROOK_VALUE][
      ROOK_RULE,
    IS_EQUAL[piece_value, KNIGHT_VALUE][
      KNIGHT_RULE,
    IS_EQUAL[piece_value, BISHOP_VALUE][
      BISHOP_RULE,
    IS_EQUAL[piece_value, QUEEN_VALUE][
      QUEEN_RULE,
    IS_EQUAL[piece_value, KING_VALUE][
      KING_RULE,
      ZERO
    ]]]]]]
  }[
    # "piece_value"
    GET_VALUE[piece]
  ]
}
