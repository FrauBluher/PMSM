/* Include files */

#include <stddef.h>
#include "blas.h"
#include "FOCsim_sfun.h"
#include "c2_FOCsim.h"
#define CHARTINSTANCE_CHARTNUMBER      (chartInstance->chartNumber)
#define CHARTINSTANCE_INSTANCENUMBER   (chartInstance->instanceNumber)
#include "FOCsim_sfun_debug_macros.h"
#define _SF_MEX_LISTEN_FOR_CTRL_C(S)   sf_mex_listen_for_ctrl_c(sfGlobalDebugInstanceStruct,S);

/* Type Definitions */

/* Named Constants */
#define CALL_EVENT                     (-1)

/* Variable Declarations */

/* Variable Definitions */
static real_T _sfTime_;
static const char * c2_debug_family_names[15] = { "PWM", "Ta", "T1", "T2", "Tc",
  "Tb", "nargin", "nargout", "Va", "Vb", "Vc", "PWM1", "PWM2", "PWM3", "sector"
};

/* Function Declarations */
static void initialize_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void initialize_params_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void enable_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void disable_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void c2_update_debugger_state_c2_FOCsim(SFc2_FOCsimInstanceStruct
  *chartInstance);
static const mxArray *get_sim_state_c2_FOCsim(SFc2_FOCsimInstanceStruct
  *chartInstance);
static void set_sim_state_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_st);
static void finalize_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void sf_gateway_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void c2_chartstep_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void initSimStructsc2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber, uint32_T c2_instanceNumber);
static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData);
static real32_T c2_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_sector, const char_T *c2_identifier);
static real32_T c2_b_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static real_T c2_c_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static void c2_info_helper(const mxArray **c2_info);
static const mxArray *c2_emlrt_marshallOut(const char * c2_u);
static const mxArray *c2_b_emlrt_marshallOut(const uint32_T c2_u);
static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData);
static int32_T c2_d_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData);
static uint8_T c2_e_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_b_is_active_c2_FOCsim, const char_T *c2_identifier);
static uint8_T c2_f_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId);
static void init_dsm_address_info(SFc2_FOCsimInstanceStruct *chartInstance);

/* Function Definitions */
static void initialize_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  chartInstance->c2_sfEvent = CALL_EVENT;
  _sfTime_ = sf_get_time(chartInstance->S);
  chartInstance->c2_is_active_c2_FOCsim = 0U;
}

static void initialize_params_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void enable_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void disable_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void c2_update_debugger_state_c2_FOCsim(SFc2_FOCsimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *get_sim_state_c2_FOCsim(SFc2_FOCsimInstanceStruct
  *chartInstance)
{
  const mxArray *c2_st;
  const mxArray *c2_y = NULL;
  real32_T c2_hoistedGlobal;
  real32_T c2_u;
  const mxArray *c2_b_y = NULL;
  real32_T c2_b_hoistedGlobal;
  real32_T c2_b_u;
  const mxArray *c2_c_y = NULL;
  real32_T c2_c_hoistedGlobal;
  real32_T c2_c_u;
  const mxArray *c2_d_y = NULL;
  real32_T c2_d_hoistedGlobal;
  real32_T c2_d_u;
  const mxArray *c2_e_y = NULL;
  uint8_T c2_e_hoistedGlobal;
  uint8_T c2_e_u;
  const mxArray *c2_f_y = NULL;
  real32_T *c2_PWM1;
  real32_T *c2_PWM2;
  real32_T *c2_PWM3;
  real32_T *c2_sector;
  c2_sector = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c2_PWM3 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c2_PWM2 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_PWM1 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c2_st = NULL;
  c2_st = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_createcellmatrix(5, 1), false);
  c2_hoistedGlobal = *c2_PWM1;
  c2_u = c2_hoistedGlobal;
  c2_b_y = NULL;
  sf_mex_assign(&c2_b_y, sf_mex_create("y", &c2_u, 1, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 0, c2_b_y);
  c2_b_hoistedGlobal = *c2_PWM2;
  c2_b_u = c2_b_hoistedGlobal;
  c2_c_y = NULL;
  sf_mex_assign(&c2_c_y, sf_mex_create("y", &c2_b_u, 1, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 1, c2_c_y);
  c2_c_hoistedGlobal = *c2_PWM3;
  c2_c_u = c2_c_hoistedGlobal;
  c2_d_y = NULL;
  sf_mex_assign(&c2_d_y, sf_mex_create("y", &c2_c_u, 1, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 2, c2_d_y);
  c2_d_hoistedGlobal = *c2_sector;
  c2_d_u = c2_d_hoistedGlobal;
  c2_e_y = NULL;
  sf_mex_assign(&c2_e_y, sf_mex_create("y", &c2_d_u, 1, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 3, c2_e_y);
  c2_e_hoistedGlobal = chartInstance->c2_is_active_c2_FOCsim;
  c2_e_u = c2_e_hoistedGlobal;
  c2_f_y = NULL;
  sf_mex_assign(&c2_f_y, sf_mex_create("y", &c2_e_u, 3, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c2_y, 4, c2_f_y);
  sf_mex_assign(&c2_st, c2_y, false);
  return c2_st;
}

static void set_sim_state_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_st)
{
  const mxArray *c2_u;
  real32_T *c2_PWM1;
  real32_T *c2_PWM2;
  real32_T *c2_PWM3;
  real32_T *c2_sector;
  c2_sector = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c2_PWM3 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c2_PWM2 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_PWM1 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c2_doneDoubleBufferReInit = true;
  c2_u = sf_mex_dup(c2_st);
  *c2_PWM1 = c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u,
    0)), "PWM1");
  *c2_PWM2 = c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u,
    1)), "PWM2");
  *c2_PWM3 = c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u,
    2)), "PWM3");
  *c2_sector = c2_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c2_u,
    3)), "sector");
  chartInstance->c2_is_active_c2_FOCsim = c2_e_emlrt_marshallIn(chartInstance,
    sf_mex_dup(sf_mex_getcell(c2_u, 4)), "is_active_c2_FOCsim");
  sf_mex_destroy(&c2_u);
  c2_update_debugger_state_c2_FOCsim(chartInstance);
  sf_mex_destroy(&c2_st);
}

