#ifndef __MC_MATH_H
#define __MC_MATH_H

#include <stdint.h>

static const int16_t Mc_atan2_s4d5poly_sectortable[8] = {0x0000, 0x4001, 0x0001, 0xc000, 0x8001, 0x4000, 0x8000, 0xc001};
static const int16_t Mc_atan2_s4d5poly_coeffs_531[3] = {26048, -23954, 20755};
inline static int16_t Mc_atan2_s4d5poly(int16_t y, int16_t x)
{

    volatile uint16_t sectorbits;
    volatile uint16_t rho;
    uint16_t offset;
    __asm__(
        "    clr       %0\n"
        // get the sign bit of xy and put it in bit 15 of sectorbits

        // If y < 0, complement it (overflow-free abs value)
        // and shift in a 0 into bit 15 of sectorbits, else
        // shift in a 1 into bit 15 of sectorbits.
        "    btst.c    %[x], #15\n"
        "    btsc      %[x], #15\n"
        "    com       %[x], %[x]\n"
        "    rlc       %0, %0\n"

        "    btst.c    %[y], #15\n"
        "    btsc      %[y], #15\n"
        "    com       %[y], %[y]\n"
        "    rlc       %0, %0\n"

        // If x < y, then swap x and y, and shift in a 1
        // else shift in a 1
        "    cp        %[y], %[x]\n"
        "    rlc       %0, %0\n"
        "    cpsgt     %[x], %[y]\n"
        "    exch      %[x], %[y]\n"
        // At this point, x >= y and both are >= 0.
        // Also the sectorbits have a value of 0-7.

    : "=&r"(sectorbits), [x] "+r"(x), [y] "+r"(y) :  );

    __asm__(
        // Now compute (y/2)/x in Q16
        "    asr       %[y], %[y]\n"
        "    repeat    #17\n"
        "    divf      %[y], %[x]\n"
        "    sl        W0, %[rho]\n"
    : [rho] "=r"(rho) : [x] "e"(x) , [y] "e"(y) : "w0", "w1" );
    // x and y must not be in the div registers (W0 and W1)
    offset = Mc_atan2_s4d5poly_sectortable[sectorbits];
        // At this point, x and y are no longer necessary, and
        // "offset" contains information about which sector
        // we're working in. Bits 15 and 14 contain an offset, bit 0 contains
        // the sign bit s that should be applied to rho:
        // s = 1 if rho is really negative (needs sign correction),
        // s = 0 if rho is really positive (doesn't need sign correction)
        //
        // 0x0001 for points near the positive x-axis, y<0   (sector 7)
        // 0x0000 for points near the positive x-axis, y>0   (sector 0)
        // 0x4001 for points near the positive y-axis, x>0   (sector 1)
        // 0x4000 for points near the positive y-axis, x<0   (sector 2)
        // 0x8001 for points near the negative x-axis, y>0   (sector 3)
        // 0x8000 for points near the negative x-axis, y<0   (sector 4)
        // 0xc001 for points near the negative y-axis, x<0   (sector 5)
        // 0xc000 for points near the negative y-axis, x>0   (sector 6)
    // Now we have a value rho between 0 and +0.5 Q16 (unsigned) inclusive,
    // which maps to y/x.
    // for sectors 7 and 0 (x>0, |x| > |y|), and appropriate values of rho
    // for other sectors, with an end offset that can be added in at the end
    // to provide correct angle for all sectors. In sectors 7 and 0,
    // atan2(y,x) = atan(rho*2) in fixedpoint angles (0x2000 = pi/4, -0x2000 = -pi/4)
    // so in Q15 math, 1.0 = pi.

    // degree 3 Chebyshev approximation for arctan(x) between x = -1 and x = +1.0
    // is -0.48261 * x**3 + 0.61788 * x
    // in Q15, the coeffs are k3 = -15814 for x**3 and k1 = 20247 for x
    // Using Horner's rule, this works out to ((k3*x)*x + k1)*x + offset
    // k3*x*x (Q16) is between -7907 and 0, so ((k3*x)*x + k1) is a valid int16_t

    // degree 5 Chebyshev approximation for arctan(x) between x = -1 and x = +1.0
    // is 0.79492 * x**5 - 0.73101 * x**3 + 0.63341 * x
    // in Q15, the coeffs are k5 = 26048, k3 = -23954, k1 = 20755
    // Using Horner's rule, this works out to (((k5*u) + k3)*u + k1)*x + offset
    // where u = x*x

    const int16_t *pk = Mc_atan2_s4d5poly_coeffs_531;
    x = __builtin_muluu(rho, rho) >> 16;
    y = *pk++;
    y = __builtin_mulss(x, y) >> 16;
    y += *pk++;
    y = __builtin_mulss(x, y) >> 16;
    y += *pk;
    y = __builtin_mulsu(y, rho) >> 16;

    // Finally, grab the sign bit, apply to the polynomial result,
    // and add the offset. (The offset has a 1 count error from storing the
    // sign bit, but that's ok.)
    //
    volatile int16_t angle;
    __asm__(
        "    add       %[ofs],%[y], %[angle]\n"
        "    btsc      %[ofs], #0\n"
        "    sub       %[ofs],%[y],%[angle]\n"
    : [ofs] "+r"(offset), [angle] "=&r"(angle) : [y] "r"(y));
    return angle;
}

inline static int16_t Mc_min3(const int16_t px[3])
{
    int16_t out = *px++;
    int16_t b = *px++;
    int16_t c = *px++;
    __asm__(
        "   cpsgt  %[b],   %[out]\n"
        "   exch   %[b],   %[out]\n"
        "   cpsgt  %[c],   %[out]\n"
        "   exch   %[c],   %[out]\n"
    : [out] "+r"(out) : [b] "r"(b), [c]"r"(c));
    return out;
}

inline static int16_t Mc_max3(const int16_t px[3])
{
    int16_t out = *px++;
    int16_t b = *px++;
    int16_t c = *px++;

    __asm__(
        "   cpslt  %[b],   %[out]\n"
        "   exch   %[b],   %[out]\n"
        "   cpslt  %[c],   %[out]\n"
        "   exch   %[c],   %[out]\n"
    : [out] "+r"(out) : [b] "r"(b), [c]"r"(c));
    return out;
}

inline static int16_t Mc_minmaxmid3(const int16_t px[3]) {
    /* Compute (min(x)+max(x))/2 where x is an array of 3 int16_t values.
     */
    int16_t result, x0, x1, x2;
    x0 = *px++;
    x1 = *px++;
    x2 = *px++;
    
    __asm__(// order x0, x1, x2
            "   cpslt   %1, %2\n"
            "   exch    %1, %2\n"
            "   cpslt   %1, %3\n"
            "   exch    %1, %3\n"
            "   cpslt   %2, %3\n"
            "   exch    %2, %3\n"
            // now take half the sum of the minimum and maximum
            "   add     %1, %3, %0\n"
            "   btss    SR, #2\n"   // skip if OV is set (SR<2>)
            "   btst.c  %0, #15\n"  // if OV is clear, copy msb of subtraction into C
            "   rrc     %0,%0"      // rotate right and shift in the carry
    : "=r"(result) : "r"(x0), "r"(x1), "r"(x2) );
    return result;
}


#endif // __MC_MATH_H
