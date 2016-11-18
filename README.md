# Lambda Chess!
A playable game of chess and an AI opponent written in untyped lambda calculus... and it's a quine.

[Here is a demo](https://youtu.be/DC-bjR6WeaM?t=39m7s) of it in action from a talk about how to write quines and other useless programs.

**Note:** the bottom part of the code—which is written in "normal" `Ruby`—just handles re-rendering the program and IO. The actual rules of chess and the AI are entirely done in untyped lambda syntax using `->` lambdas. Also, the expanded version in this repo is a little out of date and contains some bugs which were fixed later.

1. First look at the program:

   `cat lambda_chess.rb`

   Make your text reeeeeeal small (at least 195 characters per line) so you can see what the code looks like.
  
   **Hint:** you may want to turn off anti-aliasing and decrease the spacing between lines to make it look a little better.

2. Now run the program:

   `ruby lambda_chess.rb`

   Make the text reeeeeeal small again to see how the program changed.

3. To prove it is a quine, run:

   `ruby lambda_chess.rb | ruby`

   OR:
   
   `ruby lambda_chess.rb | ruby | ruby`

   OR:
   
   `ruby lambda_chess.rb | ruby | ruby | ruby`

   etc.

4.  You play as white (on the bottom). To play a move, pass your move in as a command line argument. Use the format `b1:c3`, or `b1-c3`, or `b1 c3`, etc (the argument parser is very forgiving). The first position (`b1` in this example) is the position you are moving from, while the second position (`c3` in this example) is the position you are moving to.

   `ruby lambda_chess.rb b1:c3`

5. To view your move AND to save the resulting program to a file you can use pipe the result into `tee`:

   `ruby lambda_chess.rb b1:c3 | tee move_1.rb`

   **Note:** if you run the same program multiple times with the same move, the black AI may respond differently each time.

6. To play another move, run the program the last move generated, passing in your next move:

   `ruby move_1.rb d2:d4 | tee move_2.rb`

Try playing a full game of chess! Try playing invalid moves! Castling is done by giving the from and to positions for the king you are castling, such as `e1:c1`. Pawns will automatically be promoted to queens, unless you pass in what piece you want to promote to such as `e7:e8 k` to promote to a knight, `b` for bishop, etc.

For chess nerds out there: yes, en passant captures are valid, and the AI may perform them.

## Find a bug?

Report it! I will fix it. It may take a while... but I'll do it. :-)
