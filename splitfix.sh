#!/bin/bash
# splitfix
# 7th of October 2015

function usage {
    cat <<EOF
    $0  [OPTIONS] FILE [FILE ...] Split FILE into
    fixed-size pieces.
    The pieces are 10 lines long,
        if FILE is a text file.
    The pieces are 10 kiB long,
        if FILE is *not* a text file.
    The last piece may be smaller, it contains the rest
        of the original file.
    The output files bear the name of the input file
        with a 4-digit numerical suffix.
    The original file can be reconstructed with
        the command ''cat FILE.*''

    EXAMPLE:
        splitfix.sh foo.pdf
          splits foo.pdf into the files
          foo.pdf.0000 foo.pdf.0001 etc.

    splitfix.sh [-h | --help] This help text
    splitfix.sh --version     Print version number

    OPTIONS:
    -h
      --help    this help text

    -s SIZE     size of the pieces
                  in lines (for text files)
                  or in kiBytes (for other files)

    -v
      --verbose print debugging messages
EOF
    exit 0
}

function fixFilenames { # $1 = fileName
    num=0
    for file in $1.*
    do
        if [ "$num" -lt 10 ]; then
            mv "$file" "$1.000$num"
        elif [ "$num" -lt 100 ]; then
            mv "$file" "$1.00$num"
        elif [ "$num" -lt 1000 ]; then
            mv "$file" "$1.0$num"
        else
            mv "$file" "$1.$num"
        fi
        let "num++"
    done
    if [ "$verbosity" -eq 1 ]; then
        echo fixed filenames.
    fi
}

# ##########################################################################
#                   main
cParams=$#
defPieceSize=10
pieceSize=$defPieceSize
verbosity=0
versionNumber=1
fileName=0
fileGiven=0
while [ "$cParams" -gt 0 ]; do
    case $1 in
        "-h" | "--help")
        usage
        ;;
        "-s")
        pieceSize=$2
        if [[ $pieceSize =~ ^[^0-9]+$ ]]; then
            pieceSize=$defPieceSize
        fi
        ;;
        "-v" | "--verbose")
        verbosity=1
        ;;
        "--version")
        echo $versionNumber
        ;;
        *)
        ;;
    esac
    
    if [ "$cParams" -eq 1 ]; then
        fileName=$1
        fileGiven=1
    fi

    shift
    let "cParams--"
done

isTextFile=0

if [ "$fileGiven" -ne 0 ]; then    
	FileTyp=$(file -i $fileName)
	echo "File Typ: $FileTyp" 	

    if file -i "$fileName" | grep -q "^.*text/plain; charset=.*"; then
	
        # it's text
        let isTextFile=1
        if [ "$verbosity" -eq 1 ]; then
            echo the file was determined to be a text file
        fi
    fi

    export verbosity
    export fileName
    export pieceSize
    export isTextFile    
    ./subShellFileSplit.sh
 
    fixFilenames $fileName
fi

exit 0

