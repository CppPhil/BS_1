function splitFile { # $1 = fileName, $2 = pieceSize, $3 = isTextFile
    if [ "$3" -eq 0 ]; then # normal file
        split -b $2k $1 $1.
        if [ "$verbosity" -eq 1 ]; then
            echo splitting $1 into $2 kiloByte pieces
        fi
    else # text file
        split -l $2 $1 $1.
        if [ "$verbosity" -eq 1 ]; then
            echo splitting $1 into $2 line pieces
        fi
    fi
}

splitFile $fileName $pieceSize $isTextFile

