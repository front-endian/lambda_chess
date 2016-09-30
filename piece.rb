# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Piece Functions

DISTANCE_RULE = ->(rule) {
  ->(board, from, to) {
    rule[
      board,
      LEFT[DISTANCE[from, to]],
      RIGHT[DISTANCE[from, to]]
    ]
  }
}

NULL_PIECE = ->(_, _, _) { SECOND }

ROOK = DISTANCE_RULE[
  ->(board, delta_x, delta_y) {
    OR[
      IS_ZERO[delta_x],
      IS_ZERO[delta_y]
    ]
  }
]

BISHOP = DISTANCE_RULE[
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

KING = DISTANCE_RULE[
  ->(board, delta_x, delta_y) {
    AND[
      IS_GREATER_OR_EQUAL[ONE, delta_x],
      IS_GREATER_OR_EQUAL[ONE, delta_y]
    ]
  }
]

KNIGHT = DISTANCE_RULE[
  ->(board, delta_x, delta_y) {
    OR[
      AND[
        IS_EQUAL[TWO, delta_x],
        IS_EQUAL[THREE, delta_y]
      ],
      AND[
        IS_EQUAL[THREE, delta_x],
        IS_EQUAL[TWO, delta_y]
      ]
    ]
  }
]
