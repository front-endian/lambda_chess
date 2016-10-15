# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Piece Helper Functions

VALID      = ->(valid, invalid, en_passant) { valid }
INVALID    = ->(valid, invalid, en_passant) { invalid }
EN_PASSANT = ->(valid, invalid, en_passant) { en_passant }

NULL_PIECE = ->(board, from, to, last_from, last_to) { INVALID }

BASIC_CHECKS = ->(rule) {
  ->(board, from, to, last_from, last_to) {
    IF[
      AND[
        NOT[IS_EMPTY_AT[board, to]],
        IS_BLACK_AT[board, from][
          IS_BLACK_AT[board, to],
          IS_WHITE_AT[board, to]
        ]
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
      AND[
        FREE_PATH[board, from, to, DECREMENT],
        rule[
          LEFT[DISTANCE[from, to]],
          RIGHT[DISTANCE[from, to]]
        ]
      ][
        VALID,
        INVALID
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
      ->(memo, piece, x, y) {
        IF[
          OR[
            IS_EQUAL[piece, EMPTY_SPACE],
            IS_EQUAL[POSITION_TO_INDEX[PAIR[x, y]], POSITION_TO_INDEX[to]]
          ]
        ][
          # If this is the king under test or an empty space
          -> { memo },
          # If this is another piece
          -> {
            IF[memo][
              -> {
                GET_RULE[piece][after_move, PAIR[x, y], to, from, to][
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
        IS_GREATER_OR_EQUAL[ONE, LEFT[DISTANCE[from, to]]],
        IS_GREATER_OR_EQUAL[ONE, RIGHT[DISTANCE[from, to]]]
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
      LEFT[DISTANCE[from, to]],
      # "delta_y"
      RIGHT[DISTANCE[from, to]]
    ]
  }
]

PAWN_RULE = BASIC_CHECKS[
  ->(board, from, to, last_from, last_to) {
    ->(check_movement_in_axis, this_is_black, from_y, to_y) {
      ->(is_moving_forward_one, is_moving_sideways_one) {
        # Check whether the piece is moving forwards or backwards
        this_is_black[
          IS_ZERO[SUBTRACT[from_y, to_y]],
          IS_ZERO[SUBTRACT[to_y, from_y]]
        ][
          # If Moving forward
          # Check if the path is free of obstructing pieces
          FREE_PATH[board, from, to, IDENTITY][
            # If the path is free
            # Check if there is horizontal movement
            IS_ZERO[LEFT[DISTANCE[from, to]]][
              # If not moving horizontally
              OR[
                is_moving_forward_one,
                # Check moving forward two from the initial row
                AND[
                  check_movement_in_axis[RIGHT, TWO],
                  IS_EQUAL[
                    from_y,
                    this_is_black[BLACK_PAWN_ROW, WHITE_PAWN_ROW]
                  ]
                ]
              ][
                VALID,
                INVALID
              ],
              # If moving horizontally
              # Check if capturing en passant
              FIVE_CONDITIONS_MET[
                is_moving_sideways_one,
                is_moving_forward_one,
                # Check if the last moved piece is directly behind the new location
                IS_EQUAL[
                  POSITION_TO_INDEX[last_to],
                  POSITION_TO_INDEX[PAIR[LEFT[to], from_y]]
                ],
                # Check if the last moved piece a pawn of the opposite color
                IS_EQUAL[
                  GET_POSITION[board, last_to],
                  TO_MOVED_PIECE[this_is_black[WHITE_PAWN, BLACK_PAWN]]
                ],
                # Check if the last moved piece moved forward two
                IS_EQUAL[
                  RIGHT[DISTANCE[last_from, last_to]],
                  TWO
                ]
              ][
                EN_PASSANT,
                INVALID
              ]
            ],
            # There is a piece in the way
            # Check if moving for a normal capture
            AND[
              is_moving_sideways_one,
              is_moving_forward_one
            ][
              VALID,
              INVALID
            ]
          ],
          # If not moving forward
          INVALID
        ]
      }[
        # "is_moving_forward_one"
        check_movement_in_axis[RIGHT, ONE],
        # "is_moving_sideways_one"
        check_movement_in_axis[LEFT, ONE]
      ]
    }[
      # "check_movement_in_axis"
      ->(direction, amount) {
        IS_EQUAL[amount, direction[DISTANCE[from, to]]]
      },
      # "this_is_black"
      IS_BLACK_AT[board, from],
      # "from_y"
      RIGHT[from],
      # "to_y"
      RIGHT[to]
    ]
  }
]

GET_RULE = ->(piece) {
  ->(unmoved_black_piece) {
    IS_EQUAL[unmoved_black_piece, BLACK_PAWN][
      PAWN_RULE,
    IS_EQUAL[unmoved_black_piece, BLACK_ROOK][
      ROOK_RULE,
    IS_EQUAL[unmoved_black_piece, BLACK_KNIGHT][
      KNIGHT_RULE,
    IS_EQUAL[unmoved_black_piece, BLACK_BISHOP][
      BISHOP_RULE,
    IS_EQUAL[unmoved_black_piece, BLACK_QUEEN][
      QUEEN_RULE,
    IS_EQUAL[unmoved_black_piece, BLACK_KING][
      KING_RULE,
      NULL_PIECE
    ]]]]]]
  }[
    # "unmoved_black_piece"
    TO_UNMOVED_PIECE[
      IS_ZERO[SUBTRACT[piece, WHITE_OFFSET]][
        piece,
        SUBTRACT[piece, WHITE_OFFSET]
      ]
    ]
  ]
}
