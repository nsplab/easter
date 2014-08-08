# for cardiac
inkscape ../vep/matlab_data/_Thu_15_05_2014_14_13_26_vep__cardiac_labelled.svg --export-pdf=../vep/matlab_data/_Thu_15_05_2014_14_13_26_vep__cardiac_labelled.pdf
pdfcrop ../vep/matlab_data/_Thu_15_05_2014_14_13_26_vep__cardiac_labelled.pdf

inkscape ../qrs/matlab_data/_Thu_15_05_2014_14_13_26_vep__qrs.svg --export-pdf=../qrs/matlab_data/_Thu_15_05_2014_14_13_26_vep__qrs.pdf
pdfcrop ../qrs/matlab_data/_Thu_15_05_2014_14_13_26_vep__qrs.pdf

pdfcrop ../qrs/matlab_data/_Thu_15_05_2014_14_13_26_vep__start.pdf
pdfcrop ../qrs/matlab_data/_Thu_15_05_2014_14_13_26_vep__end.pdf