static void finalize_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void sf_gateway_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  real32_T *c2_PWM1;
  real32_T *c2_Va;
  real32_T *c2_PWM2;
  real32_T *c2_PWM3;
  real32_T *c2_sector;
  real32_T *c2_Vb;
  real32_T *c2_Vc;
  c2_Vc = (real32_T *)ssGetInputPortSignal(chartInstance->S, 2);
  c2_Vb = (real32_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c2_sector = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c2_PWM3 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c2_PWM2 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_Va = (real32_T *)ssGetInputPortSignal(chartInstance->S, 0);
  c2_PWM1 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_SYMBOL_SCOPE_PUSH(0U, 0U);
  _sfTime_ = sf_get_time(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 1U, chartInstance->c2_sfEvent);
  chartInstance->c2_sfEvent = CALL_EVENT;
  c2_chartstep_c2_FOCsim(chartInstance);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_FOCsimMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_PWM1, 0U);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_Va, 1U);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_PWM2, 2U);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_PWM3, 3U);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_sector, 4U);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_Vb, 5U);
  _SFD_DATA_RANGE_CHECK((real_T)*c2_Vc, 6U);
}

static void c2_chartstep_c2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  real32_T c2_hoistedGlobal;
  real32_T c2_b_hoistedGlobal;
  real32_T c2_c_hoistedGlobal;
  real32_T c2_Va;
  real32_T c2_Vb;
  real32_T c2_Vc;
  uint32_T c2_debug_family_var_map[15];
  real32_T c2_PWM;
  real32_T c2_Ta;
  real32_T c2_T1;
  real32_T c2_T2;
  real32_T c2_Tc;
  real32_T c2_Tb;
  real_T c2_nargin = 3.0;
  real_T c2_nargout = 4.0;
  real32_T c2_PWM1;
  real32_T c2_PWM2;
  real32_T c2_PWM3;
  real32_T c2_sector;
  real32_T c2_A;
  real32_T c2_x;
  real32_T c2_b_x;
  real32_T c2_c_x;
  real32_T c2_b_A;
  real32_T c2_d_x;
  real32_T c2_e_x;
  real32_T c2_f_x;
  real32_T c2_c_A;
  real32_T c2_g_x;
  real32_T c2_h_x;
  real32_T c2_i_x;
  real32_T c2_d_A;
  real32_T c2_j_x;
  real32_T c2_k_x;
  real32_T c2_l_x;
  real32_T c2_e_A;
  real32_T c2_m_x;
  real32_T c2_n_x;
  real32_T c2_o_x;
  real32_T c2_f_A;
  real32_T c2_p_x;
  real32_T c2_q_x;
  real32_T c2_r_x;
  real32_T *c2_b_sector;
  real32_T *c2_b_PWM3;
  real32_T *c2_b_PWM2;
  real32_T *c2_b_PWM1;
  real32_T *c2_b_Vc;
  real32_T *c2_b_Vb;
  real32_T *c2_b_Va;
  c2_b_Vc = (real32_T *)ssGetInputPortSignal(chartInstance->S, 2);
  c2_b_Vb = (real32_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c2_b_sector = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c2_b_PWM3 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c2_b_PWM2 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c2_b_Va = (real32_T *)ssGetInputPortSignal(chartInstance->S, 0);
  c2_b_PWM1 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 1U, chartInstance->c2_sfEvent);
  c2_hoistedGlobal = *c2_b_Va;
  c2_b_hoistedGlobal = *c2_b_Vb;
  c2_c_hoistedGlobal = *c2_b_Vc;
  c2_Va = c2_hoistedGlobal;
  c2_Vb = c2_b_hoistedGlobal;
  c2_Vc = c2_c_hoistedGlobal;
  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 15U, 15U, c2_debug_family_names,
    c2_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_PWM, 0U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Ta, 1U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_T1, 2U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_T2, 3U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Tc, 4U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_Tb, 5U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargin, 6U, c2_b_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_nargout, 7U, c2_b_sf_marshallOut,
    c2_b_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Va, 8U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Vb, 9U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c2_Vc, 10U, c2_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_PWM1, 11U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_PWM2, 12U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_PWM3, 13U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c2_sector, 14U, c2_sf_marshallOut,
    c2_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 3);
  c2_PWM = 100.0F;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 5);
  c2_Ta = 0.0F;
  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 7);
  if (CV_EML_IF(0, 1, 0, c2_Va >= 0.0F)) {
    _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 8);
    if (CV_EML_IF(0, 1, 1, c2_Vb >= 0.0F)) {
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 10);
      c2_T1 = c2_Vb;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 11);
      c2_T2 = c2_Va;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 13);
      c2_T1 *= 100.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 14);
      c2_T2 *= 100.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 15);
      c2_A = (c2_PWM - c2_T1) - c2_T2;
      c2_x = c2_A;
      c2_b_x = c2_x;
      c2_c_x = c2_b_x;
      c2_Tc = c2_c_x / 2.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 16);
      c2_Tb = c2_Ta + c2_T1;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 17);
      c2_Ta = c2_Tb + c2_T2;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 19);
      c2_PWM1 = 0.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 20);
      c2_PWM2 = c2_Tb;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 21);
      c2_PWM3 = c2_Ta;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 22);
      c2_sector = 3.0F;
    } else {
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 24);
      if (CV_EML_IF(0, 1, 2, c2_Vc >= 0.0F)) {
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 26);
        c2_T1 = c2_Va;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 27);
        c2_T2 = c2_Vc;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 29);
        c2_T1 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 30);
        c2_T2 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 31);
        c2_b_A = (c2_PWM - c2_T1) - c2_T2;
        c2_d_x = c2_b_A;
        c2_e_x = c2_d_x;
        c2_f_x = c2_e_x;
        c2_Tc = c2_f_x / 2.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 32);
        c2_Tb = c2_Ta + c2_T1;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 33);
        c2_Ta = c2_Tb + c2_T2;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 35);
        c2_PWM1 = c2_Ta;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 36);
        c2_PWM2 = 0.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 37);
        c2_PWM3 = c2_Tb;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 38);
        c2_sector = 5.0F;
      } else {
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 41);
        c2_T1 = -c2_Vb;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 42);
        c2_T2 = -c2_Vc;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 44);
        c2_T1 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 45);
        c2_T2 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 46);
        c2_c_A = (c2_PWM - c2_T1) - c2_T2;
        c2_g_x = c2_c_A;
        c2_h_x = c2_g_x;
        c2_i_x = c2_h_x;
        c2_Tc = c2_i_x / 2.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 47);
        c2_Tb = c2_Ta + c2_T1;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 48);
        c2_Ta = c2_Tb + c2_T2;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 50);
        c2_PWM1 = c2_Tb;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 51);
        c2_PWM2 = 0.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 52);
        c2_PWM3 = c2_Ta;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 53);
        c2_sector = 1.0F;
      }
    }
  } else {
    _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 57);
    if (CV_EML_IF(0, 1, 3, c2_Vb >= 0.0F)) {
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 58);
      if (CV_EML_IF(0, 1, 4, c2_Vc >= 0.0F)) {
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 60);
        c2_T1 = c2_Vc;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 61);
        c2_T2 = c2_Vb;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 63);
        c2_T1 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 64);
        c2_T2 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 65);
        c2_d_A = (c2_PWM - c2_T1) - c2_T2;
        c2_j_x = c2_d_A;
        c2_k_x = c2_j_x;
        c2_l_x = c2_k_x;
        c2_Tc = c2_l_x / 2.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 66);
        c2_Tb = c2_Ta + c2_T1;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 67);
        c2_Ta = c2_Tb + c2_T2;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 69);
        c2_PWM1 = c2_Tb;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 70);
        c2_PWM2 = c2_Ta;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 71);
        c2_PWM3 = 0.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 72);
        c2_sector = 6.0F;
      } else {
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 75);
        c2_T1 = -c2_Vc;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 76);
        c2_T2 = -c2_Va;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 78);
        c2_T1 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 79);
        c2_T2 *= 100.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 80);
        c2_e_A = (c2_PWM - c2_T1) - c2_T2;
        c2_m_x = c2_e_A;
        c2_n_x = c2_m_x;
        c2_o_x = c2_n_x;
        c2_Tc = c2_o_x / 2.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 81);
        c2_Tb = c2_Ta + c2_T1;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 82);
        c2_Ta = c2_Tb + c2_T2;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 84);
        c2_PWM1 = 0.0F;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 85);
        c2_PWM2 = c2_Ta;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 86);
        c2_PWM3 = c2_Tb;
        _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 87);
        c2_sector = 2.0F;
      }
    } else {
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 91);
      c2_T1 = -c2_Va;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 92);
      c2_T2 = -c2_Vb;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 94);
      c2_T1 *= 100.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 95);
      c2_T2 *= 100.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 96);
      c2_f_A = (c2_PWM - c2_T1) - c2_T2;
      c2_p_x = c2_f_A;
      c2_q_x = c2_p_x;
      c2_r_x = c2_q_x;
      c2_Tc = c2_r_x / 2.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 97);
      c2_Tb = c2_Ta + c2_T1;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 98);
      c2_Ta = c2_Tb + c2_T2;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 100);
      c2_PWM1 = c2_Ta;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 101);
      c2_PWM2 = c2_Tb;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 102);
      c2_PWM3 = 0.0F;
      _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, 103);
      c2_sector = 4.0F;
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c2_sfEvent, -103);
  _SFD_SYMBOL_SCOPE_POP();
  *c2_b_PWM1 = c2_PWM1;
  *c2_b_PWM2 = c2_PWM2;
  *c2_b_PWM3 = c2_PWM3;
  *c2_b_sector = c2_sector;
  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 1U, chartInstance->c2_sfEvent);
}

