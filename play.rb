# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

PERFORM_CASTLING = ->(old_board, from, to, last_from, last_to) {
  ->(is_moving_left) {
    ->(rook_from, not_in_check) {
      IF[
        AND[
          AND[
            # Moving an unmoved king
            IS_EQUAL[
              GET_POSITION[old_board, from],
              IS_BLACK_AT[old_board, from][BLACK_KING, WHITE_KING]
            ],
            # Moving an unmoved rook
            IS_EQUAL[
              GET_POSITION[old_board, rook_from],
              IS_BLACK_AT[old_board, rook_from][BLACK_ROOK, WHITE_ROOK]
            ]
          ],
          # The path is free
          FREE_PATH[old_board, from, rook_from, DECREMENT]
        ]
      ][
        ->() {
          IF[
            IS_NOT_IN_CHECK[old_board, from, from]
          ][
            ->() {
              MOVE[
                MOVE[old_board, from, to],
                rook_from,
                PAIR[
                  is_moving_left[THREE, FIVE],
                  RIGHT[from]
                ]
              ]
            },
            ->() { old_board }
          ]
        },
        ->() { old_board }
      ]
    }[
      # "rook_from"
      PAIR[
        is_moving_left[ZERO, SEVEN],
        RIGHT[from]
      ],
      # "not_in_check"
      FIRST
    ]
  }[
    # "is_moving_left"
    IS_GREATER_OR_EQUAL[LEFT[from], LEFT[to]]
  ]
}
