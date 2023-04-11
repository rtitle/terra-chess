import argparse
import chess.pgn
import chess.engine

parser = argparse.ArgumentParser()

parser.add_argument('pgn_file', help='pgn file')
parser.add_argument('offset', help='offset')
args = parser.parse_args()

print(f"Opening pgn file {args.pgn_file}, offset {args.offset}")

pgn = open(args.pgn_file)
pgn.seek(int(args.offset))
game = chess.pgn.read_game(pgn)

stockfish_uci = "/usr/local/bin/stockfish"
print(f"Using stockfish engine at {stockfish_uci}")
engine = chess.engine.SimpleEngine.popen_uci(stockfish_uci)

color = chess.WHITE
board = game.board()
white_sum = 0
black_sum = 0
white_count = 0
black_count = 0
time_limit = 0.5
for move in game.mainline_moves():
    # First play the best move
    best = engine.play(board, chess.engine.Limit(time=time_limit))
    board.push(best.move)
    best_info = engine.analyse(board, chess.engine.Limit(time=time_limit))

    # Now play the actual move
    board.pop()
    board.push(move)
    info = engine.analyse(board, chess.engine.Limit(time=time_limit))

    # Calculate difference in evaluation
    if best.move == move:
        diff = 0
    else:
        diff = best_info['score'].pov(color).score(mate_score = 1000) - info['score'].pov(color).score(mate_score = 1000)

    # Sum up to compute average
    if color == chess.WHITE:
        white_sum += diff
        white_count += 1
        color = chess.BLACK
    else:
        black_sum += diff
        black_count += 1
        color = chess.WHITE

white_avg_centipawn_loss = white_sum / white_count
black_avg_centipawn_loss = black_sum / black_count
print(f"White avg centipawn loss: {white_avg_centipawn_loss}")
print(f"Black avg centipawn loss: {black_avg_centipawn_loss}")

with open('white_avg_centipawn_loss.txt', 'w') as f:
    f.write(white_avg_centipawn_loss)

with open('black_avg_centipawn_loss.txt', 'w') as f:
    f.write(black_avg_centipawn_loss)