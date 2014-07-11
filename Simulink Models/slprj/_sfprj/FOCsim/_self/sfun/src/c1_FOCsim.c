/* Include files */

#include <stddef.h>
#include "blas.h"
#include "FOCsim_sfun.h"
#include "c1_FOCsim.h"
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
static const char * c1_debug_family_names[12] = { "nargin", "nargout", "u", "v",
  "w", "sector", "H1", "L1", "H2", "L2", "H3", "L3" };

/* Function Declarations */
static void initialize_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void initialize_params_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void enable_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void disable_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void c1_update_debugger_state_c1_FOCsim(SFc1_FOCsimInstanceStruct
  *chartInstance);
static const mxArray *get_sim_state_c1_FOCsim(SFc1_FOCsimInstanceStruct
  *chartInstance);
static void set_sim_state_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_st);
static void finalize_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void sf_gateway_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void initSimStructsc1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance);
static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber, uint32_T c1_instanceNumber);
static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData);
static real_T c1_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_L3, const char_T *c1_identifier);
static real_T c1_b_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData);
static int32_T c1_c_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData);
static uint8_T c1_d_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_b_is_active_c1_FOCsim, const char_T *c1_identifier);
static uint8_T c1_e_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId);
static void init_dsm_address_info(SFc1_FOCsimInstanceStruct *chartInstance);

/* Function Definitions */
static void initialize_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  chartInstance->c1_sfEvent = CALL_EVENT;
  _sfTime_ = sf_get_time(chartInstance->S);
  chartInstance->c1_is_active_c1_FOCsim = 0U;
}

static void initialize_params_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void enable_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void disable_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  _sfTime_ = sf_get_time(chartInstance->S);
}

static void c1_update_debugger_state_c1_FOCsim(SFc1_FOCsimInstanceStruct
  *chartInstance)
{
  (void)chartInstance;
}

static const mxArray *get_sim_state_c1_FOCsim(SFc1_FOCsimInstanceStruct
  *chartInstance)
{
  const mxArray *c1_st;
  const mxArray *c1_y = NULL;
  real_T c1_hoistedGlobal;
  real_T c1_u;
  const mxArray *c1_b_y = NULL;
  real_T c1_b_hoistedGlobal;
  real_T c1_b_u;
  const mxArray *c1_c_y = NULL;
  real_T c1_c_hoistedGlobal;
  real_T c1_c_u;
  const mxArray *c1_d_y = NULL;
  real_T c1_d_hoistedGlobal;
  real_T c1_d_u;
  const mxArray *c1_e_y = NULL;
  real_T c1_e_hoistedGlobal;
  real_T c1_e_u;
  const mxArray *c1_f_y = NULL;
  real_T c1_f_hoistedGlobal;
  real_T c1_f_u;
  const mxArray *c1_g_y = NULL;
  uint8_T c1_g_hoistedGlobal;
  uint8_T c1_g_u;
  const mxArray *c1_h_y = NULL;
  real_T *c1_H1;
  real_T *c1_H2;
  real_T *c1_H3;
  real_T *c1_L1;
  real_T *c1_L2;
  real_T *c1_L3;
  c1_L3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 6);
  c1_H3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 5);
  c1_L2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c1_H2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c1_L1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c1_H1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c1_st = NULL;
  c1_st = NULL;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_createcellmatrix(7, 1), false);
  c1_hoistedGlobal = *c1_H1;
  c1_u = c1_hoistedGlobal;
  c1_b_y = NULL;
  sf_mex_assign(&c1_b_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 0, c1_b_y);
  c1_b_hoistedGlobal = *c1_H2;
  c1_b_u = c1_b_hoistedGlobal;
  c1_c_y = NULL;
  sf_mex_assign(&c1_c_y, sf_mex_create("y", &c1_b_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 1, c1_c_y);
  c1_c_hoistedGlobal = *c1_H3;
  c1_c_u = c1_c_hoistedGlobal;
  c1_d_y = NULL;
  sf_mex_assign(&c1_d_y, sf_mex_create("y", &c1_c_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 2, c1_d_y);
  c1_d_hoistedGlobal = *c1_L1;
  c1_d_u = c1_d_hoistedGlobal;
  c1_e_y = NULL;
  sf_mex_assign(&c1_e_y, sf_mex_create("y", &c1_d_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 3, c1_e_y);
  c1_e_hoistedGlobal = *c1_L2;
  c1_e_u = c1_e_hoistedGlobal;
  c1_f_y = NULL;
  sf_mex_assign(&c1_f_y, sf_mex_create("y", &c1_e_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 4, c1_f_y);
  c1_f_hoistedGlobal = *c1_L3;
  c1_f_u = c1_f_hoistedGlobal;
  c1_g_y = NULL;
  sf_mex_assign(&c1_g_y, sf_mex_create("y", &c1_f_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 5, c1_g_y);
  c1_g_hoistedGlobal = chartInstance->c1_is_active_c1_FOCsim;
  c1_g_u = c1_g_hoistedGlobal;
  c1_h_y = NULL;
  sf_mex_assign(&c1_h_y, sf_mex_create("y", &c1_g_u, 3, 0U, 0U, 0U, 0), false);
  sf_mex_setcell(c1_y, 6, c1_h_y);
  sf_mex_assign(&c1_st, c1_y, false);
  return c1_st;
}

static void set_sim_state_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_st)
{
  const mxArray *c1_u;
  real_T *c1_H1;
  real_T *c1_H2;
  real_T *c1_H3;
  real_T *c1_L1;
  real_T *c1_L2;
  real_T *c1_L3;
  c1_L3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 6);
  c1_H3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 5);
  c1_L2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c1_H2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c1_L1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c1_H1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  chartInstance->c1_doneDoubleBufferReInit = true;
  c1_u = sf_mex_dup(c1_st);
  *c1_H1 = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 0)),
    "H1");
  *c1_H2 = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 1)),
    "H2");
  *c1_H3 = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 2)),
    "H3");
  *c1_L1 = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 3)),
    "L1");
  *c1_L2 = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 4)),
    "L2");
  *c1_L3 = c1_emlrt_marshallIn(chartInstance, sf_mex_dup(sf_mex_getcell(c1_u, 5)),
    "L3");
  chartInstance->c1_is_active_c1_FOCsim = c1_d_emlrt_marshallIn(chartInstance,
    sf_mex_dup(sf_mex_getcell(c1_u, 6)), "is_active_c1_FOCsim");
  sf_mex_destroy(&c1_u);
  c1_update_debugger_state_c1_FOCsim(chartInstance);
  sf_mex_destroy(&c1_st);
}

