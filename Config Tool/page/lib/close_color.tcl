#!/bin/sh
# Time-stamp: <2013-02-13 11:38:50 rozen>

# Derived from ColorExplorer by William J. Poser.

array set NamesToColors {
    snow fffafa
    {ghost white} f8f8ff
    {white smoke} f5f5f5
    gainsboro dcdcdc
    {floral white} fffaf0
    {old lace} fdf5e6
    linen faf0e6
    {antique white} faebd7
    {papaya whip} ffefd5
    {blanched almond} ffebcd
    bisque ffe4c4
    {peach puff} ffdab9
    {navajo white} ffdead
    moccasin ffe4b5
    cornsilk fff8dc
    ivory fffff0
    {lemon chiffon} fffacd
    seashell fff5ee
    honeydew f0fff0
    {mint cream} f5fffa
    azure f0ffff
    {alice blue} f0f8ff
    lavender e6e6fa
    {lavender blush} fff0f5
    {misty rose} ffe4e1
    white ffffff
    black 000000
    {dark slate gray} 2f4f4f
    {dim gray} 696969
    {slate gray} 708090
    {light slate gray} 778899
    gray bebebe
    {light grey} d3d3d3
    {midnight blue} 191970
    navy 000080
    {cornflower blue} 6495ed
    {dark slate blue} 483d8b
    {slate blue} 6a5acd
    {medium slate blue} 7b68ee
    {light slate blue} 8470ff
    {medium blue} 0000cd
    {royal blue} 4169e1
    blue 0000ff
    {dodger blue} 1e90ff
    {deep sky blue} 00bfff
    {sky blue} 87ceeb
    {light sky blue} 87cefa
    {steel blue} 4682b4
    {light steel blue} b0c4de
    {light blue} add8e6
    {powder blue} b0e0e6
    {pale turquoise} afeeee
    {dark turquoise} 00ced1
    {medium turquoise} 48d1cc
    turquoise 40e0d0
    cyan 00ffff
    {light cyan} e0ffff
    {cadet blue} 5f9ea0
    {medium aquamarine} 66cdaa
    aquamarine 7fffd4
    {dark green} 006400
    {dark olive green} 556b2f
    {dark sea green} 8fbc8f
    {sea green} 2e8b57
    {medium sea green} 3cb371
    {light sea green} 20b2aa
    {pale green} 98fb98
    {spring green} 00ff7f
    {lawn green} 7cfc00
    green 00ff00
    chartreuse 7fff00
    {medium spring green} 00fa9a
    {green yellow} adff2f
    {lime green} 32cd32
    {yellow green} 9acd32
    {forest green} 228b22
    {olive drab} 6b8e23
    {dark khaki} bdb76b
    khaki f0e68c
    {pale goldenrod} eee8aa
    {light goldenrod yellow} fafad2
    {light yellow} ffffe0
    yellow ffff00
    gold ffd700
    {light goldenrod} eedd82
    goldenrod daa520
    {dark goldenrod} b8860b
    {rosy brown} bc8f8f
    {indian red} cd5c5c
    {saddle brown} 8b4513
    sienna a0522d
    peru cd853f
    burlywood deb887
    beige f5f5dc
    wheat f5deb3
    {sandy brown} f4a460
    tan d2b48c
    chocolate d2691e
    firebrick b22222
    brown a52a2a
    {dark salmon} e9967a
    salmon fa8072
    {light salmon} ffa07a
    orange ffa500
    {dark orange} ff8c00
    coral ff7f50
    {light coral} f08080
    tomato ff6347
    {orange red} ff4500
    red ff0000
    {hot pink} ff69b4
    {deep pink} ff1493
    pink ffc0cb
    {light pink} ffb6c1
    {pale violet red} db7093
    maroon b03060
    {medium violet red} c71585
    {violet red} d02090
    magenta ff00ff
    violet ee82ee
    plum dda0dd
    orchid da70d6
    {medium orchid} ba55d3
    {dark orchid} 9932cc
    {dark violet} 9400d3
    {blue violet} 8a2be2
    purple a020f0
    {medium purple} 9370db
    thistle d8bfd8
    snow2 eee9e9
    snow3 cdc9c9
    snow4 8b8989
    seashell2 eee5de
    seashell3 cdc5bf
    seashell4 8b8682
    AntiqueWhite1 ffefdb
    AntiqueWhite2 eedfcc
    AntiqueWhite3 cdc0b0
    AntiqueWhite4 8b8378
    bisque2 eed5b7
    bisque3 cdb79e
    bisque4 8b7d6b
    PeachPuff2 eecbad
    PeachPuff3 cdaf95
    PeachPuff4 8b7765
    NavajoWhite2 eecfa1
    NavajoWhite3 cdb38b
    NavajoWhite4 8b795e
    LemonChiffon2 eee9bf
    LemonChiffon3 cdc9a5
    LemonChiffon4 8b8970
    cornsilk2 eee8cd
    cornsilk3 cdc8b1
    cornsilk4 8b8878
    ivory2 eeeee0
    ivory3 cdcdc1
    ivory4 8b8b83
    honeydew2 e0eee0
    honeydew3 c1cdc1
    honeydew4 838b83
    LavenderBlush2 eee0e5
    LavenderBlush3 cdc1c5
    LavenderBlush4 8b8386
    MistyRose2 eed5d2
    MistyRose3 cdb7b5
    MistyRose4 8b7d7b
    azure2 e0eeee
    azure3 c1cdcd
    azure4 838b8b
    SlateBlue1 836fff
    SlateBlue2 7a67ee
    SlateBlue3 6959cd
    SlateBlue4 473c8b
    RoyalBlue1 4876ff
    RoyalBlue2 436eee
    RoyalBlue3 3a5fcd
    RoyalBlue4 27408b
    blue2 0000ee
    blue4 00008b
    DodgerBlue2 1c86ee
    DodgerBlue3 1874cd
    DodgerBlue4 104e8b
    SteelBlue1 63b8ff
    SteelBlue2 5cacee
    SteelBlue3 4f94cd
    SteelBlue4 36648b
    DeepSkyBlue2 00b2ee
    DeepSkyBlue3 009acd
    DeepSkyBlue4 00688b
    SkyBlue1 87ceff
    SkyBlue2 7ec0ee
    SkyBlue3 6ca6cd
    SkyBlue4 4a708b
    LightSkyBlue1 b0e2ff
    LightSkyBlue2 a4d3ee
    LightSkyBlue3 8db6cd
    LightSkyBlue4 607b8b
    SlateGray1 c6e2ff
    SlateGray2 b9d3ee
    SlateGray3 9fb6cd
    SlateGray4 6c7b8b
    LightSteelBlue1 cae1ff
    LightSteelBlue2 bcd2ee
    LightSteelBlue3 a2b5cd
    LightSteelBlue4 6e7b8b
    LightBlue1 bfefff
    LightBlue2 b2dfee
    LightBlue3 9ac0cd
    LightBlue4 68838b
    LightCyan2 d1eeee
    LightCyan3 b4cdcd
    LightCyan4 7a8b8b
    PaleTurquoise1 bbffff
    PaleTurquoise2 aeeeee
    PaleTurquoise3 96cdcd
    PaleTurquoise4 668b8b
    CadetBlue1 98f5ff
    CadetBlue2 8ee5ee
    CadetBlue3 7ac5cd
    CadetBlue4 53868b
    turquoise1 00f5ff
    turquoise2 00e5ee
    turquoise3 00c5cd
    turquoise4 00868b
    cyan2 00eeee
    cyan3 00cdcd
    cyan4 008b8b
    DarkSlateGray1 97ffff
    DarkSlateGray2 8deeee
    DarkSlateGray3 79cdcd
    DarkSlateGray4 528b8b
    aquamarine2 76eec6
    aquamarine4 458b74
    DarkSeaGreen1 c1ffc1
    DarkSeaGreen2 b4eeb4
    DarkSeaGreen3 9bcd9b
    DarkSeaGreen4 698b69
    SeaGreen1 54ff9f
    SeaGreen2 4eee94
    SeaGreen3 43cd80
    PaleGreen1 9aff9a
    PaleGreen2 90ee90
    PaleGreen3 7ccd7c
    PaleGreen4 548b54
    SpringGreen2 00ee76
    SpringGreen3 00cd66
    SpringGreen4 008b45
    green2 00ee00
    green3 00cd00
    green4 008b00
    chartreuse2 76ee00
    chartreuse3 66cd00
    chartreuse4 458b00
    OliveDrab1 c0ff3e
    OliveDrab2 b3ee3a
    OliveDrab4 698b22
    DarkOliveGreen1 caff70
    DarkOliveGreen2 bcee68
    DarkOliveGreen3 a2cd5a
    DarkOliveGreen4 6e8b3d
    khaki1 fff68f
    khaki2 eee685
    khaki3 cdc673
    khaki4 8b864e
    LightGoldenrod1 ffec8b
    LightGoldenrod2 eedc82
    LightGoldenrod3 cdbe70
    LightGoldenrod4 8b814c
    LightYellow2 eeeed1
    LightYellow3 cdcdb4
    LightYellow4 8b8b7a
    yellow2 eeee00
    yellow3 cdcd00
    yellow4 8b8b00
    gold2 eec900
    gold3 cdad00
    gold4 8b7500
    goldenrod1 ffc125
    goldenrod2 eeb422
    goldenrod3 cd9b1d
    goldenrod4 8b6914
    DarkGoldenrod1 ffb90f
    DarkGoldenrod2 eead0e
    DarkGoldenrod3 cd950c
    DarkGoldenrod4 8b6508
    RosyBrown1 ffc1c1
    RosyBrown2 eeb4b4
    RosyBrown3 cd9b9b
    RosyBrown4 8b6969
    IndianRed1 ff6a6a
    IndianRed2 ee6363
    IndianRed3 cd5555
    IndianRed4 8b3a3a
    sienna1 ff8247
    sienna2 ee7942
    sienna3 cd6839
    sienna4 8b4726
    burlywood1 ffd39b
    burlywood2 eec591
    burlywood3 cdaa7d
    burlywood4 8b7355
    wheat1 ffe7ba
    wheat2 eed8ae
    wheat3 cdba96
    wheat4 8b7e66
    tan1 ffa54f
    tan2 ee9a49
    tan4 8b5a2b
    chocolate1 ff7f24
    chocolate2 ee7621
    chocolate3 cd661d
    firebrick1 ff3030
    firebrick2 ee2c2c
    firebrick3 cd2626
    firebrick4 8b1a1a
    brown1 ff4040
    brown2 ee3b3b
    brown3 cd3333
    brown4 8b2323
    salmon1 ff8c69
    salmon2 ee8262
    salmon3 cd7054
    salmon4 8b4c39
    LightSalmon2 ee9572
    LightSalmon3 cd8162
    LightSalmon4 8b5742
    orange2 ee9a00
    orange3 cd8500
    orange4 8b5a00
    DarkOrange1 ff7f00
    DarkOrange2 ee7600
    DarkOrange3 cd6600
    DarkOrange4 8b4500
    coral1 ff7256
    coral2 ee6a50
    coral3 cd5b45
    coral4 8b3e2f
    tomato2 ee5c42
    tomato3 cd4f39
    tomato4 8b3626
    OrangeRed2 ee4000
    OrangeRed3 cd3700
    OrangeRed4 8b2500
    red2 ee0000
    red3 cd0000
    red4 8b0000
    DeepPink2 ee1289
    DeepPink3 cd1076
    DeepPink4 8b0a50
    HotPink1 ff6eb4
    HotPink2 ee6aa7
    HotPink3 cd6090
    HotPink4 8b3a62
    pink1 ffb5c5
    pink2 eea9b8
    pink3 cd919e
    pink4 8b636c
    LightPink1 ffaeb9
    LightPink2 eea2ad
    LightPink3 cd8c95
    LightPink4 8b5f65
    PaleVioletRed1 ff82ab
    PaleVioletRed2 ee799f
    PaleVioletRed3 cd6889
    PaleVioletRed4 8b475d
    maroon1 ff34b3
    maroon2 ee30a7
    maroon3 cd2990
    maroon4 8b1c62
    VioletRed1 ff3e96
    VioletRed2 ee3a8c
    VioletRed3 cd3278
    VioletRed4 8b2252
    magenta2 ee00ee
    magenta3 cd00cd
    magenta4 8b008b
    orchid1 ff83fa
    orchid2 ee7ae9
    orchid3 cd69c9
    orchid4 8b4789
    plum1 ffbbff
    plum2 eeaeee
    plum3 cd96cd
    plum4 8b668b
    MediumOrchid1 e066ff
    MediumOrchid2 d15fee
    MediumOrchid3 b452cd
    MediumOrchid4 7a378b
    DarkOrchid1 bf3eff
    DarkOrchid2 b23aee
    DarkOrchid3 9a32cd
    DarkOrchid4 68228b
    purple1 9b30ff
    purple2 912cee
    purple3 7d26cd
    purple4 551a8b
    MediumPurple1 ab82ff
    MediumPurple2 9f79ee
    MediumPurple3 8968cd
    MediumPurple4 5d478b
    thistle1 ffe1ff
    thistle2 eed2ee
    thistle3 cdb5cd
    thistle4 8b7b8b
    gray1 030303
    gray2 050505
    gray3 080808
    gray4 0a0a0a
    gray5 0d0d0d
    gray6 0f0f0f
    gray7 121212
    gray8 141414
    gray9 171717
    gray10 1a1a1a
    gray11 1c1c1c
    gray12 1f1f1f
    gray13 212121
    gray14 242424
    gray15 262626
    gray16 292929
    gray17 2b2b2b
    gray18 2e2e2e
    gray19 303030
    gray20 333333
    gray21 363636
    gray22 383838
    gray23 3b3b3b
    gray24 3d3d3d
    gray25 404040
    gray26 424242
    gray27 454545
    gray28 474747
    gray29 4a4a4a
    gray30 4d4d4d
    gray31 4f4f4f
    gray32 525252
    gray33 545454
    gray34 575757
    gray35 595959
    gray36 5c5c5c
    gray37 5e5e5e
    gray38 616161
    gray39 636363
    gray40 666666
    gray42 6b6b6b
    gray43 6e6e6e
    gray44 707070
    gray45 737373
    gray46 757575
    gray47 787878
    gray48 7a7a7a
    gray49 7d7d7d
    gray50 7f7f7f
    gray51 828282
    gray52 858585
    gray53 878787
    gray54 8a8a8a
    gray55 8c8c8c
    gray56 8f8f8f
    gray57 919191
    gray58 949494
    gray59 969696
    gray60 999999
    gray61 9c9c9c
    gray62 9e9e9e
    gray63 a1a1a1
    gray64 a3a3a3
    gray65 a6a6a6
    gray66 a8a8a8
    gray67 ababab
    gray68 adadad
    gray69 b0b0b0
    gray70 b3b3b3
    gray71 b5b5b5
    gray72 b8b8b8
    gray73 bababa
    gray74 bdbdbd
    gray75 bfbfbf
    gray76 c2c2c2
    gray77 c4c4c4
    gray78 c7c7c7
    gray79 c9c9c9
    gray80 cccccc
    gray81 cfcfcf
    gray82 d1d1d1
    gray83 d4d4d4
    gray84 d6d6d6
    gray85 d9d9d9
    gray86 dbdbdb
    gray87 dedede
    gray88 e0e0e0
    gray89 e3e3e3
    gray90 e5e5e5
    gray91 e8e8e8
    gray92 ebebeb
    gray93 ededed
    gray94 f0f0f0
    gray95 f2f2f2
    gray96 f5f5f5
    gray97 f7f7f7
    gray98 fafafa
    gray99 fcfcfc
}

