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

STRAIGHT_LINE_RULE = ->(rule) {
  ->(board, from, to, last_from, last_to) {
    AND[
      FREE_PATH[board, from, to, DECREMENT],
      rule[
        board,
        LEFT[DISTANCE[from, to]],
        RIGHT[DISTANCE[from, to]]
      ]
    ][
      VALID,
      INVALID
    ]
  }
}

IS_BLACK = ->(piece_number) {
  IS_ZERO[SUBTRACT[piece_number, TEN]]
}

# Piece Rules

ROOK_RULE = STRAIGHT_LINE_RULE[
  ->(board, delta_x, delta_y) {
    OR[
      IS_ZERO[delta_x],
      IS_ZERO[delta_y]
    ]
  }
]

BISHOP_RULE = STRAIGHT_LINE_RULE[
  ->(board, delta_x, delta_y) {
    IS_EQUAL[delta_x, delta_y]
  }
]

QUEEN_RULE = ->(board, from, to, last_from, last_to) {
  ->(check_rule) {
    OR[
      check_rule[ROOK_RULE],
      check_rule[BISHOP_RULE]
    ][
      VALID,
      INVALID
    ]
  }[
    # "check_rule"
    ->(rule) {
      rule[board, from, to, last_from, last_to][
        FIRST,
        SECOND,
        SECOND
      ]
    }
  ]
}

KING_RULE = STRAIGHT_LINE_RULE[
  ->(board, delta_x, delta_y) {
    AND[
      IS_GREATER_OR_EQUAL[ONE, delta_x],
      IS_GREATER_OR_EQUAL[ONE, delta_y]
    ]
  }
]

KNIGHT_RULE = ->(_, from, to, last_from, last_to) {
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


PAWN_RULE = ->(board, from, to, last_from, last_to) {
  ->(check_movement_in_axis, is_this_black, from_y, to_y) {
    ->(is_moving_forward_one, is_moving_sideways_one) {
      # Check whether the piece is moving forwards or backwards
      is_this_black[
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
                  is_this_black[ONE, SIX]
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
                is_this_black[ELEVEN, ONE]
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
        # Not moving forward
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
    # "is_this_black"
    IS_BLACK[GET_POSITION[board, from]],
    # "from_y"
    RIGHT[from],
    # "to_y"
    RIGHT[to]
  ]
}
