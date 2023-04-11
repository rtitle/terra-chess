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
        Float   white_avg_centipawn_loss = EvalGame.white_avg_centipawn_loss
        Float   black_avg_centipawn_loss = EvalGame.black_avg_centipawn_loss
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
        Float white_avg_centipawn_loss = read_float("white_avg_centipawn_loss.txt")
        Float black_avg_centipawn_loss = read_float("black_avg_centipawn_loss.txt")
    }
}