# Copyright (C) 2016 Colin Fulton
# All rights reserved.
#
# This software may be modified and distributed under the
# terms of the three-clause BSD license. See LICENSE.txt

# Piece Helper Functions

$VALID      = ->(valid, invalid, en_passant, castle, promotion) { valid }
$INVALID    = ->(valid, invalid, en_passant, castle, promotion) { invalid }

$ISNT_INVALID = ->(move_result) { move_result[FIRST, SECOND, FIRST, FIRST, FIRST] }

$ADVANCE_STATE = ->(state) {
  ->(move_type) {
    ->(if_valid, if_invalid) {
      IF[$ISNT_INVALID[move_type]][
        -> {
          if_valid[
            $UPDATE_AFTER_MOVE[
              state,
              move_type[
                $NORMAL_MOVE,
                ZERO,
                ->(board, from, to, new_piece) {
                  ->(captured) {
                    $CHANGE_MOVE[
                      $NORMAL_MOVE[board, from, to, new_piece],
                      captured,
                      captured,
                      $EMPTY_SPACE
                    ]
                  }[
                    # "captured"
                    PAIR[LEFT[to], RIGHT[from]]
                  ]
                },
                ->(board, from, to, new_piece) {
                  ->(is_moving_left) {
                    $NORMAL_MOVE[
                      $NORMAL_MOVE[board, from, to, new_piece],
                      # Rook positions
                      PAIR[is_moving_left[ZERO, $SEVEN], RIGHT[from]],
                      PAIR[is_moving_left[THREE, $FIVE], RIGHT[from]],
                      new_piece
                    ]
                  }[
                    # "is_moving_left"
                    IS_GREATER_OR_EQUAL[LEFT[from], LEFT[to]]
                  ]
                },
                $CHANGE_MOVE
              ][
                $GET_BOARD[state],
                $GET_FROM[state],
                $GET_TO[state],
                $GET_PROMOTION[state]
              ]
            ]
          ]
        },
        -> { if_invalid[] }
      ]
    }
  }[
    # "move_type"
    $GET_RULE[$GET_POSITION[$GET_BOARD[state], $GET_FROM[state]]][state]
  ]
}

$BASIC_CHECKS = ->(rule) {
  ->(get_rule) {
    ->(state) {
      $WITH_BASIC_INFO[
        state,
        ->(board, from, to) {
          IF[
            # Cannot capture own color
            $COLOR_SWITCH[$GET_POSITION[board, from]][
              $IS_BLACK[$GET_POSITION[board, to]],
              $IS_WHITE[$GET_POSITION[board, to]],
              SECOND
            ]
          ][
            -> { $INVALID },
            -> {
              ->(move_type) {
                IF[$ISNT_INVALID[move_type]][
                  -> {
                    ->(moved_piece, after_move) {
                      ->(my_kings_data) {
                        $VECTOR_REDUCE[
                          my_kings_data,
                          ->(memo, king_position) {
                            IF[memo][
                              -> {
                                $IS_NOT_IN_CHECK[
                                  after_move,
                                  king_position,
                                  get_rule
                                ][
                                  FIRST,
                                  SECOND
                                ]
                              },
                              -> { SECOND }
                            ]
                          },
                          FIRST
                        ]
                      }[
                        # "my_kings_data"
                        $POSITION_SELECT[
                          after_move,
                          ->(possible) {
                            AND[
                              $HAS_VALUE[possible, $KING_VALUE],
                              $IS_BLACK[possible][
                                $IS_BLACK[moved_piece],
                                $IS_WHITE[moved_piece]
                              ]
                            ]
                          }
                        ]
                      ]
                    }[
                      # "moved_piece"
                      $GET_POSITION[board, from],
                      # "after_move"
                      $NORMAL_MOVE[board, from, to, ZERO]
                    ][
                      move_type,
                      $INVALID
                    ]
                  },
                  -> { move_type }
                ]
              }[
                # "move_type"
                rule[state, get_rule]
              ]
            }
          ]
        }
      ]
    }
  }
}

$STRAIGHT_LINE_RULE = ->(rule) {
  $BASIC_CHECKS[
    ->(state, _) {
      $WITH_BASIC_INFO[
        state,
        ->(board, from, to) {
          IF[rule[$DELTA[from, to, LEFT], $DELTA[from, to, RIGHT]]][
            -> {
              $FREE_PATH[board, from, to, $DECREMENT][
                $VALID,
                $INVALID
              ]
            },
            -> { $INVALID }
          ]
        }
      ]
    }
  ]
}

# Piece Rules

$ROOK_RULE = $STRAIGHT_LINE_RULE[
  ->(delta_x, delta_y) {
    OR[
      IS_ZERO[delta_x],
      IS_ZERO[delta_y]
    ]
  }
]