static void initSimStructsc2_FOCsim(SFc2_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_script_number_translation(uint32_T c2_machineNumber, uint32_T
  c2_chartNumber, uint32_T c2_instanceNumber)
{
  (void)c2_machineNumber;
  (void)c2_chartNumber;
  (void)c2_instanceNumber;
}

static const mxArray *c2_sf_marshallOut(void *chartInstanceVoid, void *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  real32_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FOCsimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(real32_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 1, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static real32_T c2_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_sector, const char_T *c2_identifier)
{
  real32_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_sector), &c2_thisId);
  sf_mex_destroy(&c2_sector);
  return c2_y;
}

static real32_T c2_b_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  real32_T c2_y;
  real32_T c2_f0;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_f0, 1, 1, 0U, 0, 0U, 0);
  c2_y = c2_f0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_sector;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real32_T c2_y;
  SFc2_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FOCsimInstanceStruct *)chartInstanceVoid;
  c2_sector = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_sector), &c2_thisId);
  sf_mex_destroy(&c2_sector);
  *(real32_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static const mxArray *c2_b_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  real_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FOCsimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(real_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static real_T c2_c_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  real_T c2_y;
  real_T c2_d0;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_d0, 1, 0, 0U, 0, 0U, 0);
  c2_y = c2_d0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_nargout;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  real_T c2_y;
  SFc2_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FOCsimInstanceStruct *)chartInstanceVoid;
  c2_nargout = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_c_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_nargout), &c2_thisId);
  sf_mex_destroy(&c2_nargout);
  *(real_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

const mxArray *sf_c2_FOCsim_get_eml_resolved_functions_info(void)
{
  const mxArray *c2_nameCaptureInfo = NULL;
  c2_nameCaptureInfo = NULL;
  sf_mex_assign(&c2_nameCaptureInfo, sf_mex_createstruct("structure", 2, 8, 1),
                false);
  c2_info_helper(&c2_nameCaptureInfo);
  sf_mex_emlrtNameCapturePostProcessR2012a(&c2_nameCaptureInfo);
  return c2_nameCaptureInfo;
}

static void c2_info_helper(const mxArray **c2_info)
{
  const mxArray *c2_rhs0 = NULL;
  const mxArray *c2_lhs0 = NULL;
  const mxArray *c2_rhs1 = NULL;
  const mxArray *c2_lhs1 = NULL;
  const mxArray *c2_rhs2 = NULL;
  const mxArray *c2_lhs2 = NULL;
  const mxArray *c2_rhs3 = NULL;
  const mxArray *c2_lhs3 = NULL;
  const mxArray *c2_rhs4 = NULL;
  const mxArray *c2_lhs4 = NULL;
  const mxArray *c2_rhs5 = NULL;
  const mxArray *c2_lhs5 = NULL;
  const mxArray *c2_rhs6 = NULL;
  const mxArray *c2_lhs6 = NULL;
  const mxArray *c2_rhs7 = NULL;
  const mxArray *c2_lhs7 = NULL;
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(""), "context", "context", 0);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("mrdivide"), "name", "name", 0);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("single"), "dominantType",
                  "dominantType", 0);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p"), "resolved",
                  "resolved", 0);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1388492496U), "fileTimeLo",
                  "fileTimeLo", 0);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 0);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1370042286U), "mFileTimeLo",
                  "mFileTimeLo", 0);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 0);
  sf_mex_assign(&c2_rhs0, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs0, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs0), "rhs", "rhs", 0);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs0), "lhs", "lhs", 0);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p"), "context",
                  "context", 1);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("coder.internal.assert"),
                  "name", "name", 1);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("char"), "dominantType",
                  "dominantType", 1);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[IXE]$matlabroot$/toolbox/shared/coder/coder/+coder/+internal/assert.m"),
                  "resolved", "resolved", 1);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1363743356U), "fileTimeLo",
                  "fileTimeLo", 1);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 1);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 1);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 1);
  sf_mex_assign(&c2_rhs1, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs1, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs1), "rhs", "rhs", 1);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs1), "lhs", "lhs", 1);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/mrdivide.p"), "context",
                  "context", 2);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("rdivide"), "name", "name", 2);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("single"), "dominantType",
                  "dominantType", 2);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m"), "resolved",
                  "resolved", 2);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1363742680U), "fileTimeLo",
                  "fileTimeLo", 2);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 2);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 2);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 2);
  sf_mex_assign(&c2_rhs2, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs2, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs2), "rhs", "rhs", 2);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs2), "lhs", "lhs", 2);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m"), "context",
                  "context", 3);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "coder.internal.isBuiltInNumeric"), "name", "name", 3);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("single"), "dominantType",
                  "dominantType", 3);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[IXE]$matlabroot$/toolbox/shared/coder/coder/+coder/+internal/isBuiltInNumeric.m"),
                  "resolved", "resolved", 3);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1363743356U), "fileTimeLo",
                  "fileTimeLo", 3);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 3);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 3);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 3);
  sf_mex_assign(&c2_rhs3, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs3, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs3), "rhs", "rhs", 3);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs3), "lhs", "lhs", 3);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m"), "context",
                  "context", 4);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "coder.internal.isBuiltInNumeric"), "name", "name", 4);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("double"), "dominantType",
                  "dominantType", 4);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[IXE]$matlabroot$/toolbox/shared/coder/coder/+coder/+internal/isBuiltInNumeric.m"),
                  "resolved", "resolved", 4);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1363743356U), "fileTimeLo",
                  "fileTimeLo", 4);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 4);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 4);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 4);
  sf_mex_assign(&c2_rhs4, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs4, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs4), "rhs", "rhs", 4);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs4), "lhs", "lhs", 4);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m"), "context",
                  "context", 5);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("eml_scalexp_compatible"),
                  "name", "name", 5);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("single"), "dominantType",
                  "dominantType", 5);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_scalexp_compatible.m"),
                  "resolved", "resolved", 5);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1286851196U), "fileTimeLo",
                  "fileTimeLo", 5);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 5);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 5);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 5);
  sf_mex_assign(&c2_rhs5, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs5, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs5), "rhs", "rhs", 5);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs5), "lhs", "lhs", 5);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/ops/rdivide.m"), "context",
                  "context", 6);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("eml_div"), "name", "name", 6);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("single"), "dominantType",
                  "dominantType", 6);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_div.m"), "resolved",
                  "resolved", 6);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1376013088U), "fileTimeLo",
                  "fileTimeLo", 6);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 6);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 6);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 6);
  sf_mex_assign(&c2_rhs6, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs6, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs6), "rhs", "rhs", 6);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs6), "lhs", "lhs", 6);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[ILXE]$matlabroot$/toolbox/eml/lib/matlab/eml/eml_div.m"), "context",
                  "context", 7);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("coder.internal.div"), "name",
                  "name", 7);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut("single"), "dominantType",
                  "dominantType", 7);
  sf_mex_addfield(*c2_info, c2_emlrt_marshallOut(
    "[IXE]$matlabroot$/toolbox/coder/coder/+coder/+internal/div.p"), "resolved",
                  "resolved", 7);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(1389340320U), "fileTimeLo",
                  "fileTimeLo", 7);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "fileTimeHi",
                  "fileTimeHi", 7);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeLo",
                  "mFileTimeLo", 7);
  sf_mex_addfield(*c2_info, c2_b_emlrt_marshallOut(0U), "mFileTimeHi",
                  "mFileTimeHi", 7);
  sf_mex_assign(&c2_rhs7, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_assign(&c2_lhs7, sf_mex_createcellmatrix(0, 1), false);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_rhs7), "rhs", "rhs", 7);
  sf_mex_addfield(*c2_info, sf_mex_duplicatearraysafe(&c2_lhs7), "lhs", "lhs", 7);
  sf_mex_destroy(&c2_rhs0);
  sf_mex_destroy(&c2_lhs0);
  sf_mex_destroy(&c2_rhs1);
  sf_mex_destroy(&c2_lhs1);
  sf_mex_destroy(&c2_rhs2);
  sf_mex_destroy(&c2_lhs2);
  sf_mex_destroy(&c2_rhs3);
  sf_mex_destroy(&c2_lhs3);
  sf_mex_destroy(&c2_rhs4);
  sf_mex_destroy(&c2_lhs4);
  sf_mex_destroy(&c2_rhs5);
  sf_mex_destroy(&c2_lhs5);
  sf_mex_destroy(&c2_rhs6);
  sf_mex_destroy(&c2_lhs6);
  sf_mex_destroy(&c2_rhs7);
  sf_mex_destroy(&c2_lhs7);
}