static void finalize_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void sf_gateway_c1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  real_T c1_hoistedGlobal;
  real_T c1_b_hoistedGlobal;
  real_T c1_c_hoistedGlobal;
  real32_T c1_d_hoistedGlobal;
  real_T c1_u;
  real_T c1_v;
  real_T c1_w;
  real32_T c1_sector;
  uint32_T c1_debug_family_var_map[12];
  real_T c1_nargin = 4.0;
  real_T c1_nargout = 6.0;
  real_T c1_H1;
  real_T c1_L1;
  real_T c1_H2;
  real_T c1_L2;
  real_T c1_H3;
  real_T c1_L3;
  real_T *c1_b_u;
  real_T *c1_b_H1;
  real_T *c1_b_v;
  real_T *c1_b_w;
  real32_T *c1_b_sector;
  real_T *c1_b_L1;
  real_T *c1_b_H2;
  real_T *c1_b_L2;
  real_T *c1_b_H3;
  real_T *c1_b_L3;
  c1_b_L3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 6);
  c1_b_H3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 5);
  c1_b_L2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 4);
  c1_b_H2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 3);
  c1_b_L1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
  c1_b_sector = (real32_T *)ssGetInputPortSignal(chartInstance->S, 3);
  c1_b_w = (real_T *)ssGetInputPortSignal(chartInstance->S, 2);
  c1_b_v = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
  c1_b_H1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
  c1_b_u = (real_T *)ssGetInputPortSignal(chartInstance->S, 0);
  _SFD_SYMBOL_SCOPE_PUSH(0U, 0U);
  _sfTime_ = sf_get_time(chartInstance->S);
  _SFD_CC_CALL(CHART_ENTER_SFUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  _SFD_DATA_RANGE_CHECK(*c1_b_u, 0U);
  chartInstance->c1_sfEvent = CALL_EVENT;
  _SFD_CC_CALL(CHART_ENTER_DURING_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  c1_hoistedGlobal = *c1_b_u;
  c1_b_hoistedGlobal = *c1_b_v;
  c1_c_hoistedGlobal = *c1_b_w;
  c1_d_hoistedGlobal = *c1_b_sector;
  c1_u = c1_hoistedGlobal;
  c1_v = c1_b_hoistedGlobal;
  c1_w = c1_c_hoistedGlobal;
  c1_sector = c1_d_hoistedGlobal;
  _SFD_SYMBOL_SCOPE_PUSH_EML(0U, 12U, 12U, c1_debug_family_names,
    c1_debug_family_var_map);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargin, 0U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_nargout, 1U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c1_u, 2U, c1_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c1_v, 3U, c1_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c1_w, 4U, c1_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML(&c1_sector, 5U, c1_b_sf_marshallOut);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_H1, 6U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_L1, 7U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_H2, 8U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_L2, 9U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_H3, 10U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  _SFD_SYMBOL_SCOPE_ADD_EML_IMPORTABLE(&c1_L3, 11U, c1_sf_marshallOut,
    c1_sf_marshallIn);
  CV_EML_FCN(0, 0);
  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 4);
  if (CV_EML_IF(0, 1, 0, c1_sector == 3.0F)) {
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 5);
    c1_H1 = c1_u;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 6);
    c1_H2 = 0.0;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 7);
    c1_H3 = 0.0;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 8);
    c1_L1 = 0.0;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 9);
    c1_L2 = c1_u;
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 10);
    c1_L3 = c1_u;
  } else {
    _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 11);
    if (CV_EML_IF(0, 1, 1, c1_sector == 1.0F)) {
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 12);
      c1_H1 = c1_u;
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 13);
      c1_H2 = c1_v;
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 14);
      c1_H3 = 0.0;
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 15);
      c1_L1 = 0.0;
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 16);
      c1_L2 = 0.0;
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 17);
      c1_L3 = 1.0;
    } else {
      _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 18);
      if (CV_EML_IF(0, 1, 2, c1_sector == 5.0F)) {
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 19);
        c1_H1 = 0.0;
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 20);
        c1_H2 = c1_v;
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 21);
        c1_H3 = 0.0;
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 22);
        c1_L1 = c1_v;
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 23);
        c1_L2 = 0.0;
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 24);
        c1_L3 = c1_v;
      } else {
        _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 25);
        if (CV_EML_IF(0, 1, 3, c1_sector == 4.0F)) {
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 26);
          c1_H1 = 0.0;
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 27);
          c1_H2 = c1_v;
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 28);
          c1_H3 = c1_w;
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 29);
          c1_L1 = 1.0;
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 30);
          c1_L2 = 0.0;
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 31);
          c1_L3 = 0.0;
        } else {
          _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 32);
          if (CV_EML_IF(0, 1, 4, c1_sector == 6.0F)) {
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 33);
            c1_H1 = 0.0;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 34);
            c1_H2 = 0.0;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 35);
            c1_H3 = c1_w;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 36);
            c1_L1 = c1_w;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 37);
            c1_L2 = c1_w;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 38);
            c1_L3 = 0.0;
          } else {
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 40);
            c1_H1 = c1_u;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 41);
            c1_H2 = 0.0;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 42);
            c1_H3 = c1_w;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 43);
            c1_L1 = 0.0;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 44);
            c1_L2 = 1.0;
            _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, 45);
            c1_L3 = 0.0;
          }
        }
      }
    }
  }

  _SFD_EML_CALL(0U, chartInstance->c1_sfEvent, -45);
  _SFD_SYMBOL_SCOPE_POP();
  *c1_b_H1 = c1_H1;
  *c1_b_L1 = c1_L1;
  *c1_b_H2 = c1_H2;
  *c1_b_L2 = c1_L2;
  *c1_b_H3 = c1_H3;
  *c1_b_L3 = c1_L3;
  _SFD_CC_CALL(EXIT_OUT_OF_FUNCTION_TAG, 0U, chartInstance->c1_sfEvent);
  _SFD_SYMBOL_SCOPE_POP();
  _SFD_CHECK_FOR_STATE_INCONSISTENCY(_FOCsimMachineNumber_,
    chartInstance->chartNumber, chartInstance->instanceNumber);
  _SFD_DATA_RANGE_CHECK(*c1_b_H1, 1U);
  _SFD_DATA_RANGE_CHECK(*c1_b_v, 2U);
  _SFD_DATA_RANGE_CHECK(*c1_b_w, 3U);
  _SFD_DATA_RANGE_CHECK((real_T)*c1_b_sector, 4U);
  _SFD_DATA_RANGE_CHECK(*c1_b_L1, 5U);
  _SFD_DATA_RANGE_CHECK(*c1_b_H2, 6U);
  _SFD_DATA_RANGE_CHECK(*c1_b_L2, 7U);
  _SFD_DATA_RANGE_CHECK(*c1_b_H3, 8U);
  _SFD_DATA_RANGE_CHECK(*c1_b_L3, 9U);
}

