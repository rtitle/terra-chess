import argparse
import chess.pgn
import chess.engine
import math

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
time_limit = 2
win_prev = None

# See https://lichess.org/page/accuracy for explanation of accuracy algorithm
for move in game.mainline_moves():
    # Get the centipawn analysis for the current position
    info = engine.analyse(board, chess.engine.Limit(time=time_limit))
    centipawns = info['score'].pov(color).score(mate_score = 1000)

    # Get win %
    win = 50 + 50 * min(1, max(-1, 2 / (1 + math.exp(-0.00368208 * centipawns)) - 1))

    # Get accuracy %
    if win_prev:
        if win >= win_prev:
            accuracy = 100
        else:
            win_diff = win_prev = win
            accuracy = min(100, max(0, 103.1668100711649 * math.exp(-0.04354415386753951 * win_diff) + -3.166924740191411))
        # Sum up to compute average
        if color == chess.WHITE:
            white_sum += accuracy
            white_count += 1
            color = chess.BLACK
        else:
            black_sum += accuracy
            black_count += 1
            color = chess.WHITE

    board.push(move)
    win_prev = win

engine.quit()

white_accuracy = white_sum / white_count
black_accuracy = black_sum / black_count
print(f"White accuracy: {white_accuracy}")
print(f"Black accuracy: {black_accuracy}")

with open('white_accuracy.txt', 'w') as f:
    f.write(str(white_accuracy))

with open('black_accuracy.txt', 'w') as f:
    f.write(str(black_accuracy))