static const mxArray *c2_emlrt_marshallOut(const char * c2_u)
{
  const mxArray *c2_y = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", c2_u, 15, 0U, 0U, 0U, 2, 1, strlen
    (c2_u)), false);
  return c2_y;
}

static const mxArray *c2_b_emlrt_marshallOut(const uint32_T c2_u)
{
  const mxArray *c2_y = NULL;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 7, 0U, 0U, 0U, 0), false);
  return c2_y;
}

static const mxArray *c2_c_sf_marshallOut(void *chartInstanceVoid, void
  *c2_inData)
{
  const mxArray *c2_mxArrayOutData = NULL;
  int32_T c2_u;
  const mxArray *c2_y = NULL;
  SFc2_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FOCsimInstanceStruct *)chartInstanceVoid;
  c2_mxArrayOutData = NULL;
  c2_u = *(int32_T *)c2_inData;
  c2_y = NULL;
  sf_mex_assign(&c2_y, sf_mex_create("y", &c2_u, 6, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c2_mxArrayOutData, c2_y, false);
  return c2_mxArrayOutData;
}

static int32_T c2_d_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  int32_T c2_y;
  int32_T c2_i0;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_i0, 1, 6, 0U, 0, 0U, 0);
  c2_y = c2_i0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void c2_c_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c2_mxArrayInData, const char_T *c2_varName, void *c2_outData)
{
  const mxArray *c2_b_sfEvent;
  const char_T *c2_identifier;
  emlrtMsgIdentifier c2_thisId;
  int32_T c2_y;
  SFc2_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc2_FOCsimInstanceStruct *)chartInstanceVoid;
  c2_b_sfEvent = sf_mex_dup(c2_mxArrayInData);
  c2_identifier = c2_varName;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_d_emlrt_marshallIn(chartInstance, sf_mex_dup(c2_b_sfEvent),
    &c2_thisId);
  sf_mex_destroy(&c2_b_sfEvent);
  *(int32_T *)c2_outData = c2_y;
  sf_mex_destroy(&c2_mxArrayInData);
}