static void initSimStructsc1_FOCsim(SFc1_FOCsimInstanceStruct *chartInstance)
{
  (void)chartInstance;
}

static void init_script_number_translation(uint32_T c1_machineNumber, uint32_T
  c1_chartNumber, uint32_T c1_instanceNumber)
{
  (void)c1_machineNumber;
  (void)c1_chartNumber;
  (void)c1_instanceNumber;
}

static const mxArray *c1_sf_marshallOut(void *chartInstanceVoid, void *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  real_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FOCsimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(real_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 0, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static real_T c1_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_L3, const char_T *c1_identifier)
{
  real_T c1_y;
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_L3), &c1_thisId);
  sf_mex_destroy(&c1_L3);
  return c1_y;
}

static real_T c1_b_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  real_T c1_y;
  real_T c1_d0;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_d0, 1, 0, 0U, 0, 0U, 0);
  c1_y = c1_d0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_L3;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  real_T c1_y;
  SFc1_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FOCsimInstanceStruct *)chartInstanceVoid;
  c1_L3 = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_b_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_L3), &c1_thisId);
  sf_mex_destroy(&c1_L3);
  *(real_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static const mxArray *c1_b_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  real32_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FOCsimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(real32_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 1, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

const mxArray *sf_c1_FOCsim_get_eml_resolved_functions_info(void)
{
  const mxArray *c1_nameCaptureInfo = NULL;
  c1_nameCaptureInfo = NULL;
  sf_mex_assign(&c1_nameCaptureInfo, sf_mex_create("nameCaptureInfo", NULL, 0,
    0U, 1U, 0U, 2, 0, 1), false);
  return c1_nameCaptureInfo;
}

static const mxArray *c1_c_sf_marshallOut(void *chartInstanceVoid, void
  *c1_inData)
{
  const mxArray *c1_mxArrayOutData = NULL;
  int32_T c1_u;
  const mxArray *c1_y = NULL;
  SFc1_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FOCsimInstanceStruct *)chartInstanceVoid;
  c1_mxArrayOutData = NULL;
  c1_u = *(int32_T *)c1_inData;
  c1_y = NULL;
  sf_mex_assign(&c1_y, sf_mex_create("y", &c1_u, 6, 0U, 0U, 0U, 0), false);
  sf_mex_assign(&c1_mxArrayOutData, c1_y, false);
  return c1_mxArrayOutData;
}

static int32_T c1_c_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  int32_T c1_y;
  int32_T c1_i0;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_i0, 1, 6, 0U, 0, 0U, 0);
  c1_y = c1_i0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void c1_b_sf_marshallIn(void *chartInstanceVoid, const mxArray
  *c1_mxArrayInData, const char_T *c1_varName, void *c1_outData)
{
  const mxArray *c1_b_sfEvent;
  const char_T *c1_identifier;
  emlrtMsgIdentifier c1_thisId;
  int32_T c1_y;
  SFc1_FOCsimInstanceStruct *chartInstance;
  chartInstance = (SFc1_FOCsimInstanceStruct *)chartInstanceVoid;
  c1_b_sfEvent = sf_mex_dup(c1_mxArrayInData);
  c1_identifier = c1_varName;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_c_emlrt_marshallIn(chartInstance, sf_mex_dup(c1_b_sfEvent),
    &c1_thisId);
  sf_mex_destroy(&c1_b_sfEvent);
  *(int32_T *)c1_outData = c1_y;
  sf_mex_destroy(&c1_mxArrayInData);
}

