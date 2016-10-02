# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Piece Helper Functions

STRAIGHT_LINE_PIECE = ->(rule) {
  ->(board, from, to) {
    FREE_PATH[board, from, to, DECREMENT][
      rule[
        board,
        LEFT[DISTANCE[from, to]],
        RIGHT[DISTANCE[from, to]]
      ],
      SECOND
    ]
  }
}

IS_BLACK = ->(piece_number) {
  IS_ZERO[SUBTRACT[piece_number, TEN]]
}

# Piece Functions

NULL_PIECE = ->(_, _, _) { SECOND }

ROOK = STRAIGHT_LINE_PIECE[
  ->(board, delta_x, delta_y) {
    OR[
      IS_ZERO[delta_x],
      IS_ZERO[delta_y]
    ]
  }
]

BISHOP = STRAIGHT_LINE_PIECE[
  ->(board, delta_x, delta_y) {
    IS_EQUAL[delta_x, delta_y]
  }
]

QUEEN = ->(from, to) {
  OR[
    ROOK[from, to],
    BISHOP[from, to]
  ]
}

KING = STRAIGHT_LINE_PIECE[
  ->(board, delta_x, delta_y) {
    AND[
      IS_GREATER_OR_EQUAL[ONE, delta_x],
      IS_GREATER_OR_EQUAL[ONE, delta_y]
    ]
  }
]

KNIGHT = ->(_, from, to) {
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
    ]
  }[
    LEFT[DISTANCE[from, to]],
    RIGHT[DISTANCE[from, to]]
  ]
}

PAWN = ->(board, from, to) {
  IS_BLACK[GET_POSITION[board, from]][
    IS_ZERO[SUBTRACT[RIGHT[from], RIGHT[to]]],
    IS_ZERO[SUBTRACT[RIGHT[to], RIGHT[from]]]
  ][
    FREE_PATH[board, from, to, IDENTITY][
      AND[
        IS_EQUAL[ZERO, LEFT[DISTANCE[from, to]]],
        IS_EQUAL[ONE, RIGHT[DISTANCE[from, to]]]
      ][
        # MOVING FORWARD ONE
        FIRST,
        AND[
          IS_EQUAL[ZERO, LEFT[DISTANCE[from, to]]],
          IS_EQUAL[TWO, RIGHT[DISTANCE[from, to]]]
        ][
          # MOVING FORWARD TWO
          IS_EQUAL[
            RIGHT[from],
            IS_BLACK[GET_POSITION[board, from]][
              ONE,
              SIX
            ]
          ],
          SECOND
        ]
      ],
      # CAPTURING
      AND[
        IS_EQUAL[ONE, LEFT[DISTANCE[from, to]]],
        IS_EQUAL[ONE, RIGHT[DISTANCE[from, to]]]
      ]
    ],
    SECOND
  ]
}