static uint8_T c2_e_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_b_is_active_c2_FOCsim, const char_T *c2_identifier)
{
  uint8_T c2_y;
  emlrtMsgIdentifier c2_thisId;
  c2_thisId.fIdentifier = c2_identifier;
  c2_thisId.fParent = NULL;
  c2_y = c2_f_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c2_b_is_active_c2_FOCsim), &c2_thisId);
  sf_mex_destroy(&c2_b_is_active_c2_FOCsim);
  return c2_y;
}

static uint8_T c2_f_emlrt_marshallIn(SFc2_FOCsimInstanceStruct *chartInstance,
  const mxArray *c2_u, const emlrtMsgIdentifier *c2_parentId)
{
  uint8_T c2_y;
  uint8_T c2_u0;
  (void)chartInstance;
  sf_mex_import(c2_parentId, sf_mex_dup(c2_u), &c2_u0, 1, 3, 0U, 0, 0U, 0);
  c2_y = c2_u0;
  sf_mex_destroy(&c2_u);
  return c2_y;
}

static void init_dsm_address_info(SFc2_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

/* SFunction Glue Code */
#ifdef utFree
#undef utFree
#endif

#ifdef utMalloc
#undef utMalloc
#endif

#ifdef __cplusplus

extern "C" void *utMalloc(size_t size);
extern "C" void utFree(void*);

#else

extern void *utMalloc(size_t size);
extern void utFree(void*);

#endif

void sf_c2_FOCsim_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(1613363420U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(4236464798U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(2846579398U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(3307014063U);
}

mxArray *sf_c2_FOCsim_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,5,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("jRqtGVzrOq0hsvuAq1tn9C");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,3,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,4,3,dataFields);

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,0,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,0,"type",mxType);
    }

    mxSetField(mxData,0,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,1,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,1,"type",mxType);
    }

    mxSetField(mxData,1,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,2,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,2,"type",mxType);
    }

    mxSetField(mxData,2,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,3,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(9));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c2_FOCsim_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

