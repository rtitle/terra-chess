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
        Int   white_avg_centipawn_loss = CalculateAverage.white_avg_centipawn_loss
        Int   black_avg_centipawn_loss = CalculateAverage.black_avg_centipawn_loss
    }
}

task EvalGame {
    input {
        Int    offset
        File   pgn_file
    }

    command <<<
        python eval.py

    >>>
    

    runtime {
        docker: "broadinstitute/horsefish"
    }

    output {
        Int white_avg_centipawn_loss = read_int("white_avg_centipawn_loss.txt")
        Int black_avg_centipawn_loss = read_int("black_avg_centipawn_loss.txt")
    }
}