static uint8_T c1_d_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_b_is_active_c1_FOCsim, const char_T *c1_identifier)
{
  uint8_T c1_y;
  emlrtMsgIdentifier c1_thisId;
  c1_thisId.fIdentifier = c1_identifier;
  c1_thisId.fParent = NULL;
  c1_y = c1_e_emlrt_marshallIn(chartInstance, sf_mex_dup
    (c1_b_is_active_c1_FOCsim), &c1_thisId);
  sf_mex_destroy(&c1_b_is_active_c1_FOCsim);
  return c1_y;
}

static uint8_T c1_e_emlrt_marshallIn(SFc1_FOCsimInstanceStruct *chartInstance,
  const mxArray *c1_u, const emlrtMsgIdentifier *c1_parentId)
{
  uint8_T c1_y;
  uint8_T c1_u0;
  (void)chartInstance;
  sf_mex_import(c1_parentId, sf_mex_dup(c1_u), &c1_u0, 1, 3, 0U, 0, 0U, 0);
  c1_y = c1_u0;
  sf_mex_destroy(&c1_u);
  return c1_y;
}

static void init_dsm_address_info(SFc1_FOCsimInstanceStruct *chartInstance)
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

void sf_c1_FOCsim_get_check_sum(mxArray *plhs[])
{
  ((real_T *)mxGetPr((plhs[0])))[0] = (real_T)(4221895127U);
  ((real_T *)mxGetPr((plhs[0])))[1] = (real_T)(4037923576U);
  ((real_T *)mxGetPr((plhs[0])))[2] = (real_T)(3528615428U);
  ((real_T *)mxGetPr((plhs[0])))[3] = (real_T)(2596821141U);
}