mxArray *sf_c2_FOCsim_updateBuildInfo_args_info(void)
{
  mxArray *mxBIArgs = mxCreateCellMatrix(1,0);
  return mxBIArgs;
}

static const mxArray *sf_get_sim_state_info_c2_FOCsim(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x5'type','srcId','name','auxInfo'{{M[1],M[5],T\"PWM1\",},{M[1],M[12],T\"PWM2\",},{M[1],M[13],T\"PWM3\",},{M[1],M[14],T\"sector\",},{M[8],M[0],T\"is_active_c2_FOCsim\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 5, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c2_FOCsim_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc2_FOCsimInstanceStruct *chartInstance;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
    chartInstance = (SFc2_FOCsimInstanceStruct *) chartInfo->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _FOCsimMachineNumber_,
           2,
           1,
           1,
           0,
           7,
           0,
           0,
           0,
           0,
           0,
           &(chartInstance->chartNumber),
           &(chartInstance->instanceNumber),
           (void *)S);

        /* Each instance must initialize ist own list of scripts */
        init_script_number_translation(_FOCsimMachineNumber_,
          chartInstance->chartNumber,chartInstance->instanceNumber);
        if (chartAlreadyPresent==0) {
          /* this is the first instance */
          sf_debug_set_chart_disable_implicit_casting
            (sfGlobalDebugInstanceStruct,_FOCsimMachineNumber_,
             chartInstance->chartNumber,1);
          sf_debug_set_chart_event_thresholds(sfGlobalDebugInstanceStruct,
            _FOCsimMachineNumber_,
            chartInstance->chartNumber,
            0,
            0,
            0);
          _SFD_SET_DATA_PROPS(0,2,0,1,"PWM1");
          _SFD_SET_DATA_PROPS(1,1,1,0,"Va");
          _SFD_SET_DATA_PROPS(2,2,0,1,"PWM2");
          _SFD_SET_DATA_PROPS(3,2,0,1,"PWM3");
          _SFD_SET_DATA_PROPS(4,2,0,1,"sector");
          _SFD_SET_DATA_PROPS(5,1,1,0,"Vb");
          _SFD_SET_DATA_PROPS(6,1,1,0,"Vc");
          _SFD_STATE_INFO(0,0,2);
          _SFD_CH_SUBSTATE_COUNT(0);
          _SFD_CH_SUBSTATE_DECOMP(0);
        }

        _SFD_CV_INIT_CHART(0,0,0,0);

        {
          _SFD_CV_INIT_STATE(0,0,0,0,0,0,NULL,NULL);
        }

        _SFD_CV_INIT_TRANS(0,0,NULL,NULL,0,NULL);

        /* Initialization of MATLAB Function Model Coverage */
        _SFD_CV_INIT_EML(0,1,1,5,0,0,0,0,0,0,0);
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,2211);
        _SFD_CV_INIT_EML_IF(0,1,0,112,124,1159,2206);
        _SFD_CV_INIT_EML_IF(0,1,1,129,141,430,1158);
        _SFD_CV_INIT_EML_IF(0,1,2,443,455,798,1150);
        _SFD_CV_INIT_EML_IF(0,1,3,1168,1180,1901,2202);
        _SFD_CV_INIT_EML_IF(0,1,4,1189,1201,1545,1896);
        _SFD_SET_DATA_COMPILED_PROPS(0,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(1,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(2,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(3,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(4,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)c2_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(5,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(6,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c2_sf_marshallOut,(MexInFcnForType)NULL);

        {
          real32_T *c2_PWM1;
          real32_T *c2_Va;
          real32_T *c2_PWM2;
          real32_T *c2_PWM3;
          real32_T *c2_sector;
          real32_T *c2_Vb;
          real32_T *c2_Vc;
          c2_Vc = (real32_T *)ssGetInputPortSignal(chartInstance->S, 2);
          c2_Vb = (real32_T *)ssGetInputPortSignal(chartInstance->S, 1);
          c2_sector = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 4);
          c2_PWM3 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 3);
          c2_PWM2 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 2);
          c2_Va = (real32_T *)ssGetInputPortSignal(chartInstance->S, 0);
          c2_PWM1 = (real32_T *)ssGetOutputPortSignal(chartInstance->S, 1);
          _SFD_SET_DATA_VALUE_PTR(0U, c2_PWM1);
          _SFD_SET_DATA_VALUE_PTR(1U, c2_Va);
          _SFD_SET_DATA_VALUE_PTR(2U, c2_PWM2);
          _SFD_SET_DATA_VALUE_PTR(3U, c2_PWM3);
          _SFD_SET_DATA_VALUE_PTR(4U, c2_sector);
          _SFD_SET_DATA_VALUE_PTR(5U, c2_Vb);
          _SFD_SET_DATA_VALUE_PTR(6U, c2_Vc);
        }
      }
    } else {
      sf_debug_reset_current_state_configuration(sfGlobalDebugInstanceStruct,
        _FOCsimMachineNumber_,chartInstance->chartNumber,
        chartInstance->instanceNumber);
    }
  }
}

