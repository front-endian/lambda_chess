# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Piece Helper Functions

VALID      = ->(valid, invalid, en_passant) { valid }
INVALID    = ->(valid, invalid, en_passant) { invalid }
EN_PASSANT = ->(valid, invalid, en_passant) { en_passant }

NULL_PIECE = ->(board, from, to, last_from, last_to) { board }

NORMAL_PIECE = ->(rule) {
  ->(board, from, to, last_from, last_to) {
    AND[
      LEFT[IS_ZERO[DISTANCE[from, to]]],
      RIGHT[IS_ZERO[DISTANCE[from, to]]]
    ][
      board,
      rule[board, from, to][
        MOVE[board, from, to],
        board
      ]
    ]
  }
}

STRAIGHT_LINE_RULE = ->(rule) {
  ->(board, from, to) {
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

QUEEN_RULE = ->(from, to) {
  OR[
    ROOK_RULE[from, to],
    BISHOP_RULE[from, to]
  ][
    VALID,
    INVALID
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

KNIGHT_RULE = ->(_, from, to) {
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
    LEFT[DISTANCE[from, to]],
    RIGHT[DISTANCE[from, to]]
  ]
}

PAWN_RULE = ->(board, from, to, last_from, last_to) {
  # If moving forward
  IS_BLACK[GET_POSITION[board, from]][
    IS_ZERO[SUBTRACT[RIGHT[from], RIGHT[to]]],
    IS_ZERO[SUBTRACT[RIGHT[to], RIGHT[from]]]
  ][
    FREE_PATH[board, from, to, IDENTITY][
      # Moving forward one
      AND[
        IS_EQUAL[ZERO, LEFT[DISTANCE[from, to]]],
        IS_EQUAL[ONE, RIGHT[DISTANCE[from, to]]]
      ][
        VALID,
        # Moving forward two
        AND[
          IS_EQUAL[ZERO, LEFT[DISTANCE[from, to]]],
          IS_EQUAL[TWO, RIGHT[DISTANCE[from, to]]]
        ][
          # Only on first move
          IS_EQUAL[
            RIGHT[from],
            IS_BLACK[GET_POSITION[board, from]][
              ONE,
              SIX
            ]
          ][
            VALID,
            INVALID
          ],
          # Capturing en passant
          AND[
            AND[
              # Is moving diagonally forward one
              AND[
                IS_EQUAL[ONE, LEFT[DISTANCE[from, to]]],
                IS_EQUAL[ONE, RIGHT[DISTANCE[from, to]]]
              ],
              AND[
                # Is moving to an empty stop
                IS_EMPTY[board, to],
                # The last moved piece is directly behind the new location
                IS_EQUAL[
                    POSITION_TO_INDEX[last_to],
                    POSITION_TO_INDEX[PAIR[LEFT[to], RIGHT[from]]]
                ]
              ]
            ],
            AND[
              # The last moved piece a pawn of the opposite color
              IS_EQUAL[
                GET_POSITION[board, last_to],
                IS_BLACK[GET_POSITION[board, from]][
                  ELEVEN,
                  ONE
                ]
              ],
              # The last moved piece moved forward two
              IS_EQUAL[
                RIGHT[DISTANCE[last_from, last_to]],
                TWO
              ]
            ]
          ][
            EN_PASSANT,
            INVALID
          ]
        ]
      ],
      # Normal capturing
      AND[
        IS_EQUAL[ONE, LEFT[DISTANCE[from, to]]],
        IS_EQUAL[ONE, RIGHT[DISTANCE[from, to]]]
      ][
        VALID,
        INVALID
      ]
    ],
    INVALID
  ]
}