$BISHOP_RULE = $STRAIGHT_LINE_RULE[
  ->(delta_x, delta_y) {
    IS_EQUAL[delta_x, delta_y]
  }
]

$QUEEN_RULE = ->(get_rule) {
  ->(state) {
    ->(follows_rule) {
      OR[
        follows_rule[$ROOK_RULE[get_rule]],
        follows_rule[$BISHOP_RULE[get_rule]]
      ][
        $VALID,
        $INVALID
      ]
    }[
      # "follows_rule"
      ->(rule) { $ISNT_INVALID[rule[state]] }
    ]
  }
}

$IS_NOT_IN_CHECK = ->(board, to, get_rule) {
  $FROM_TO_REDUCE[
    $POSITION_SELECT[
      board,
      ->(piece) {
        $IS_BLACK[$GET_POSITION[board, to]][
          $IS_WHITE[piece],
          $IS_BLACK[piece]
        ]
      }
    ],
    $VECTOR_APPEND[$EMPTY_VECTOR, to],
    ->(memo, from, to) {
      IF[memo][
        -> {
          NOT[
            $ISNT_INVALID[
              get_rule[$GET_POSITION[board, from]][
                $CREATE_STATE[from, to, from, to, board, ZERO, ZERO]
              ]
            ]
          ]
        },
        -> { SECOND }
      ]
    },
    FIRST
  ]
}

$KING_RULE = $BASIC_CHECKS[
  ->(state, get_rule) {
    IF[
      AND[
        IS_GREATER_OR_EQUAL[ONE, $DELTA[$GET_FROM[state], $GET_TO[state], LEFT]],
        IS_GREATER_OR_EQUAL[ONE, $DELTA[$GET_FROM[state], $GET_TO[state], RIGHT]]
      ]
    ][
      -> { $VALID },
      -> {
        $WITH_BASIC_INFO[
          state,
          ->(board, from, to) {
            IF[
              AND[
                IS_EQUAL[TWO, $DELTA[from, to, LEFT]],
                IS_ZERO[$DELTA[from, to, RIGHT]]
              ]
            ][
              -> {
                ->(is_moving_left) {
                  ->(rook_from, invalid, mid_to) {
                    IF[
                      ->(king, rook) {
                        FIVE_CONDITIONS_MET[
                          # Moving a king
                          $HAS_VALUE[king, $KING_VALUE],
                          # King is unmoved
                          NOT[$GET_MOVED[king]],
                          # Moving a rook
                          $HAS_VALUE[rook, $ROOK_VALUE],
                          # Rook is unmoved
                          NOT[$GET_MOVED[rook]],
                          # Path is free
                          $FREE_PATH[board, from, rook_from, $DECREMENT],
                        ]
                      }[
                        # "king"
                        $GET_POSITION[board, from],
                        # "rook"
                        $GET_POSITION[board, rook_from]
                      ]
                    ][
                      -> {
                        IF[$IS_NOT_IN_CHECK[$NORMAL_MOVE[board, from, from, ZERO], from, get_rule]][
                          -> {
                            IF[$IS_NOT_IN_CHECK[$NORMAL_MOVE[board, from, mid_to, ZERO], mid_to, get_rule]][
                              # Don't check $IS_NOT_IN_CHECK[board, from, to] since
                              # $BASIC_CHECKS does that.
                              -> { FIRST },
                              invalid
                            ]
                          },
                          invalid
                        ]
                      },
                      invalid
                    ]
                  }[
                    # "rook_from"
                    PAIR[is_moving_left[ZERO, $SEVEN], RIGHT[from]],
                    # "invalid"
                    -> { SECOND },
                    # "mid_to"
                    PAIR[
                      is_moving_left[$DECREMENT, $INCREMENT][LEFT[from]],
                      RIGHT[from]
                    ]
                  ]
                }[
                  # "is_moving_left"
                  IS_GREATER_OR_EQUAL[LEFT[from], LEFT[to]]
                ]
              },
              -> { SECOND }
            ]
          }
        ][
          ->(valid, invalid, en_passant, castle, promotion) { castle },
          $INVALID
        ]
      }
    ]
  }
]

$KNIGHT_RULE = $BASIC_CHECKS[
  ->(state, _) {
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
        $VALID,
        $INVALID
      ]
    }[
      # "delta_x"
      $DELTA[$GET_FROM[state], $GET_TO[state], LEFT],
      # "delta_y"
      $DELTA[$GET_FROM[state], $GET_TO[state], RIGHT]
    ]
  }
]

