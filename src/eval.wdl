version 1.0

workflow ChessEval {
    meta {
        description: "Evalulates a chess game using Stockfish."
    }

    input {
        Int    offset
        File   pgn_file
    }

    call EvalGame {
        input:
            offset      = offset,
            pgn_file    = pgn_file
    }

    output {
        Int   white_avg_centipawn_loss = EvalGame.white_avg_centipawn_loss
        Int   black_avg_centipawn_loss = EvalGame.black_avg_centipawn_loss
    }
}

task EvalGame {
    input {
        Int    offset
        File   pgn_file
    }

    command <<<
        python /root/eval.py ~{pgn_file} ~{offset}
    >>>
    

    runtime {
        docker: "us.gcr.io/broad-dsp-gcr-public/rt-terra-chess:0.2"
    }

    output {
        Int white_avg_centipawn_loss = read_int("white_avg_centipawn_loss.txt")
        Int black_avg_centipawn_loss = read_int("black_avg_centipawn_loss.txt")
    }
}