mxArray *sf_c1_FOCsim_get_autoinheritance_info(void)
{
  const char *autoinheritanceFields[] = { "checksum", "inputs", "parameters",
    "outputs", "locals" };

  mxArray *mxAutoinheritanceInfo = mxCreateStructMatrix(1,1,5,
    autoinheritanceFields);

  {
    mxArray *mxChecksum = mxCreateString("7PIdeHWLXhJCj9llIdewYG");
    mxSetField(mxAutoinheritanceInfo,0,"checksum",mxChecksum);
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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
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
    mxSetField(mxAutoinheritanceInfo,0,"inputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"parameters",mxCreateDoubleMatrix(0,0,
                mxREAL));
  }

  {
    const char *dataFields[] = { "size", "type", "complexity" };

    mxArray *mxData = mxCreateStructMatrix(1,6,3,dataFields);

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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
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
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,3,"type",mxType);
    }

    mxSetField(mxData,3,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,4,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,4,"type",mxType);
    }

    mxSetField(mxData,4,"complexity",mxCreateDoubleScalar(0));

    {
      mxArray *mxSize = mxCreateDoubleMatrix(1,2,mxREAL);
      double *pr = mxGetPr(mxSize);
      pr[0] = (double)(1);
      pr[1] = (double)(1);
      mxSetField(mxData,5,"size",mxSize);
    }

    {
      const char *typeFields[] = { "base", "fixpt" };

      mxArray *mxType = mxCreateStructMatrix(1,1,2,typeFields);
      mxSetField(mxType,0,"base",mxCreateDoubleScalar(10));
      mxSetField(mxType,0,"fixpt",mxCreateDoubleMatrix(0,0,mxREAL));
      mxSetField(mxData,5,"type",mxType);
    }

    mxSetField(mxData,5,"complexity",mxCreateDoubleScalar(0));
    mxSetField(mxAutoinheritanceInfo,0,"outputs",mxData);
  }

  {
    mxSetField(mxAutoinheritanceInfo,0,"locals",mxCreateDoubleMatrix(0,0,mxREAL));
  }

  return(mxAutoinheritanceInfo);
}

mxArray *sf_c1_FOCsim_third_party_uses_info(void)
{
  mxArray * mxcell3p = mxCreateCellMatrix(1,0);
  return(mxcell3p);
}

mxArray *sf_c1_FOCsim_updateBuildInfo_args_info(void)
{
  mxArray *mxBIArgs = mxCreateCellMatrix(1,0);
  return mxBIArgs;
}

static const mxArray *sf_get_sim_state_info_c1_FOCsim(void)
{
  const char *infoFields[] = { "chartChecksum", "varInfo" };

  mxArray *mxInfo = mxCreateStructMatrix(1, 1, 2, infoFields);
  const char *infoEncStr[] = {
    "100 S1x7'type','srcId','name','auxInfo'{{M[1],M[5],T\"H1\",},{M[1],M[12],T\"H2\",},{M[1],M[10],T\"H3\",},{M[1],M[9],T\"L1\",},{M[1],M[13],T\"L2\",},{M[1],M[11],T\"L3\",},{M[8],M[0],T\"is_active_c1_FOCsim\",}}"
  };

  mxArray *mxVarInfo = sf_mex_decode_encoded_mx_struct_array(infoEncStr, 7, 10);
  mxArray *mxChecksum = mxCreateDoubleMatrix(1, 4, mxREAL);
  sf_c1_FOCsim_get_check_sum(&mxChecksum);
  mxSetField(mxInfo, 0, infoFields[0], mxChecksum);
  mxSetField(mxInfo, 0, infoFields[1], mxVarInfo);
  return mxInfo;
}