#Make colors with similar names sort together
proc ColorNameCompare {a b} {
    set AMain [lindex [split $a] end]
    set BMain [lindex [split $b] end]
    set A [string trim [regsub -nocase \
        ^(dark|deep|hot|medium|light|forest|antique|indian|pale|misty|royal|mint) $AMain ""]]
    set B [string trim [regsub -nocase \
        ^(dark|deep|hot|medium|light|forest|antique|indian|pale|misty|royal|mint) $BMain ""]]
    set A [string trim [regsub -nocase  \
        ^(sky|slate|steel|powder|midnight|dim|dodger|cadet|lime|sea|olive|spring) $A ""]]
    set B [string trim [regsub -nocase  \
        ^(sky|slate|steel|powder|midnight|dim|dodger|cadet|lime|sea|olive|spring) $B ""]]
    set cr [string compare -nocase $A $B]
    if {$cr != 0} {
    return $cr;
    } else {
    set LengthA [string length $a]
    set LengthB [string length $b]
    set cr [expr $LengthA - $LengthB]
    if {$cr != 0} {
        return $cr;
    } else {
        set cr [string compare -nocase $a $b]
        if {$cr != 0} {
        return $cr;
        } else {
        return [string compare $a $b]
        }
    }
    }
}

proc setup_arrays {} {
    global NamesToColors
    foreach k [lsort -command ColorNameCompare [array names NamesToColors]] {
    lappend ::ColorNameList $k
    lappend ::ColorSpecList $NamesToColors($k)
    }
}

proc ColorDistance {x y} {
    scan $x "%2x%2x%2x" rx gx bx
    scan $y "%2x%2x%2x" ry gy by
    set dr [expr $rx - $ry]
    set dg [expr $gx - $gy]
    set db [expr $bx - $by]
    return [expr ($dr*$dr) + ($dg*$dg) + ($db*$db)]
}

set MaximumColorDistance [ColorDistance 000000 FFFFFF];

proc FindClosestNamedColor {color} {
    global MaximumColorDistance;
    set color [string range $color 1 end]  ;# Delete leading '#'
    set tgt $color
    set min $MaximumColorDistance;
    set BestColorIndex 0;
    set cnt 0;
    foreach cs $::ColorSpecList {

		set delta [ColorDistance $tgt $cs]

		if {$delta < $min} {
				set min $delta
				set BestColorIndex $cnt
				if {$min == 0} break
			}
			incr cnt;
    }

    set name [lrange $::ColorNameList $BestColorIndex $BestColorIndex]
    return [list $name $min]
}


setup_arrays