$PAWN_RULE = $BASIC_CHECKS[
  ->(state, _) {
    $WITH_BASIC_INFO[
      state,
      ->(board, from, to) {
        ->(pawn_is_black, from_y, to_y) {
          IF[
             pawn_is_black[
              IS_ZERO[$SUBTRACT[from_y, to_y]],
              IS_ZERO[$SUBTRACT[to_y, from_y]]
            ]
          ][
            # If moving forward
            -> {
              ->(vertical_movement) {
                IF[IS_EQUAL[ONE, vertical_movement]][
                  # If moving vertically one
                  -> {
                    ->(horizontal_movement, last_to) {
                      IF[IS_ZERO[horizontal_movement]][
                        # If not moving horizontally
                        -> {
                          # Performing a normal move
                          $IS_EMPTY[$GET_POSITION[board, to]][
                            IS_EQUAL[
                              to_y,
                              pawn_is_black[$SEVEN, ZERO]
                            ][
                              ->(valid, invalid, en_passant, castle, promotion) { promotion },
                              $VALID
                            ],
                            $INVALID
                          ]
                        },
                        # If moving horizontally
                        -> {
                          IF[IS_EQUAL[ONE, horizontal_movement]][
                            # If moving horizontally one
                            -> {
                              IF[$IS_EMPTY[$GET_POSITION[board, to]]][
                                # Not performing a normal capture
                                -> {
                                  ->(last_moved) {
                                    FIVE_CONDITIONS_MET[
                                      FIRST,
                                      # Position behind "to" is "last_to"
                                      $SAME_POSITION[
                                        last_to,
                                        PAIR[LEFT[to], from_y]
                                      ],
                                      # "last_moved" is a pawn
                                      $HAS_VALUE[last_moved, $PAWN_VALUE],
                                      # "last_moved" is the opposite color
                                      pawn_is_black[$IS_WHITE, $IS_BLACK][last_moved],
                                      # "last_moved" moved forward two
                                      IS_EQUAL[
                                        $DELTA[$GET_LAST_FROM[state], last_to, RIGHT],
                                        TWO
                                      ]
                                    ][
                                      ->(valid, invalid, en_passant, castle, promotion) { en_passant },
                                      $INVALID
                                    ]
                                  }[
                                    # "last_moved"
                                    $GET_POSITION[board, last_to]
                                  ]
                                },
                                # Performing a normal capture
                                -> { $VALID }
                              ]
                            },
                            # If moving horizontally more than
                            -> { $INVALID }
                          ]
                        }
                      ]
                    }[
                      # "horizontal_movement"
                      $DELTA[from, to, LEFT],
                      # "last_to"
                      $GET_LAST_TO[state]
                    ]
                  },
                  # If not moving vertically one
                  -> {
                    IF[IS_EQUAL[TWO, vertical_movement]][
                      # If moving vertically two
                      -> {
                        IF[IS_ZERO[$DELTA[from, to, LEFT]]][
                          # If not moving horizontally
                          -> {
                            AND[
                              $IS_EMPTY[$GET_POSITION[board, to]],
                              AND[
                                # One space ahead of pawn is free
                                $IS_EMPTY[
                                  $GET_POSITION[
                                    board,
                                    PAIR[
                                      LEFT[to],
                                      $CHANGE_FUNC[from, to, RIGHT][from_y]
                                    ]
                                  ]
                                ],
                                # Pawn has not moved yet
                                NOT[$GET_MOVED[$GET_POSITION[board, from]]]
                              ]
                            ][
                              $VALID,
                              $INVALID
                            ]
                          },
                          # If moving horizontally
                          -> { $INVALID }
                        ]
                      },
                      # If not moving vertically two
                      -> { $INVALID }
                    ]
                  }
                ]
              }[
                # "vertical_movement"
                $DELTA[from, to, RIGHT]
              ]
            },
            # If not moving forward
            -> { $INVALID }
          ]
        }[
          # "pawn_is_black"
          $IS_BLACK[$GET_POSITION[board, from]],
          # "from_y"
          RIGHT[from],
          # "to_y"
          RIGHT[to]
        ]
      }
    ]
  }
]

$GET_RULE = $Z[->(get_rule) {
  ->(piece) {
    $HAS_VALUE[piece, $PAWN_VALUE][
      $PAWN_RULE,
    $HAS_VALUE[piece, $ROOK_VALUE][
      $ROOK_RULE,
    $HAS_VALUE[piece, $KNIGHT_VALUE][
      $KNIGHT_RULE,
    $HAS_VALUE[piece, $BISHOP_VALUE][
      $BISHOP_RULE,
    $HAS_VALUE[piece, $QUEEN_VALUE][
      $QUEEN_RULE,
    $HAS_VALUE[piece, $KING_VALUE][
      $KING_RULE,
      ->(_) { ->(_) { $INVALID } }
    ]]]]]][get_rule]
  }
}]
