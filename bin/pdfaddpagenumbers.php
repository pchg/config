#!/usr/bin/php
<?
    (count($argv) == 3) || DIE("Usage: $argv[0] input.pdf output.pdf\n");
    $filename = $argv[1];
    $target = $argv[2];
    $tmpDir = '/tmp';
    $tmpName = 'addPdfPages';

    exec("pdfinfo $filename",$outList);

    foreach ($outList as $l) {
        if (preg_match('/^Pages/',$l)) {
            $a = preg_split('/[ ]+/ ',$l);
            break;
            }
    }
    echo "Input file $filename has $a[1] pages.\n";
    $numPages = $a[1];

    $escPages = '{' . $numPages . '}';

    if ($fp = fopen($tmpDir . '/' . $tmpName . '.tex','w')) {
        fwrite($fp,"
\\documentclass[12pt,a4paper]{article}
\\usepackage{multido}
\\usepackage[hmargin=.8cm,vmargin=1.5cm,nohead,nofoot]{geometry}
\\begin{document}
\\multido{}$escPages{\\vphantom{x}\\newpage}
\\end{document}");
        echo("Generating PDF with page numbers\n");
        exec("pdflatex -output-directory=$tmpDir $tmpDir/$tmpName");

        copy("$filename","$tmpDir/source.pdf");
        echo("Bursting input file\n");
        exec("pdftk $tmpDir/source.pdf burst output $tmpDir/file_%03d.pdf");
        echo("Bursting page number file\n");
        exec("pdftk $tmpDir/$tmpName.pdf burst output $tmpDir/numb_%03d.pdf");
        echo("Backgrounding ");
        for($ii=1;$ii<=$numPages;$ii++) {
            $jj = sprintf("%03d",$ii);
            exec("pdftk $tmpDir/file_$jj.pdf background $tmpDir/numb_$jj.pdf output $tmpDir/new_$jj.pdf");
            echo(".");
        }
        echo("\nMerging...");
        exec("pdftk $tmpDir/new_???.pdf output $target");
        echo("...Done\n");
    }
?>