static void chart_debug_initialization(SimStruct *S, unsigned int
  fullDebuggerInitialization)
{
  if (!sim_mode_is_rtw_gen(S)) {
    SFc1_FOCsimInstanceStruct *chartInstance;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
    chartInstance = (SFc1_FOCsimInstanceStruct *) chartInfo->chartInstance;
    if (ssIsFirstInitCond(S) && fullDebuggerInitialization==1) {
      /* do this only if simulation is starting */
      {
        unsigned int chartAlreadyPresent;
        chartAlreadyPresent = sf_debug_initialize_chart
          (sfGlobalDebugInstanceStruct,
           _FOCsimMachineNumber_,
           1,
           1,
           1,
           0,
           10,
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
          _SFD_SET_DATA_PROPS(0,1,1,0,"u");
          _SFD_SET_DATA_PROPS(1,2,0,1,"H1");
          _SFD_SET_DATA_PROPS(2,1,1,0,"v");
          _SFD_SET_DATA_PROPS(3,1,1,0,"w");
          _SFD_SET_DATA_PROPS(4,1,1,0,"sector");
          _SFD_SET_DATA_PROPS(5,2,0,1,"L1");
          _SFD_SET_DATA_PROPS(6,2,0,1,"H2");
          _SFD_SET_DATA_PROPS(7,2,0,1,"L2");
          _SFD_SET_DATA_PROPS(8,2,0,1,"H3");
          _SFD_SET_DATA_PROPS(9,2,0,1,"L3");
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
        _SFD_CV_INIT_EML_FCN(0,0,"eML_blk_kernel",0,-1,785);
        _SFD_CV_INIT_EML_IF(0,1,0,72,88,189,781);
        _SFD_CV_INIT_EML_IF(0,1,1,189,209,310,781);
        _SFD_CV_INIT_EML_IF(0,1,2,310,330,431,781);
        _SFD_CV_INIT_EML_IF(0,1,3,431,451,552,781);
        _SFD_CV_INIT_EML_IF(0,1,4,552,572,673,781);
        _SFD_SET_DATA_COMPILED_PROPS(0,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(1,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(2,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(3,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(4,SF_SINGLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_b_sf_marshallOut,(MexInFcnForType)NULL);
        _SFD_SET_DATA_COMPILED_PROPS(5,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(6,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(7,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(8,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);
        _SFD_SET_DATA_COMPILED_PROPS(9,SF_DOUBLE,0,NULL,0,0,0,0.0,1.0,0,0,
          (MexFcnForType)c1_sf_marshallOut,(MexInFcnForType)c1_sf_marshallIn);

        {
          real_T *c1_u;
          real_T *c1_H1;
          real_T *c1_v;
          real_T *c1_w;
          real32_T *c1_sector;
          real_T *c1_L1;
          real_T *c1_H2;
          real_T *c1_L2;
          real_T *c1_H3;
          real_T *c1_L3;
          c1_L3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 6);
          c1_H3 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 5);
          c1_L2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 4);
          c1_H2 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 3);
          c1_L1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 2);
          c1_sector = (real32_T *)ssGetInputPortSignal(chartInstance->S, 3);
          c1_w = (real_T *)ssGetInputPortSignal(chartInstance->S, 2);
          c1_v = (real_T *)ssGetInputPortSignal(chartInstance->S, 1);
          c1_H1 = (real_T *)ssGetOutputPortSignal(chartInstance->S, 1);
          c1_u = (real_T *)ssGetInputPortSignal(chartInstance->S, 0);
          _SFD_SET_DATA_VALUE_PTR(0U, c1_u);
          _SFD_SET_DATA_VALUE_PTR(1U, c1_H1);
          _SFD_SET_DATA_VALUE_PTR(2U, c1_v);
          _SFD_SET_DATA_VALUE_PTR(3U, c1_w);
          _SFD_SET_DATA_VALUE_PTR(4U, c1_sector);
          _SFD_SET_DATA_VALUE_PTR(5U, c1_L1);
          _SFD_SET_DATA_VALUE_PTR(6U, c1_H2);
          _SFD_SET_DATA_VALUE_PTR(7U, c1_L2);
          _SFD_SET_DATA_VALUE_PTR(8U, c1_H3);
          _SFD_SET_DATA_VALUE_PTR(9U, c1_L3);
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
  return "Eqq9eCm1162wVcFX9ho7bG";
}

static void sf_opaque_initialize_c1_FOCsim(void *chartInstanceVar)
{
  chart_debug_initialization(((SFc1_FOCsimInstanceStruct*) chartInstanceVar)->S,
    0);
  initialize_params_c1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
  initialize_c1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_enable_c1_FOCsim(void *chartInstanceVar)
{
  enable_c1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_disable_c1_FOCsim(void *chartInstanceVar)
{
  disable_c1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
}

static void sf_opaque_gateway_c1_FOCsim(void *chartInstanceVar)
{
  sf_gateway_c1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
}

extern const mxArray* sf_internal_get_sim_state_c1_FOCsim(SimStruct* S)
{
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
  ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[4];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_raw2high");
  prhs[1] = mxCreateDoubleScalar(ssGetSFuncBlockHandle(S));
  prhs[2] = (mxArray*) get_sim_state_c1_FOCsim((SFc1_FOCsimInstanceStruct*)
    chartInfo->chartInstance);         /* raw sim ctx */
  prhs[3] = (mxArray*) sf_get_sim_state_info_c1_FOCsim();/* state var info */
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

extern void sf_internal_set_sim_state_c1_FOCsim(SimStruct* S, const mxArray *st)
{
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
  ChartInfoStruct * chartInfo = (ChartInfoStruct *)(crtInfo->instanceInfo);
  mxArray *plhs[1] = { NULL };

  mxArray *prhs[3];
  int mxError = 0;
  prhs[0] = mxCreateString("chart_simctx_high2raw");
  prhs[1] = mxDuplicateArray(st);      /* high level simctx */
  prhs[2] = (mxArray*) sf_get_sim_state_info_c1_FOCsim();/* state var info */
  mxError = sf_mex_call_matlab(1, plhs, 3, prhs, "sfprivate");
  mxDestroyArray(prhs[0]);
  mxDestroyArray(prhs[1]);
  mxDestroyArray(prhs[2]);
  if (mxError || plhs[0] == NULL) {
    sf_mex_error_message("Stateflow Internal Error: \nError calling 'chart_simctx_high2raw'.\n");
  }

  set_sim_state_c1_FOCsim((SFc1_FOCsimInstanceStruct*)chartInfo->chartInstance,
    mxDuplicateArray(plhs[0]));
  mxDestroyArray(plhs[0]);
}

static const mxArray* sf_opaque_get_sim_state_c1_FOCsim(SimStruct* S)
{
  return sf_internal_get_sim_state_c1_FOCsim(S);
}

static void sf_opaque_set_sim_state_c1_FOCsim(SimStruct* S, const mxArray *st)
{
  sf_internal_set_sim_state_c1_FOCsim(S, st);
}

static void sf_opaque_terminate_c1_FOCsim(void *chartInstanceVar)
{
  if (chartInstanceVar!=NULL) {
    SimStruct *S = ((SFc1_FOCsimInstanceStruct*) chartInstanceVar)->S;
    ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)(ssGetUserData(S));
    if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
      sf_clear_rtw_identifier(S);
      unload_FOCsim_optimization_info();
    }

    finalize_c1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
    utFree((void *)chartInstanceVar);
    if (crtInfo != NULL) {
      utFree((void *)crtInfo);
    }

    ssSetUserData(S,NULL);
  }
}

static void sf_opaque_init_subchart_simstructs(void *chartInstanceVar)
{
  initSimStructsc1_FOCsim((SFc1_FOCsimInstanceStruct*) chartInstanceVar);
}

extern unsigned int sf_machine_global_initializer_called(void);
static void mdlProcessParameters_c1_FOCsim(SimStruct *S)
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
    initialize_params_c1_FOCsim((SFc1_FOCsimInstanceStruct*)
      (chartInfo->chartInstance));
  }
}

static void mdlSetWorkWidths_c1_FOCsim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S) || sim_mode_is_external(S)) {
    mxArray *infoStruct = load_FOCsim_optimization_info();
    int_T chartIsInlinable =
      (int_T)sf_is_chart_inlinable(sf_get_instance_specialization(),infoStruct,1);
    ssSetStateflowIsInlinable(S,chartIsInlinable);
    ssSetRTWCG(S,sf_rtw_info_uint_prop(sf_get_instance_specialization(),
                infoStruct,1,"RTWCG"));
    ssSetEnableFcnIsTrivial(S,1);
    ssSetDisableFcnIsTrivial(S,1);
    ssSetNotMultipleInlinable(S,sf_rtw_info_uint_prop
      (sf_get_instance_specialization(),infoStruct,1,
       "gatewayCannotBeInlinedMultipleTimes"));
    sf_update_buildInfo(sf_get_instance_specialization(),infoStruct,1);
    if (chartIsInlinable) {
      ssSetInputPortOptimOpts(S, 0, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 1, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 2, SS_REUSABLE_AND_LOCAL);
      ssSetInputPortOptimOpts(S, 3, SS_REUSABLE_AND_LOCAL);
      sf_mark_chart_expressionable_inputs(S,sf_get_instance_specialization(),
        infoStruct,1,4);
      sf_mark_chart_reusable_outputs(S,sf_get_instance_specialization(),
        infoStruct,1,6);
    }

    {
      unsigned int outPortIdx;
      for (outPortIdx=1; outPortIdx<=6; ++outPortIdx) {
        ssSetOutputPortOptimizeInIR(S, outPortIdx, 1U);
      }
    }

    {
      unsigned int inPortIdx;
      for (inPortIdx=0; inPortIdx < 4; ++inPortIdx) {
        ssSetInputPortOptimizeInIR(S, inPortIdx, 1U);
      }
    }

    sf_set_rtw_dwork_info(S,sf_get_instance_specialization(),infoStruct,1);
    ssSetHasSubFunctions(S,!(chartIsInlinable));
  } else {
  }

  ssSetOptions(S,ssGetOptions(S)|SS_OPTION_WORKS_WITH_CODE_REUSE);
  ssSetChecksum0(S,(4153648427U));
  ssSetChecksum1(S,(1120721582U));
  ssSetChecksum2(S,(1402268111U));
  ssSetChecksum3(S,(2943674915U));
  ssSetmdlDerivatives(S, NULL);
  ssSetExplicitFCSSCtrl(S,1);
  ssSupportsMultipleExecInstances(S,1);
}

static void mdlRTW_c1_FOCsim(SimStruct *S)
{
  if (sim_mode_is_rtw_gen(S)) {
    ssWriteRTWStrParam(S, "StateflowChartType", "Embedded MATLAB");
  }
}

static void mdlStart_c1_FOCsim(SimStruct *S)
{
  SFc1_FOCsimInstanceStruct *chartInstance;
  ChartRunTimeInfo * crtInfo = (ChartRunTimeInfo *)utMalloc(sizeof
    (ChartRunTimeInfo));
  chartInstance = (SFc1_FOCsimInstanceStruct *)utMalloc(sizeof
    (SFc1_FOCsimInstanceStruct));
  memset(chartInstance, 0, sizeof(SFc1_FOCsimInstanceStruct));
  if (chartInstance==NULL) {
    sf_mex_error_message("Could not allocate memory for chart instance.");
  }

  chartInstance->chartInfo.chartInstance = chartInstance;
  chartInstance->chartInfo.isEMLChart = 1;
  chartInstance->chartInfo.chartInitialized = 0;
  chartInstance->chartInfo.sFunctionGateway = sf_opaque_gateway_c1_FOCsim;
  chartInstance->chartInfo.initializeChart = sf_opaque_initialize_c1_FOCsim;
  chartInstance->chartInfo.terminateChart = sf_opaque_terminate_c1_FOCsim;
  chartInstance->chartInfo.enableChart = sf_opaque_enable_c1_FOCsim;
  chartInstance->chartInfo.disableChart = sf_opaque_disable_c1_FOCsim;
  chartInstance->chartInfo.getSimState = sf_opaque_get_sim_state_c1_FOCsim;
  chartInstance->chartInfo.setSimState = sf_opaque_set_sim_state_c1_FOCsim;
  chartInstance->chartInfo.getSimStateInfo = sf_get_sim_state_info_c1_FOCsim;
  chartInstance->chartInfo.zeroCrossings = NULL;
  chartInstance->chartInfo.outputs = NULL;
  chartInstance->chartInfo.derivatives = NULL;
  chartInstance->chartInfo.mdlRTW = mdlRTW_c1_FOCsim;
  chartInstance->chartInfo.mdlStart = mdlStart_c1_FOCsim;
  chartInstance->chartInfo.mdlSetWorkWidths = mdlSetWorkWidths_c1_FOCsim;
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

void c1_FOCsim_method_dispatcher(SimStruct *S, int_T method, void *data)
{
  switch (method) {
   case SS_CALL_MDL_START:
    mdlStart_c1_FOCsim(S);
    break;

   case SS_CALL_MDL_SET_WORK_WIDTHS:
    mdlSetWorkWidths_c1_FOCsim(S);
    break;

   case SS_CALL_MDL_PROCESS_PARAMETERS:
    mdlProcessParameters_c1_FOCsim(S);
    break;

   default:
    /* Unhandled method */
    sf_mex_error_message("Stateflow Internal Error:\n"
                         "Error calling c1_FOCsim_method_dispatcher.\n"
                         "Can't handle method %d.\n", method);
    break;
  }
}
