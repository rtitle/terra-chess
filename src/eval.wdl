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
        Float   white_accuracy = EvalGame.white_accuracy
        Float   black_accuracy = EvalGame.black_accuracy
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
        docker: "us.gcr.io/broad-dsp-gcr-public/rt-terra-chess:0.3"
    }

    output {
        Float white_accuracy = read_float("white_accuracy.txt")
        Float black_accuracy = read_float("black_accuracy.txt")
    }
}