static const char* sf_get_instance_specialization(void)
{
  return "6R9i6K47x1UnYCG1IYSclB";
}

static void sf_opaque_initialize_c2_FOCsim(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc2_FOCsimInstanceStruct*) chartInstanceVar)->S,
    0);
  initialize_params_c2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
  initialize_c2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c2_FOCsim(void *chartInstanceVar)
{
  enable_c2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c2_FOCsim(void *chartInstanceVar)
{
  disable_c2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c2_FOCsim(void *chartInstanceVar)
{
  sf_gateway_c2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
}

extern const mxArray* sf_internal_get_sim_state_c2_FOCsim(SimStruct* S)
{
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
  ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c2_FOCsim((SFc2_FOCsimInstanceStruct*)
    chartInfo->chartInstance);         /* raw sim ctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c2_FOCsim();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 4, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  mxDestroyArray(prhs[3]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_raw2high'.\n");
  }

  return plhs[0];
}

extern void sf_internal_set_sim_state_c2_FOCsim(SimStruct* S, const mxArray *st)
{
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
  ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[3];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxDuplicateArray(st);      /* high level simctx */
  prhs[2] = (mxArray*) sf_get_sim_state_info_c2_FOCsim();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 3, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c2_FOCsim((SFc2_FOCsimInstanceStruct*)chartInfo->chartInstance,
    mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static const mxArray* sf_opaque_get_sim_state_c2_FOCsim(SimStruct* S)
{
  return sf_internal_get_sim_state_c2_FOCsim(S);
}

static void sf_opaque_set_sim_state_c2_FOCsim(SimStruct* S, const mxArray *st)
{
  sf_internal_set_sim_state_c2_FOCsim(S, st);
}

static void sf_opaque_terminate_c2_FOCsim(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc2_FOCsimInstanceStruct*) chartInstanceVar)->S;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_FOCsim_optimization_info();
    }

    finalize_c2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
    utFree((void *)chartInstanceVar);
    if (crtInfo != NULL) {
      utFree((void *)crtInfo);
    }

    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc2_FOCsim((SFc2_FOCsimInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c2_FOCsim(SimStruct *S)
{
  int i;
  for (i=0;i<ssGetNumRunTimeParams(S);i++) {
    if (ssGetSFcnParamTunable(S,i)) {
      ssUpdateDlgParamAsRunTimeParam(S,i);
    }
  }

  if (sf_machine_global_initializer_called()) {
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
    initialize_params_c2_FOCsim((SFc2_FOCsimInstanceStruct*)
      (chartInfo->chartInstance));
  }
}

static void mdlSetWorkWidths_c2_FOCsim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_FOCsim_optimization_info();
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(sf_get_instance_specialization(),infoStruct,2);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(sf_get_instance_specialization(),
                infoStruct,2,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop
      (sf_get_instance_specialization(),infoStruct,2,
       "gatewayCannotBeInlinedMultipleTimes"));
    sf_update_buildInfo(sf_get_instance_specialization(),infoStruct,2);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,2,3);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,2,4);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=4; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 3; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,2);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(799594686U));
  ssSetChecksum1(S,(873988635U));
  ssSetChecksum2(S,(2127618204U));
  ssSetChecksum3(S,(2676549281U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c2_FOCsim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c2_FOCsim(SimStruct *S)
{
  SFc2_FOCsimInstanceStruct *chartInstance;
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)utMalloc(sizeof
    (ChartRunTimeInfo));
  chartInstance = (SFc2_FOCsimInstanceStruct *)utMalloc(sizeof
    (SFc2_FOCsimInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc2_FOCsimInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway = sf_opaque_gateway_c2_FOCsim;
  chartInstance->chartInfo.initializeChart = sf_opaque_initialize_c2_FOCsim;
  chartInstance->chartInfo.terminateChart = sf_opaque_terminate_c2_FOCsim;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c2_FOCsim;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c2_FOCsim;
  chartInstance->chartInfo.getSimState = sf_opaque_get_sim_state_c2_FOCsim;
  chartInstance->chartInfo.setSimState = sf_opaque_set_sim_state_c2_FOCsim;
  chartInstance->chartInfo.getSimStateInfo = sf_get_sim_state_info_c2_FOCsim;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c2_FOCsim;
  chartInstance->chartInfo.mdlStart = mdlStart_c2_FOCsim;
  chartInstance->chartInfo.mdlSetWorkWidths = mdlSetWorkWidths_c2_FOCsim;
  chartInstance->chartInfo.extModeExec = NULL;
  chartInstance->chartInfo.restoreLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.restoreBeforeLastMajorStepConfiguration = NULL;
  chartInstance->chartInfo.storeCurrentConfiguration = NULL;
  chartInstance->chartInfo.debugInstance = sfGlobalDebugInstanceStruct;
  chartInstance->S = S;
  crtInfo->instanceInfo = (&(chartInstance->chartInfo));
  crtInfo->isJITEnabled = false;
  ssSetUserData(S,(void *)(crtInfo));  /* register the chart instance with simstruct */
  init_dsm_address_info(chartInstance);
  if (!sim_mode_is_rtw_gen(S)) {
  }

  sf_opaque_init_subchart_simstructs(chartInstance->chartInfo.chartInstance);
  chart_debug_initialization(S,1);
}

void c2_FOCsim_method_dispatcher(SimStruct *S, int_T method, void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c2_FOCsim(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c2_FOCsim(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c2_FOCsim(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c2_FOCsim_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
