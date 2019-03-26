#!/bin/bash
awk ' == "NN" {print $0}' DeReKo-2014-II-MainArchive-STT.100000.freq/DeReKo-2014-II-MainArchive-STT.100000.freq | sort -nk4 > nouns_german
