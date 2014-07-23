# Module to build global array "color", the key is the color name and
# the corresponding hexadecimal value. Rozen

proc convert_color {args} {
    global color
    foreach {r g b c} $args {}
    set x [format "#%02x%02x%02x" $r $g $b]
    set color($c) $x
}

convert_color 255 250 250  {snow}
convert_color 248 248 255  {ghost white}
convert_color 248 248 255  {GhostWhite}
convert_color 245 245 245  {white smoke}
convert_color 245 245 245  {WhiteSmoke}
convert_color 220 220 220  {gainsboro}
convert_color 255 250 240  {floral white}
convert_color 255 250 240  {FloralWhite}
convert_color 253 245 230  {old lace}
convert_color 253 245 230  {OldLace}
convert_color 250 240 230  {linen}
convert_color 250 235 215  {antique white}
convert_color 250 235 215  {AntiqueWhite}
convert_color 255 239 213  {papaya whip}
convert_color 255 239 213  {PapayaWhip}
convert_color 255 235 205  {blanched almond}
convert_color 255 235 205  {BlanchedAlmond}
convert_color 255 228 196  {bisque}
convert_color 255 218 185  {peach puff}
convert_color 255 218 185  {PeachPuff}
convert_color 255 222 173  {navajo white}
convert_color 255 222 173  {NavajoWhite}
convert_color 255 228 181  {moccasin}
convert_color 255 248 220  {cornsilk}
convert_color 255 255 240  {ivory}
convert_color 255 250 205  {lemon chiffon}
convert_color 255 250 205  {LemonChiffon}
convert_color 255 245 238  {seashell}
convert_color 240 255 240  {honeydew}
convert_color 245 255 250  {mint cream}
convert_color 245 255 250  {MintCream}
convert_color 240 255 255  {azure}
convert_color 240 248 255  {alice blue}
convert_color 240 248 255  {AliceBlue}
convert_color 230 230 250  {lavender}
convert_color 255 240 245  {lavender blush}
convert_color 255 240 245  {LavenderBlush}
convert_color 255 228 225  {misty rose}
convert_color 255 228 225  {MistyRose}
convert_color 255 255 255  {white}
convert_color   0   0   0  {black}
convert_color  47  79  79  {dark slate gray}
convert_color  47  79  79  {DarkSlateGray}
convert_color  47  79  79  {dark slate grey}
convert_color  47  79  79  {DarkSlateGrey}
convert_color 105 105 105  {dim gray}
convert_color 105 105 105  {DimGray}
convert_color 105 105 105  {dim grey}
convert_color 105 105 105  {DimGrey}
convert_color 112 128 144  {slate gray}
convert_color 112 128 144  {SlateGray}
convert_color 112 128 144  {slate grey}
convert_color 112 128 144  {SlateGrey}
convert_color 119 136 153  {light slate gray}
convert_color 119 136 153  {LightSlateGray}
convert_color 119 136 153  {light slate grey}
convert_color 119 136 153  {LightSlateGrey}
convert_color 190 190 190  {gray}
convert_color 190 190 190  {grey}
convert_color 211 211 211  {light grey}
convert_color 211 211 211  {LightGrey}
convert_color 211 211 211  {light gray}
convert_color 211 211 211  {LightGray}
convert_color  25  25 112  {midnight blue}
convert_color  25  25 112  {MidnightBlue}
convert_color   0   0 128  {navy}
convert_color   0   0 128  {navy blue}
convert_color   0   0 128  {NavyBlue}
convert_color 100 149 237  {cornflower blue}
convert_color 100 149 237  {CornflowerBlue}
convert_color  72  61 139  {dark slate blue}
convert_color  72  61 139  {DarkSlateBlue}
convert_color 106  90 205  {slate blue}
convert_color 106  90 205  {SlateBlue}
convert_color 123 104 238  {medium slate blue}
convert_color 123 104 238  {MediumSlateBlue}
convert_color 132 112 255  {light slate blue}
convert_color 132 112 255  {LightSlateBlue}
convert_color   0   0 205  {medium blue}
convert_color   0   0 205  {MediumBlue}
convert_color  65 105 225  {royal blue}
convert_color  65 105 225  {RoyalBlue}
convert_color   0   0 255  {blue}
convert_color  30 144 255  {dodger blue}
convert_color  30 144 255  {DodgerBlue}
convert_color   0 191 255  {deep sky blue}
convert_color   0 191 255  {DeepSkyBlue}
convert_color 135 206 235  {sky blue}
convert_color 135 206 235  {SkyBlue}
convert_color 135 206 250  {light sky blue}
convert_color 135 206 250  {LightSkyBlue}
convert_color  70 130 180  {steel blue}
convert_color  70 130 180  {SteelBlue}
convert_color 176 196 222  {light steel blue}
convert_color 176 196 222  {LightSteelBlue}
convert_color 173 216 230  {light blue}
convert_color 173 216 230  {LightBlue}
convert_color 176 224 230  {powder blue}
convert_color 176 224 230  {PowderBlue}
convert_color 175 238 238  {pale turquoise}
convert_color 175 238 238  {PaleTurquoise}
convert_color   0 206 209  {dark turquoise}
convert_color   0 206 209  {DarkTurquoise}
convert_color  72 209 204  {medium turquoise}
convert_color  72 209 204  {MediumTurquoise}
convert_color  64 224 208  {turquoise}
convert_color   0 255 255  {cyan}
convert_color 224 255 255  {light cyan}
convert_color 224 255 255  {LightCyan}
convert_color  95 158 160  {cadet blue}
convert_color  95 158 160  {CadetBlue}
convert_color 102 205 170  {medium aquamarine}
convert_color 102 205 170  {MediumAquamarine}
convert_color 127 255 212  {aquamarine}
convert_color   0 100   0  {dark green}
convert_color   0 100   0  {DarkGreen}
convert_color  85 107  47  {dark olive green}
convert_color  85 107  47  {DarkOliveGreen}
convert_color 143 188 143  {dark sea green}
convert_color 143 188 143  {DarkSeaGreen}
convert_color  46 139  87  {sea green}
convert_color  46 139  87  {SeaGreen}
convert_color  60 179 113  {medium sea green}
convert_color  60 179 113  {MediumSeaGreen}
convert_color  32 178 170  {light sea green}
convert_color  32 178 170  {LightSeaGreen}
convert_color 152 251 152  {pale green}
convert_color 152 251 152  {PaleGreen}
convert_color   0 255 127  {spring green}
convert_color   0 255 127  {SpringGreen}
convert_color 124 252   0  {lawn green}
convert_color 124 252   0  {LawnGreen}
convert_color   0 255   0  {green}
convert_color 127 255   0  {chartreuse}
convert_color   0 250 154  {medium spring green}
convert_color   0 250 154  {MediumSpringGreen}
convert_color 173 255  47  {green yellow}
convert_color 173 255  47  {GreenYellow}
convert_color  50 205  50  {lime green}
convert_color  50 205  50  {LimeGreen}
convert_color 154 205  50  {yellow green}
convert_color 154 205  50  {YellowGreen}
convert_color  34 139  34  {forest green}
convert_color  34 139  34  {ForestGreen}
convert_color 107 142  35  {olive drab}
convert_color 107 142  35  {OliveDrab}
convert_color 189 183 107  {dark khaki}
convert_color 189 183 107  {DarkKhaki}
convert_color 240 230 140  {khaki}
convert_color 238 232 170  {pale goldenrod}
convert_color 238 232 170  {PaleGoldenrod}
convert_color 250 250 210  {light goldenrod yellow}
convert_color 250 250 210  {LightGoldenrodYellow}
convert_color 255 255 224  {light yellow}
convert_color 255 255 224  {LightYellow}
convert_color 255 255   0  {yellow}
convert_color 255 215   0  {gold}
convert_color 238 221 130  {light goldenrod}
convert_color 238 221 130  {LightGoldenrod}
convert_color 218 165  32  {goldenrod}
convert_color 184 134  11  {dark goldenrod}
convert_color 184 134  11  {DarkGoldenrod}
convert_color 188 143 143  {rosy brown}
convert_color 188 143 143  {RosyBrown}
convert_color 205  92  92  {indian red}
convert_color 205  92  92  {IndianRed}
convert_color 139  69  19  {saddle brown}
convert_color 139  69  19  {SaddleBrown}
convert_color 160  82  45  {sienna}
convert_color 205 133  63  {peru}
convert_color 222 184 135  {burlywood}
convert_color 245 245 220  {beige}
convert_color 245 222 179  {wheat}
convert_color 244 164  96  {sandy brown}
convert_color 244 164  96  {SandyBrown}
convert_color 210 180 140  {tan}
convert_color 210 105  30  {chocolate}
convert_color 178  34  34  {firebrick}
convert_color 165  42  42  {brown}
convert_color 233 150 122  {dark salmon}
convert_color 233 150 122  {DarkSalmon}
convert_color 250 128 114  {salmon}
convert_color 255 160 122  {light salmon}
convert_color 255 160 122  {LightSalmon}
convert_color 255 165   0  {orange}
convert_color 255 140   0  {dark orange}
convert_color 255 140   0  {DarkOrange}
convert_color 255 127  80  {coral}
convert_color 240 128 128  {light coral}
convert_color 240 128 128  {LightCoral}
convert_color 255  99  71  {tomato}
convert_color 255  69   0  {orange red}
convert_color 255  69   0  {OrangeRed}
convert_color 255   0   0  {red}
convert_color 255 105 180  {hot pink}
convert_color 255 105 180  {HotPink}
convert_color 255  20 147  {deep pink}
convert_color 255  20 147  {DeepPink}
convert_color 255 192 203  {pink}
convert_color 255 182 193  {light pink}
convert_color 255 182 193  {LightPink}
convert_color 219 112 147  {pale violet red}
convert_color 219 112 147  {PaleVioletRed}
convert_color 176  48  96  {maroon}
convert_color 199  21 133  {medium violet red}
convert_color 199  21 133  {MediumVioletRed}
convert_color 208  32 144  {violet red}
convert_color 208  32 144  {VioletRed}
convert_color 255   0 255  {magenta}
convert_color 238 130 238  {violet}
convert_color 221 160 221  {plum}
convert_color 218 112 214  {orchid}
convert_color 186  85 211  {medium orchid}
convert_color 186  85 211  {MediumOrchid}
convert_color 153  50 204  {dark orchid}
convert_color 153  50 204  {DarkOrchid}
convert_color 148   0 211  {dark violet}
convert_color 148   0 211  {DarkViolet}
convert_color 138  43 226  {blue violet}
convert_color 138  43 226  {BlueViolet}
convert_color 160  32 240  {purple}
convert_color 147 112 219  {medium purple}
convert_color 147 112 219  {MediumPurple}
convert_color 216 191 216  {thistle}
convert_color 255 250 250  {snow1}
convert_color 238 233 233  {snow2}
convert_color 205 201 201  {snow3}
convert_color 139 137 137  {snow4}
convert_color 255 245 238  {seashell1}
convert_color 238 229 222  {seashell2}
convert_color 205 197 191  {seashell3}
convert_color 139 134 130  {seashell4}
convert_color 255 239 219  {AntiqueWhite1}
convert_color 238 223 204  {AntiqueWhite2}
convert_color 205 192 176  {AntiqueWhite3}
convert_color 139 131 120  {AntiqueWhite4}
convert_color 255 228 196  {bisque1}
convert_color 238 213 183  {bisque2}
convert_color 205 183 158  {bisque3}
convert_color 139 125 107  {bisque4}
convert_color 255 218 185  {PeachPuff1}
convert_color 238 203 173  {PeachPuff2}
convert_color 205 175 149  {PeachPuff3}
convert_color 139 119 101  {PeachPuff4}
convert_color 255 222 173  {NavajoWhite1}
convert_color 238 207 161  {NavajoWhite2}
convert_color 205 179 139  {NavajoWhite3}
convert_color 139 121  94  {NavajoWhite4}
convert_color 255 250 205  {LemonChiffon1}
convert_color 238 233 191  {LemonChiffon2}
convert_color 205 201 165  {LemonChiffon3}
convert_color 139 137 112  {LemonChiffon4}
convert_color 255 248 220  {cornsilk1}
convert_color 238 232 205  {cornsilk2}
convert_color 205 200 177  {cornsilk3}
convert_color 139 136 120  {cornsilk4}
convert_color 255 255 240  {ivory1}
convert_color 238 238 224  {ivory2}
convert_color 205 205 193  {ivory3}
convert_color 139 139 131  {ivory4}
convert_color 240 255 240  {honeydew1}
convert_color 224 238 224  {honeydew2}
convert_color 193 205 193  {honeydew3}
convert_color 131 139 131  {honeydew4}
convert_color 255 240 245  {LavenderBlush1}
convert_color 238 224 229  {LavenderBlush2}
convert_color 205 193 197  {LavenderBlush3}
convert_color 139 131 134  {LavenderBlush4}
convert_color 255 228 225  {MistyRose1}
convert_color 238 213 210  {MistyRose2}
convert_color 205 183 181  {MistyRose3}
convert_color 139 125 123  {MistyRose4}
convert_color 240 255 255  {azure1}
convert_color 224 238 238  {azure2}
convert_color 193 205 205  {azure3}
convert_color 131 139 139  {azure4}
convert_color 131 111 255  {SlateBlue1}
convert_color 122 103 238  {SlateBlue2}
convert_color 105  89 205  {SlateBlue3}
convert_color  71  60 139  {SlateBlue4}
convert_color  72 118 255  {RoyalBlue1}
convert_color  67 110 238  {RoyalBlue2}
convert_color  58  95 205  {RoyalBlue3}
convert_color  39  64 139  {RoyalBlue4}
convert_color   0   0 255  {blue1}
convert_color   0   0 238  {blue2}
convert_color   0   0 205  {blue3}
convert_color   0   0 139  {blue4}
convert_color  30 144 255  {DodgerBlue1}
convert_color  28 134 238  {DodgerBlue2}
convert_color  24 116 205  {DodgerBlue3}
convert_color  16  78 139  {DodgerBlue4}
convert_color  99 184 255  {SteelBlue1}
convert_color  92 172 238  {SteelBlue2}
convert_color  79 148 205  {SteelBlue3}
convert_color  54 100 139  {SteelBlue4}
convert_color   0 191 255  {DeepSkyBlue1}
convert_color   0 178 238  {DeepSkyBlue2}
convert_color   0 154 205  {DeepSkyBlue3}
convert_color   0 104 139  {DeepSkyBlue4}
convert_color 135 206 255  {SkyBlue1}
convert_color 126 192 238  {SkyBlue2}
convert_color 108 166 205  {SkyBlue3}
convert_color  74 112 139  {SkyBlue4}
convert_color 176 226 255  {LightSkyBlue1}
convert_color 164 211 238  {LightSkyBlue2}
convert_color 141 182 205  {LightSkyBlue3}
convert_color  96 123 139  {LightSkyBlue4}
convert_color 198 226 255  {SlateGray1}
convert_color 185 211 238  {SlateGray2}
convert_color 159 182 205  {SlateGray3}
convert_color 108 123 139  {SlateGray4}
convert_color 202 225 255  {LightSteelBlue1}
convert_color 188 210 238  {LightSteelBlue2}
convert_color 162 181 205  {LightSteelBlue3}
convert_color 110 123 139  {LightSteelBlue4}
convert_color 191 239 255  {LightBlue1}
convert_color 178 223 238  {LightBlue2}
convert_color 154 192 205  {LightBlue3}
convert_color 104 131 139  {LightBlue4}
convert_color 224 255 255  {LightCyan1}
convert_color 209 238 238  {LightCyan2}
convert_color 180 205 205  {LightCyan3}
convert_color 122 139 139  {LightCyan4}
convert_color 187 255 255  {PaleTurquoise1}
convert_color 174 238 238  {PaleTurquoise2}
convert_color 150 205 205  {PaleTurquoise3}
convert_color 102 139 139  {PaleTurquoise4}
convert_color 152 245 255  {CadetBlue1}
convert_color 142 229 238  {CadetBlue2}
convert_color 122 197 205  {CadetBlue3}
convert_color  83 134 139  {CadetBlue4}
convert_color   0 245 255  {turquoise1}
convert_color   0 229 238  {turquoise2}
convert_color   0 197 205  {turquoise3}
convert_color   0 134 139  {turquoise4}
convert_color   0 255 255  {cyan1}
convert_color   0 238 238  {cyan2}
convert_color   0 205 205  {cyan3}
convert_color   0 139 139  {cyan4}
convert_color 151 255 255  {DarkSlateGray1}
convert_color 141 238 238  {DarkSlateGray2}
convert_color 121 205 205  {DarkSlateGray3}
convert_color  82 139 139  {DarkSlateGray4}
convert_color 127 255 212  {aquamarine1}
convert_color 118 238 198  {aquamarine2}
convert_color 102 205 170  {aquamarine3}
convert_color  69 139 116  {aquamarine4}
convert_color 193 255 193  {DarkSeaGreen1}
convert_color 180 238 180  {DarkSeaGreen2}
convert_color 155 205 155  {DarkSeaGreen3}
convert_color 105 139 105  {DarkSeaGreen4}
convert_color  84 255 159  {SeaGreen1}
convert_color  78 238 148  {SeaGreen2}
convert_color  67 205 128  {SeaGreen3}
convert_color  46 139  87  {SeaGreen4}
convert_color 154 255 154  {PaleGreen1}
convert_color 144 238 144  {PaleGreen2}
convert_color 124 205 124  {PaleGreen3}
convert_color  84 139  84  {PaleGreen4}
convert_color   0 255 127  {SpringGreen1}
convert_color   0 238 118  {SpringGreen2}
convert_color   0 205 102  {SpringGreen3}
convert_color   0 139  69  {SpringGreen4}
convert_color   0 255   0  {green1}
convert_color   0 238   0  {green2}
convert_color   0 205   0  {green3}
convert_color   0 139   0  {green4}
convert_color 127 255   0  {chartreuse1}
convert_color 118 238   0  {chartreuse2}
convert_color 102 205   0  {chartreuse3}
convert_color  69 139   0  {chartreuse4}
convert_color 192 255  62  {OliveDrab1}
convert_color 179 238  58  {OliveDrab2}
convert_color 154 205  50  {OliveDrab3}
convert_color 105 139  34  {OliveDrab4}
convert_color 202 255 112  {DarkOliveGreen1}
convert_color 188 238 104  {DarkOliveGreen2}
convert_color 162 205  90  {DarkOliveGreen3}
convert_color 110 139  61  {DarkOliveGreen4}
convert_color 255 246 143  {khaki1}
convert_color 238 230 133  {khaki2}
convert_color 205 198 115  {khaki3}
convert_color 139 134  78  {khaki4}
convert_color 255 236 139  {LightGoldenrod1}
convert_color 238 220 130  {LightGoldenrod2}
convert_color 205 190 112  {LightGoldenrod3}
convert_color 139 129  76  {LightGoldenrod4}
convert_color 255 255 224  {LightYellow1}
convert_color 238 238 209  {LightYellow2}
convert_color 205 205 180  {LightYellow3}
convert_color 139 139 122  {LightYellow4}
convert_color 255 255   0  {yellow1}
convert_color 238 238   0  {yellow2}
convert_color 205 205   0  {yellow3}
convert_color 139 139   0  {yellow4}
convert_color 255 215   0  {gold1}
convert_color 238 201   0  {gold2}
convert_color 205 173   0  {gold3}
convert_color 139 117   0  {gold4}
convert_color 255 193  37  {goldenrod1}
convert_color 238 180  34  {goldenrod2}
convert_color 205 155  29  {goldenrod3}
convert_color 139 105  20  {goldenrod4}
convert_color 255 185  15  {DarkGoldenrod1}
convert_color 238 173  14  {DarkGoldenrod2}
convert_color 205 149  12  {DarkGoldenrod3}
convert_color 139 101   8  {DarkGoldenrod4}
convert_color 255 193 193  {RosyBrown1}
convert_color 238 180 180  {RosyBrown2}
convert_color 205 155 155  {RosyBrown3}
convert_color 139 105 105  {RosyBrown4}
convert_color 255 106 106  {IndianRed1}
convert_color 238  99  99  {IndianRed2}
convert_color 205  85  85  {IndianRed3}
convert_color 139  58  58  {IndianRed4}
convert_color 255 130  71  {sienna1}
convert_color 238 121  66  {sienna2}
convert_color 205 104  57  {sienna3}
convert_color 139  71  38  {sienna4}
convert_color 255 211 155  {burlywood1}
convert_color 238 197 145  {burlywood2}
convert_color 205 170 125  {burlywood3}
convert_color 139 115  85  {burlywood4}
convert_color 255 231 186  {wheat1}
convert_color 238 216 174  {wheat2}
convert_color 205 186 150  {wheat3}
convert_color 139 126 102  {wheat4}
convert_color 255 165  79  {tan1}
convert_color 238 154  73  {tan2}
convert_color 205 133  63  {tan3}
convert_color 139  90  43  {tan4}
convert_color 255 127  36  {chocolate1}
convert_color 238 118  33  {chocolate2}
convert_color 205 102  29  {chocolate3}
convert_color 139  69  19  {chocolate4}
convert_color 255  48  48  {firebrick1}
convert_color 238  44  44  {firebrick2}
convert_color 205  38  38  {firebrick3}
convert_color 139  26  26  {firebrick4}
convert_color 255  64  64  {brown1}
convert_color 238  59  59  {brown2}
convert_color 205  51  51  {brown3}
convert_color 139  35  35  {brown4}
convert_color 255 140 105  {salmon1}
convert_color 238 130  98  {salmon2}
convert_color 205 112  84  {salmon3}
convert_color 139  76  57  {salmon4}
convert_color 255 160 122  {LightSalmon1}
convert_color 238 149 114  {LightSalmon2}
convert_color 205 129  98  {LightSalmon3}
convert_color 139  87  66  {LightSalmon4}
convert_color 255 165   0  {orange1}
convert_color 238 154   0  {orange2}
convert_color 205 133   0  {orange3}
convert_color 139  90   0  {orange4}
convert_color 255 127   0  {DarkOrange1}
convert_color 238 118   0  {DarkOrange2}
convert_color 205 102   0  {DarkOrange3}
convert_color 139  69   0  {DarkOrange4}
convert_color 255 114  86  {coral1}
convert_color 238 106  80  {coral2}
convert_color 205  91  69  {coral3}
convert_color 139  62  47  {coral4}
convert_color 255  99  71  {tomato1}
convert_color 238  92  66  {tomato2}
convert_color 205  79  57  {tomato3}
convert_color 139  54  38  {tomato4}
convert_color 255  69   0  {OrangeRed1}
convert_color 238  64   0  {OrangeRed2}
convert_color 205  55   0  {OrangeRed3}
convert_color 139  37   0  {OrangeRed4}
convert_color 255   0   0  {red1}
convert_color 238   0   0  {red2}
convert_color 205   0   0  {red3}
convert_color 139   0   0  {red4}
convert_color 215   7  81  {DebianRed}
convert_color 255  20 147  {DeepPink1}
convert_color 238  18 137  {DeepPink2}
convert_color 205  16 118  {DeepPink3}
convert_color 139  10  80  {DeepPink4}
convert_color 255 110 180  {HotPink1}
convert_color 238 106 167  {HotPink2}
convert_color 205  96 144  {HotPink3}
convert_color 139  58  98  {HotPink4}
convert_color 255 181 197  {pink1}
convert_color 238 169 184  {pink2}
convert_color 205 145 158  {pink3}
convert_color 139  99 108  {pink4}
convert_color 255 174 185  {LightPink1}
convert_color 238 162 173  {LightPink2}
convert_color 205 140 149  {LightPink3}
convert_color 139  95 101  {LightPink4}
convert_color 255 130 171  {PaleVioletRed1}
convert_color 238 121 159  {PaleVioletRed2}
convert_color 205 104 137  {PaleVioletRed3}
convert_color 139  71  93  {PaleVioletRed4}
convert_color 255  52 179  {maroon1}
convert_color 238  48 167  {maroon2}
convert_color 205  41 144  {maroon3}
convert_color 139  28  98  {maroon4}
convert_color 255  62 150  {VioletRed1}
convert_color 238  58 140  {VioletRed2}
convert_color 205  50 120  {VioletRed3}
convert_color 139  34  82  {VioletRed4}
convert_color 255   0 255  {magenta1}
convert_color 238   0 238  {magenta2}
convert_color 205   0 205  {magenta3}
convert_color 139   0 139  {magenta4}
convert_color 255 131 250  {orchid1}
convert_color 238 122 233  {orchid2}
convert_color 205 105 201  {orchid3}
convert_color 139  71 137  {orchid4}
convert_color 255 187 255  {plum1}
convert_color 238 174 238  {plum2}
convert_color 205 150 205  {plum3}
convert_color 139 102 139  {plum4}
convert_color 224 102 255  {MediumOrchid1}
convert_color 209  95 238  {MediumOrchid2}
convert_color 180  82 205  {MediumOrchid3}
convert_color 122  55 139  {MediumOrchid4}
convert_color 191  62 255  {DarkOrchid1}
convert_color 178  58 238  {DarkOrchid2}
convert_color 154  50 205  {DarkOrchid3}
convert_color 104  34 139  {DarkOrchid4}
convert_color 155  48 255  {purple1}
convert_color 145  44 238  {purple2}
convert_color 125  38 205  {purple3}
convert_color  85  26 139  {purple4}
convert_color 171 130 255  {MediumPurple1}
convert_color 159 121 238  {MediumPurple2}
convert_color 137 104 205  {MediumPurple3}
convert_color  93  71 139  {MediumPurple4}
convert_color 255 225 255  {thistle1}
convert_color 238 210 238  {thistle2}
convert_color 205 181 205  {thistle3}
convert_color 139 123 139  {thistle4}
convert_color   0   0   0  {gray0}
convert_color   0   0   0  {grey0}
convert_color   3   3   3  {gray1}
convert_color   3   3   3  {grey1}
convert_color   5   5   5  {gray2}
convert_color   5   5   5  {grey2}
convert_color   8   8   8  {gray3}
convert_color   8   8   8  {grey3}
convert_color  10  10  10  {gray4}
convert_color  10  10  10  {grey4}
convert_color  13  13  13  {gray5}
convert_color  13  13  13  {grey5}
convert_color  15  15  15  {gray6}
convert_color  15  15  15  {grey6}
convert_color  18  18  18  {gray7}
convert_color  18  18  18  {grey7}
convert_color  20  20  20  {gray8}
convert_color  20  20  20  {grey8}
convert_color  23  23  23  {gray9}
convert_color  23  23  23  {grey9}
convert_color  26  26  26  {gray10}
convert_color  26  26  26  {grey10}
convert_color  28  28  28  {gray11}
convert_color  28  28  28  {grey11}
convert_color  31  31  31  {gray12}
convert_color  31  31  31  {grey12}
convert_color  33  33  33  {gray13}
convert_color  33  33  33  {grey13}
convert_color  36  36  36  {gray14}
convert_color  36  36  36  {grey14}
convert_color  38  38  38  {gray15}
convert_color  38  38  38  {grey15}
convert_color  41  41  41  {gray16}
convert_color  41  41  41  {grey16}
convert_color  43  43  43  {gray17}
convert_color  43  43  43  {grey17}
convert_color  46  46  46  {gray18}
convert_color  46  46  46  {grey18}
convert_color  48  48  48  {gray19}
convert_color  48  48  48  {grey19}
convert_color  51  51  51  {gray20}
convert_color  51  51  51  {grey20}
convert_color  54  54  54  {gray21}
convert_color  54  54  54  {grey21}
convert_color  56  56  56  {gray22}
convert_color  56  56  56  {grey22}
convert_color  59  59  59  {gray23}
convert_color  59  59  59  {grey23}
convert_color  61  61  61  {gray24}
convert_color  61  61  61  {grey24}
convert_color  64  64  64  {gray25}
convert_color  64  64  64  {grey25}
convert_color  66  66  66  {gray26}
convert_color  66  66  66  {grey26}
convert_color  69  69  69  {gray27}
convert_color  69  69  69  {grey27}
convert_color  71  71  71  {gray28}
convert_color  71  71  71  {grey28}
convert_color  74  74  74  {gray29}
convert_color  74  74  74  {grey29}
convert_color  77  77  77  {gray30}
convert_color  77  77  77  {grey30}
convert_color  79  79  79  {gray31}
convert_color  79  79  79  {grey31}
convert_color  82  82  82  {gray32}
convert_color  82  82  82  {grey32}
convert_color  84  84  84  {gray33}
convert_color  84  84  84  {grey33}
convert_color  87  87  87  {gray34}
convert_color  87  87  87  {grey34}
convert_color  89  89  89  {gray35}
convert_color  89  89  89  {grey35}
convert_color  92  92  92  {gray36}
convert_color  92  92  92  {grey36}
convert_color  94  94  94  {gray37}
convert_color  94  94  94  {grey37}
convert_color  97  97  97  {gray38}
convert_color  97  97  97  {grey38}
convert_color  99  99  99  {gray39}
convert_color  99  99  99  {grey39}
convert_color 102 102 102  {gray40}
convert_color 102 102 102  {grey40}
convert_color 105 105 105  {gray41}
convert_color 105 105 105  {grey41}
convert_color 107 107 107  {gray42}
convert_color 107 107 107  {grey42}
convert_color 110 110 110  {gray43}
convert_color 110 110 110  {grey43}
convert_color 112 112 112  {gray44}
convert_color 112 112 112  {grey44}
convert_color 115 115 115  {gray45}
convert_color 115 115 115  {grey45}
convert_color 117 117 117  {gray46}
convert_color 117 117 117  {grey46}
convert_color 120 120 120  {gray47}
convert_color 120 120 120  {grey47}
convert_color 122 122 122  {gray48}
convert_color 122 122 122  {grey48}
convert_color 125 125 125  {gray49}
convert_color 125 125 125  {grey49}
convert_color 127 127 127  {gray50}
convert_color 127 127 127  {grey50}
convert_color 130 130 130  {gray51}
convert_color 130 130 130  {grey51}
convert_color 133 133 133  {gray52}
convert_color 133 133 133  {grey52}
convert_color 135 135 135  {gray53}
convert_color 135 135 135  {grey53}
convert_color 138 138 138  {gray54}
convert_color 138 138 138  {grey54}
convert_color 140 140 140  {gray55}
convert_color 140 140 140  {grey55}
convert_color 143 143 143  {gray56}
convert_color 143 143 143  {grey56}
convert_color 145 145 145  {gray57}
convert_color 145 145 145  {grey57}
convert_color 148 148 148  {gray58}
convert_color 148 148 148  {grey58}
convert_color 150 150 150  {gray59}
convert_color 150 150 150  {grey59}
convert_color 153 153 153  {gray60}
convert_color 153 153 153  {grey60}
convert_color 156 156 156  {gray61}
convert_color 156 156 156  {grey61}
convert_color 158 158 158  {gray62}
convert_color 158 158 158  {grey62}
convert_color 161 161 161  {gray63}
convert_color 161 161 161  {grey63}
convert_color 163 163 163  {gray64}
convert_color 163 163 163  {grey64}
convert_color 166 166 166  {gray65}
convert_color 166 166 166  {grey65}
convert_color 168 168 168  {gray66}
convert_color 168 168 168  {grey66}
convert_color 171 171 171  {gray67}
convert_color 171 171 171  {grey67}
convert_color 173 173 173  {gray68}
convert_color 173 173 173  {grey68}
convert_color 176 176 176  {gray69}
convert_color 176 176 176  {grey69}
convert_color 179 179 179  {gray70}
convert_color 179 179 179  {grey70}
convert_color 181 181 181  {gray71}
convert_color 181 181 181  {grey71}
convert_color 184 184 184  {gray72}
convert_color 184 184 184  {grey72}
convert_color 186 186 186  {gray73}
convert_color 186 186 186  {grey73}
convert_color 189 189 189  {gray74}
convert_color 189 189 189  {grey74}
convert_color 191 191 191  {gray75}
convert_color 191 191 191  {grey75}
convert_color 194 194 194  {gray76}
convert_color 194 194 194  {grey76}
convert_color 196 196 196  {gray77}
convert_color 196 196 196  {grey77}
convert_color 199 199 199  {gray78}
convert_color 199 199 199  {grey78}
convert_color 201 201 201  {gray79}
convert_color 201 201 201  {grey79}
convert_color 204 204 204  {gray80}
convert_color 204 204 204  {grey80}
convert_color 207 207 207  {gray81}
convert_color 207 207 207  {grey81}
convert_color 209 209 209  {gray82}
convert_color 209 209 209  {grey82}
convert_color 212 212 212  {gray83}
convert_color 212 212 212  {grey83}
convert_color 214 214 214  {gray84}
convert_color 214 214 214  {grey84}
convert_color 217 217 217  {gray85}
convert_color 217 217 217  {grey85}
convert_color 219 219 219  {gray86}
convert_color 219 219 219  {grey86}
convert_color 222 222 222  {gray87}
convert_color 222 222 222  {grey87}
convert_color 224 224 224  {gray88}
convert_color 224 224 224  {grey88}
convert_color 227 227 227  {gray89}
convert_color 227 227 227  {grey89}
convert_color 229 229 229  {gray90}
convert_color 229 229 229  {grey90}
convert_color 232 232 232  {gray91}
convert_color 232 232 232  {grey91}
convert_color 235 235 235  {gray92}
convert_color 235 235 235  {grey92}
convert_color 237 237 237  {gray93}
convert_color 237 237 237  {grey93}
convert_color 240 240 240  {gray94}
convert_color 240 240 240  {grey94}
convert_color 242 242 242  {gray95}
convert_color 242 242 242  {grey95}
convert_color 245 245 245  {gray96}
convert_color 245 245 245  {grey96}
convert_color 247 247 247  {gray97}
convert_color 247 247 247  {grey97}
convert_color 250 250 250  {gray98}
convert_color 250 250 250  {grey98}
convert_color 252 252 252  {gray99}
convert_color 252 252 252  {grey99}
convert_color 255 255 255  {gray100}
convert_color 255 255 255  {grey100}
convert_color 169 169 169  {dark grey}
convert_color 169 169 169  {DarkGrey}
convert_color 169 169 169  {dark gray}
convert_color 169 169 169  {DarkGray}
convert_color 0     0 139  {dark blue}
convert_color 0     0 139  {DarkBlue}
convert_color 0   139 139  {dark cyan}
convert_color 0   139 139  {DarkCyan}
convert_color 139   0 139  {dark magenta}
convert_color 139   0 139  {DarkMagenta}
convert_color 139   0   0  {dark red}
convert_color 139   0   0  {DarkRed}
convert_color 144 238 144  {light green}
convert_color 144 238 144  {LightGreen}

