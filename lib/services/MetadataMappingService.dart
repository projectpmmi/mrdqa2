class MetadataMappingService {
  final DataSetId = "MRDQA_DATA_COLLECTION";

  final CompletenessMonthlyReport = "COMPLETENESS_MALARIA_MONTHLY_REPORT"; // MDQA: Completeness of Malaria Monthly Report

  final TimelinessMonthlyReport = "TIMELINESS_MALARIA_MONTHLY_REPORT"; // MDQA: Timeliness of Malaria of Monthly Report

  final Map<String, String> SourceDocumentCompleteness = {
    "standard": "SOURCE_DOCUMENTS_STANDARD_ISSUE", // MDQA: Source documents standard issue
    "uptodate": "SOURCE_DOCUMENTS_UP-TO-DATE", // MDQA: Source documents Up-to-date
    "available": "SOURCE_DOCUMENTS_AVAILABLE" // MDQA: Source documents available
  };

  final String DataElementCompleteness = "PERCENT_CASES_MISSING_DATA"; // MDQA: Percent of cases with missing data

  final Map<int, String> DataElementCompletenessMap = {
    1: "MRDQA_UNIQUE_ID", // Unique ID
    2: "MRDQA_VISIT_DATE", // Visit date
    3: "MRDQA_CLIENT_NAME", // Client name
    4: "MRDQA_AGE", // Age
    5: "MRDQA_DIAGNOSIS_TYPE", // Diagnosis type
    6: "MRDQA_TEST_RESULT_RDT", // Test result (RDT)
    7: "MRDQA_TEST_RESULT_MICROSCOPY", // Test result (microscopy)
    8: "MRDQA_TREATMENT_ACT", // Treatment with ACT
    9: "MRDQA_OTHER_TREATMENT" // Other treatment
  };

  final Map<int, String> SourceDocumentCompletenessMap = {
    1: "MRDQA_CLIENT_HELD_RECORD", // Client held record
    2: "MRDQA_MALARIA_CASE_REGISTER", // Malaria case register
    3: "MRDQA_MONTHLY_REPORT", // Monthly report
    4: "MRDQA_LABORATORY_REGISTER", // Laboratory register
    5: "MRDQA_PHARMACY_DISPENSATION_LOG", // Pharmacy dispensation log
    6: "MRDQA_ACT_STOCK_M_LOG", // ACT stock management log
    7: "MRDQA_MALARIA_SURVEILLANCE_REPORTS", // Malaria surveillance reports
    8: "MRDQA_BET_NETS_STOCK_M_LOGS", // Bed nets stock management logs
    9: "MRDQA_INPATIENT_REGISTER", // Inpatient register
    10: "MRDQA_OPD_REGISTER", // OPD register
    11: "MRDQA_TALLY_SHEET" // Tally sheet
  };

  final Map<String, String> VerificationFactors = {
    "monthly_report": "OPTION_MONTHLY_REPORT", //
    "hmis": "OPTION_HMIS",
    "no_discrepency": "OPTION_NO_DISCREPENCY",
    "arithmetic_errors": "OPTION_ARITHMETIC_ERRORS",
    "transcription_errors": "OPTION_TRANSCRIPTION_ERRORS",
    "documents_were_missing": "OPTION_DOCUMENTS_WERE_MISSING",
    "documents_are_missing": "OPTION_DOCUMENTS_ARE_MISSING",
    "forms_not_up-to-date": "OPTION_FORMS_NOT_UP-TO-DATE",
    "commodity_forms_not_up-to-date": "OPTION_COMMODITY_NOT_UP-TO-DATE",
    "stock_out_treatment_drugs": "OPTION_STOCK_OUT_TREATMENT_DRUGS",
    "stock_out_drugs": "OPTION_STOCK_OUT_DRUGS",
    "stock_out_vaccine": "OPTION_STOCK_OUT_VACCINE"
  };

  final Map<String, String> ConsistencyMonths = {
    "month_1": "OPTION_MONTH_1",
    "month_2": "OPTION_MONTH_2",
    "month_3": "OPTION_MONTH_3",
    "last_month": "OPTION_LAST_MONTH",
    "annual_consistency_ratio": "OPTION_ANNUAL_CONSISTENCY",
    "month-to-month_consistency_ratio": "OPTION_MONTH-MONTH-CONSISTENCY"
  };

  final Map<String, String> SourceDocumentStatus = {
    "available": "OPTION_AVAILABLE", // available
    "uptodate": "OPTION_UP-TO-DATE", // Up-to-date
    "standard": "OPTION_STANDARD_FORMS", // standard issue
  };

  final String categoryOptionCombos = 'OPTION_MONTHLY_REPORT,OPTION_HMIS,OPTION_NO_DISCREPENCY,OPTION_ARITHMETIC_ERRORS,OPTION_TRANSCRIPTION_ERRORS,'
      'OPTION_DOCUMENTS_WERE_MISSING,OPTION_DOCUMENTS_ARE_MISSING,OPTION_FORMS_NOT_UP-TO-DATE,OPTION_COMMODITY_NOT_UP-TO-DATE,OPTION_STOCK_OUT_TREATMENT_DRUGS,'
      'OPTION_STOCK_OUT_DRUGS,OPTION_STOCK_OUT_VACCINE,OPTION_MONTH_1,OPTION_MONTH_2,OPTION_MONTH_3,OPTION_LAST_MONTH,OPTION_ANNUAL_CONSISTENCY,'
      'OPTION_MONTH-MONTH-CONSISTENCY,OPTION_AVAILABLE,OPTION_UP-TO-DATE,OPTION_STANDARD_FORMS';

  final Map<String, String> SystemAssessment = {
    "readiness": "SYSTEM_ASSESSMENT_READINESS", // MDQA: System assessment (readiness)
    "enter_compile": "SYSTEM_ASSESSMENT_ENTER_COMPILE", // Staff to enter or compile reports
    "review_quality": "SYSTEM_ASSESSMENT_REVIEW_QUALITY", // Staff to review quality
    "guidelines": "SYSTEM_ASSESSMENT_WRITE_GUIDELINES", // Written guidelines on data collection
    "blank_form": "SYSTEM_ASSESSMENT_STOCK_BLANK_FORMS", // Stock of blank forms
    "stock_out_forms": "SYSTEM_ASSESSMENT_STOCK_OUT_FORMS", // Experienced any stock out of forms
    "standard_register": "SYSTEM_ASSESSMENT_STANDARD_REGISTER", // Standard register
    "history_easily_found": "SYSTEM_ASSESSMENT_PATIENT_HISTORY", // Patient history easily found
    "archives_maintained": "SYSTEM_ASSESSMENT_ARCHIVES_MAINTAINED", // Archives properly maintained
    "demographic": "SYSTEM_ASSESSMENT_ACCURATE_DEMOGRAPHICS", // Maintain accurate demographic information
    "target_to_monitor": "SYSTEM_ASSESSMENT_ETABLISHED_TARGETS", // Etablished targets to monitor progress
    "display": "SYSTEM_ASSESSMENT_UP-TO-DATE_DISPLAY", // Up-to-date display
    "chart_of_disease": "SYSTEM_ASSESSMENT_CHART_DISEASE" // Chart of disease incidence displayed
  };

  final Map<int, String> DataAccuracyMap = {
    1: 'DATA_ACCURACY_INDICATOR_1_1', // Number of children under 5 who received ITN
    2: 'DATA_ACCURACY_INDICATOR_1_2', // Number of pregnant women who received ITN',
    3: 'DATA_ACCURACY_INDICATOR_1_3', // 'Number of nets distributed to pregnant women',
    4: 'DATA_ACCURACY_INDICATOR_1_4', // Number of nets distributed through routine immunization',
    5: 'DATA_ACCURACY_INDICATOR_1_5', // Total number of nets distributed',
    6: 'DATA_ACCURACY_INDICATOR_2_1', // Number of OPD visits for children (< 5)',
    7: 'DATA_ACCURACY_INDICATOR_2_2', // Number of children (< 5) with fever',
    8: 'DATA_ACCURACY_INDICATOR_2_3', // Number of children (5-14) with fever',
    9: 'DATA_ACCURACY_INDICATOR_2_4', // Number of people (15+) with fever',
    10: 'DATA_ACCURACY_INDICATOR_2_5', // Number of children (< 5) with fever tested (RDT or microscopy)',
    11: 'DATA_ACCURACY_INDICATOR_2_6', // Number of children (5-14) with fever tested (RDT or microscopy)',
    12: 'DATA_ACCURACY_INDICATOR_2_7', // Number of people (15+) with fever tested (RDT or microscopy)',
    13: 'DATA_ACCURACY_INDICATOR_3_1', // Number of children (< 5) with confirmed malaria (tested positive with RDT)',
    14: 'DATA_ACCURACY_INDICATOR_3_2', // Number of children (5-14) with confirmed malaria (tested positive with RDT)',
    15: 'DATA_ACCURACY_INDICATOR_3_3', // Number of people (15+) with confirmed malaria (tested positive with RDT)',
    16: 'DATA_ACCURACY_INDICATOR_3_4', // Number of pregnant women with confirmed malaria (tested positive with RDT)',
    17: 'DATA_ACCURACY_INDICATOR_3_5', // Number of cases tested negative with RDT across all categories',
    18: 'DATA_ACCURACY_INDICATOR_3_6', // Number of confirmed malaria cases',
    19: 'DATA_ACCURACY_INDICATOR_3_7', // Number of presumed malaria cases',
    20: 'DATA_ACCURACY_INDICATOR_3_8', // Number of children (<5) with severe malaria',
    21: 'DATA_ACCURACY_INDICATOR_3_9', // Number of children (5-14) with severe malaria',
    22: 'DATA_ACCURACY_INDICATOR_3_10', // Number of people (15+) with severe malaria',
    23: 'DATA_ACCURACY_INDICATOR_4_1', // Number of children (< 5) with confirmed malaria receiving ACT',
    24: 'DATA_ACCURACY_INDICATOR_4_2', // Number of children (5-14) with confirmed malaria receiving ACT',
    25: 'DATA_ACCURACY_INDICATOR_4_3', // Number of people (15+) with confirmed malaria receiving ACT',
    26: 'DATA_ACCURACY_INDICATOR_4_4', // Number of children (<5) receiving ACT',
    27: 'DATA_ACCURACY_INDICATOR_4_5', // Number of children (5-14) receiving ACT',
    28: 'DATA_ACCURACY_INDICATOR_4_6', // Number of people (15+) receiving ACT',
    29: 'DATA_ACCURACY_INDICATOR_4_7', // Number of severe cases referred',
    30: 'DATA_ACCURACY_INDICATOR_4_8', // Number of cases that tested negative with RDT receiving ACT',
    31: 'DATA_ACCURACY_INDICATOR_5_1', // Stock out of ACTs for 7 consecutive days in the past month',
    32: 'DATA_ACCURACY_INDICATOR_5_2', // Stock out of RDTs for 7 consecutive days in the past month',
    33: 'DATA_ACCURACY_INDICATOR_5_3', // Stock out of SP for 7 consecutive days in the past month',
    34: 'DATA_ACCURACY_INDICATOR_5_4', // Stock out of injectible artesunate for 7 consecutive days in the past month',
    35: 'DATA_ACCURACY_INDICATOR_5_5', // Stock out of rectal artestunate for 7 consecutive days in the past month',
    36: 'DATA_ACCURACY_INDICATOR_5_6', // Stock out of ITN for 7 consecutive days in the past month',
    37: 'DATA_ACCURACY_INDICATOR_6_1', // Total number of malaria deaths (inpatient only)'
  };

  final Map<int, String> ConsistencyChecksMap = {
    1: 'CONSISTENCY_INDICATOR_1_1', // Number of children under 5 who received ITN',
    2: 'CONSISTENCY_INDICATOR_1_2', // Number of pregnant women who received ITN',
    3: 'CONSISTENCY_INDICATOR_1_3', // 'Number of nets distributed to pregnant women',
    4: 'CONSISTENCY_INDICATOR_1_4', // Number of nets distributed through routine immunization',
    5: 'CONSISTENCY_INDICATOR_1_5', // Total number of nets distributed',
    6: 'CONSISTENCY_INDICATOR_2_1', // Number of OPD visits for children (< 5)',
    7: 'CONSISTENCY_INDICATOR_2_2', // Number of children (< 5) with fever',
    8: 'CONSISTENCY_INDICATOR_2_3', // Number of children (5-14) with fever',
    9: 'CONSISTENCY_INDICATOR_2_4', // Number of people (15+) with fever',
    10: 'CONSISTENCY_INDICATOR_2_5', // Number of children (< 5) with fever tested (RDT or microscopy)',
    11: 'CONSISTENCY_INDICATOR_2_6', // Number of children (5-14) with fever tested (RDT or microscopy)',
    12: 'CONSISTENCY_INDICATOR_2_7', // Number of people (15+) with fever tested (RDT or microscopy)',
    13: 'CONSISTENCY_INDICATOR_3_1', // Number of children (< 5) with confirmed malaria (tested positive with RDT)',
    14: 'CONSISTENCY_INDICATOR_3_2', // Number of children (5-14) with confirmed malaria (tested positive with RDT)',
    15: 'CONSISTENCY_INDICATOR_3_3', // Number of people (15+) with confirmed malaria (tested positive with RDT)',
    16: 'CONSISTENCY_INDICATOR_3_4', // Number of pregnant women with confirmed malaria (tested positive with RDT)',
    17: 'CONSISTENCY_INDICATOR_3_5', // Number of cases tested negative with RDT across all categories',
    18: 'CONSISTENCY_INDICATOR_3_6', // Number of confirmed malaria cases',
    19: 'CONSISTENCY_INDICATOR_3_7', // Number of presumed malaria cases',
    20: 'CONSISTENCY_INDICATOR_3_8', // Number of children (<5) with severe malaria',
    21: 'CONSISTENCY_INDICATOR_3_9', // Number of children (5-14) with severe malaria',
    22: 'CONSISTENCY_INDICATOR_3_10', // Number of people (15+) with severe malaria',
    23: 'CONSISTENCY_INDICATOR_4_1', // Number of children (< 5) with confirmed malaria receiving ACT',
    24: 'CONSISTENCY_INDICATOR_4_2', // Number of children (5-14) with confirmed malaria receiving ACT',
    25: 'CONSISTENCY_INDICATOR_4_3', // Number of people (15+) with confirmed malaria receiving ACT',
    26: 'CONSISTENCY_INDICATOR_4_4', // Number of children (<5) receiving ACT',
    27: 'CONSISTENCY_INDICATOR_4_5', // Number of children (5-14) receiving ACT',
    28: 'CONSISTENCY_INDICATOR_4_6', // Number of people (15+) receiving ACT',
    29: 'CONSISTENCY_INDICATOR_4_7', // Number of severe cases referred',
    30: 'CONSISTENCY_INDICATOR_4_8', // Number of cases that tested negative with RDT receiving ACT',
    31: 'CONSISTENCY_INDICATOR_5_1', // Stock out of ACTs for 7 consecutive days in the past month',
    32: 'CONSISTENCY_INDICATOR_5_2', // Stock out of RDTs for 7 consecutive days in the past month',
    33: 'CONSISTENCY_INDICATOR_5_3', // Stock out of SP for 7 consecutive days in the past month',
    34: 'CONSISTENCY_INDICATOR_5_4', // Stock out of injectible artesunate for 7 consecutive days in the past month',
    35: 'CONSISTENCY_INDICATOR_5_5', // Stock out of rectal artestunate for 7 consecutive days in the past month',
    36: 'CONSISTENCY_INDICATOR_5_6', // Stock out of ITN for 7 consecutive days in the past month',
    37: 'CONSISTENCY_INDICATOR_6_1', // Total number of malaria deaths (inpatient only)'
  };

  final Map<String, String> CrossChecksMap = {
    'A-1-2': 'A-C_H_R-M_C_R', // 'Client held record : Malaria case register',
    'B-1-2': 'B-C_H_R-M_C_R', // 'Client held record : Malaria case register',
    'C-1-2': 'C-C_H_R-M_C_R', // 'Client held record : Malaria case register',
    'A-1-3': 'A-C_H_R-M_R', // 'Client held record : Monthly report',
    'B-1-3': 'B-C_H_R-M_R', // 'Client held record : Monthly report',
    'C-1-3': 'C-C_H_R-M_R', // 'Client held record : Monthly report',
    'A-1-4': 'A-C_H_R-L_R', // 'Client held record : Laboratory register',
    'B-1-4': 'B-C_H_R-L_R', // 'Client held record : Laboratory register',
    'C-1-4': 'C-C_H_R-L_R', // 'Client held record : Laboratory register',
    'A-1-5': 'A-C_H_R-P_D_L', // 'Client held record : Pharmacy dispensation log',
    'B-1-5': 'B-C_H_R-P_D_L', // 'Client held record : Pharmacy dispensation log',
    'C-1-5': 'C-C_H_R-P_D_L', // 'Client held record : Pharmacy dispensation log',
    'A-1-6': 'A-C_H_R-A_S_M_L', // 'Client held record : ACT stock management log',
    'B-1-6': 'B-C_H_R-A_S_M_L', // 'Client held record : ACT stock management log',
    'C-1-6': 'C-C_H_R-A_S_M_L', // 'Client held record : ACT stock management log',
    'A-1-7': 'A-C_H_R-M_S_R', // 'Client held record : Malaria surveillance reports',
    'B-1-7': 'B-C_H_R-M_S_R', // 'Client held record : Malaria surveillance reports',
    'C-1-7': 'C-C_H_R-M_S_R', // 'Client held record : Malaria surveillance reports',
    'A-1-8': 'A-C_H_R-B_N_S_M_L', // 'Client held record : Bed nets stock management logs',
    'B-1-8': 'B-C_H_R-B_N_S_M_L', // 'Client held record : Bed nets stock management logs',
    'C-1-8': 'C-C_H_R-B_N_S_M_L', // 'Client held record : Bed nets stock management logs',
    'A-1-9': 'A-C_H_R-I_R', // 'Client held record : Inpatient register',
    'B-1-9': 'B-C_H_R-I_R', // 'Client held record : Inpatient register',
    'C-1-9': 'C-C_H_R-I_R', // 'Client held record : Inpatient register',
    'A-1-10': 'A-C_H_R-O_R', // 'Client held record : OPD register',
    'B-1-10': 'B-C_H_R-O_R', // 'Client held record : OPD register',
    'C-1-10': 'C-C_H_R-O_R', // 'Client held record : OPD register',
    'A-1-11': 'A-C_H_R-T_S', // 'Client held record : Tally sheet',
    'B-1-11': 'B-C_H_R-T_S', // 'Client held record : Tally sheet',
    'C-1-11': 'C-C_H_R-T_S', // 'Client held record : Tally sheet',
    'A-2-3': 'A-M_C_R-M_R', // 'Malaria case register : Monthly report',
    'B-2-3': 'B-M_C_R-M_R', // 'Malaria case register : Monthly report',
    'C-2-3': 'C-M_C_R-M_R', // 'Malaria case register : Monthly report',
    'A-2-4': 'A-M_C_R-L_R', // 'Malaria case register : Laboratory register',
    'B-2-4': 'B-M_C_R-L_R', // 'Malaria case register : Laboratory register',
    'C-2-4': 'C-M_C_R-L_R', // 'Malaria case register : Laboratory register',
    'A-2-5': 'A-M_C_R-P_D_L', // 'Malaria case register : Pharmacy dispensation log',
    'B-2-5': 'B-M_C_R-P_D_L', // 'Malaria case register : Pharmacy dispensation log',
    'C-2-5': 'C-M_C_R-P_D_L', // 'Malaria case register : Pharmacy dispensation log',
    'A-2-6': 'A-M_C_R-A_S_M_L', // 'Malaria case register : ACT stock management log',
    'B-2-6': 'B-M_C_R-A_S_M_L', // 'Malaria case register : ACT stock management log',
    'C-2-6': 'C-M_C_R-A_S_M_L', // 'Malaria case register : ACT stock management log',
    'A-2-7': 'A-M_C_R-M_S_R', // 'Malaria case register : Malaria surveillance reports',
    'B-2-7': 'B-M_C_R-M_S_R', // 'Malaria case register : Malaria surveillance reports',
    'C-2-7': 'C-M_C_R-M_S_R', // 'Malaria case register : Malaria surveillance reports',
    'A-2-8': 'A-M_C_R-B_N_S_M_L', // 'Malaria case register : Bed nets stock management logs',
    'B-2-8': 'B-M_C_R-B_N_S_M_L', // 'Malaria case register : Bed nets stock management logs',
    'C-2-8': 'C-M_C_R-B_N_S_M_L', // 'Malaria case register : Bed nets stock management logs',
    'A-2-9': 'A-M_C_R-I_R', // 'Malaria case register : Inpatient register',
    'B-2-9': 'B-M_C_R-I_R', // 'Malaria case register : Inpatient register',
    'C-2-9': 'C-M_C_R-I_R', // 'Malaria case register : Inpatient register',
    'A-2-10': 'A-M_C_R-O_R', // 'Malaria case register : OPD register',
    'B-2-10': 'B-M_C_R-O_R', // 'Malaria case register : OPD register',
    'C-2-10': 'C-M_C_R-O_R', // 'Malaria case register : OPD register',
    'A-2-11': 'A-M_C_R-T_S', // 'Malaria case register : Tally sheet',
    'B-2-11': 'B-M_C_R-T_S', // 'Malaria case register : Tally sheet',
    'C-2-11': 'C-M_C_R-T_S', // 'Malaria case register : Tally sheet',
    'A-3-4': 'A-M_R-L_R', // 'Monthly report : Laboratory register',
    'B-3-4': 'B-M_R-L_R', // 'Monthly report : Laboratory register',
    'C-3-4': 'C-M_R-L_R', // 'Monthly report : Laboratory register',
    'A-3-5': 'A-M_R-P_D_L', // 'Monthly report : Pharmacy dispensation log',
    'B-3-5': 'B-M_R-P_D_L', // 'Monthly report : Pharmacy dispensation log',
    'C-3-5': 'C-M_R-P_D_L', // 'Monthly report : Pharmacy dispensation log',
    'A-3-6': 'A-M_R-A_S_M_L', // 'Monthly report : ACT stock management log',
    'B-3-6': 'B-M_R-A_S_M_L', // 'Monthly report : ACT stock management log',
    'C-3-6': 'C-M_R-A_S_M_L', // 'Monthly report : ACT stock management log',
    'A-3-7': 'A-M_R-M_S_R', // 'Monthly report : Malaria surveillance reports',
    'B-3-7': 'B-M_R-M_S_R', // 'Monthly report : Malaria surveillance reports',
    'C-3-7': 'C-M_R-M_S_R', // 'Monthly report : Malaria surveillance reports',
    'A-3-8': 'A-M_R-B_N_S_M_L', // 'Monthly report : Bed nets stock management logs',
    'B-3-8': 'B-M_R-B_N_S_M_L', // 'Monthly report : Bed nets stock management logs',
    'C-3-8': 'C-M_R-B_N_S_M_L', // 'Monthly report : Bed nets stock management logs',
    'A-3-9': 'A-M_R-I_R', // 'Monthly report : Inpatient register',
    'B-3-9': 'B-M_R-I_R', // 'Monthly report : Inpatient register',
    'C-3-9': 'C-M_R-I_R', // 'Monthly report : Inpatient register',
    'A-3-10': 'A-M_R-O_R', // 'Monthly report : OPD register',
    'B-3-10': 'B-M_R-O_R', // 'Monthly report : OPD register',
    'C-3-10': 'B-M_R-O_R', // 'Monthly report : OPD register',
    'A-3-11': 'A-M_R-T_S', // 'Monthly report : Tally sheet',
    'B-3-11': 'B-M_R-T_S', // 'Monthly report : Tally sheet',
    'C-3-11': 'C-M_R-T_S', // 'Monthly report : Tally sheet',
    'A-4-5': 'A-L_R-P_D_L', // 'Laboratory register : Pharmacy dispensation log',
    'B-4-5': 'B-L_R-P_D_L', // 'Laboratory register : Pharmacy dispensation log',
    'C-4-5': 'C-L_R-P_D_L', // 'Laboratory register : Pharmacy dispensation log',
    'A-4-6': 'A-L_R-A_S_M_L', // 'Laboratory register : ACT stock management log',
    'B-4-6': 'B-L_R-A_S_M_L', // 'Laboratory register : ACT stock management log',
    'C-4-6': 'C-L_R-A_S_M_L', // 'Laboratory register : ACT stock management log',
    'A-4-7': 'A-L_R-M_S_R', // 'Laboratory register : Malaria surveillance reports',
    'B-4-7': 'B-L_R-M_S_R', // 'Laboratory register : Malaria surveillance reports',
    'C-4-7': 'C-L_R-M_S_R', // 'Laboratory register : Malaria surveillance reports',
    'A-4-8': 'A-L_R-B_N_S_M_L', // 'Laboratory register : Bed nets stock management logs',
    'B-4-8': 'B-L_R-B_N_S_M_L', // 'Laboratory register : Bed nets stock management logs',
    'C-4-8': 'C-L_R-B_N_S_M_L', // 'Laboratory register : Bed nets stock management logs',
    'A-4-9': 'A-L_R-I_R', // 'Laboratory register : Inpatient register',
    'B-4-9': 'B-L_R-I_R', // 'Laboratory register : Inpatient register',
    'C-4-9': 'C-L_R-I_R', // 'Laboratory register : Inpatient register',
    'A-4-10': 'A-L_R-O_R', // 'Laboratory register : OPD register',
    'B-4-10': 'B-L_R-O_R', // 'Laboratory register : OPD register',
    'C-4-10': 'C-L_R-O_R', // 'Laboratory register : OPD register',
    'A-4-11': 'A-L_R-T_S', // 'Laboratory register : Tally sheet',
    'B-4-11': 'B-L_R-T_S', // 'Laboratory register : Tally sheet',
    'C-4-11': 'C-L_R-T_S', // 'Laboratory register : Tally sheet',
    'A-5-6': 'A-P_D_L-A_S_M_L', // 'Pharmacy dispensation log : ACT stock management log',
    'B-5-6': 'B-P_D_L-A_S_M_L', // 'Pharmacy dispensation log : ACT stock management log',
    'C-5-6': 'C-P_D_L-A_S_M_L', // 'Pharmacy dispensation log : ACT stock management log',
    'A-5-7': 'A-P_D_L-M_S_R', // 'Pharmacy dispensation log : Malaria surveillance reports',
    'B-5-7': 'B-P_D_L-M_S_R', // 'Pharmacy dispensation log : Malaria surveillance reports',
    'C-5-7': 'C-P_D_L-M_S_R', // 'Pharmacy dispensation log : Malaria surveillance reports',
    'A-5-8': 'A-P_D_L-B_N_S_M_L', // 'Pharmacy dispensation log : Bed nets stock management logs',
    'B-5-8': 'B-P_D_L-B_N_S_M_L', // 'Pharmacy dispensation log : Bed nets stock management logs',
    'C-5-8': 'C-P_D_L-B_N_S_M_L', // 'Pharmacy dispensation log : Bed nets stock management logs',
    'A-5-9': 'A-P_D_L-I_R', // 'Pharmacy dispensation log : Inpatient register',
    'B-5-9': 'B-P_D_L-I_R', // 'Pharmacy dispensation log : Inpatient register',
    'C-5-9': 'C-P_D_L-I_R', // 'Pharmacy dispensation log : Inpatient register',
    'A-5-10': 'A-P_D_L-O_R', // 'Pharmacy dispensation log : OPD register',
    'B-5-10': 'B-P_D_L-O_R', // 'Pharmacy dispensation log : OPD register',
    'C-5-10': 'C-P_D_L-O_R', // 'Pharmacy dispensation log : OPD register',
    'A-5-11': 'A-P_D_L-T_S', // 'Pharmacy dispensation log : Tally sheet',
    'B-5-11': 'B-P_D_L-T_S', // 'Pharmacy dispensation log : Tally sheet',
    'C-5-11': 'C-P_D_L-T_S', // 'Pharmacy dispensation log : Tally sheet',
    'A-6-7': 'A-A_S_M_L-M_S_R', // 'ACT stock management log : Malaria surveillance reports',
    'B-6-7': 'B-A_S_M_L-M_S_R', // 'ACT stock management log : Malaria surveillance reports',
    'C-6-7': 'C-A_S_M_L-M_S_R', // 'ACT stock management log : Malaria surveillance reports',
    'A-6-8': 'A-A_S_M_L-B_N_S_M_L', // 'ACT stock management log : Bed nets stock management logs',
    'B-6-8': 'B-A_S_M_L-B_N_S_M_L', // 'ACT stock management log : Bed nets stock management logs',
    'C-6-8': 'C-A_S_M_L-B_N_S_M_L', // 'ACT stock management log : Bed nets stock management logs',
    'A-6-9': 'A-A_S_M_L-I_R', // 'ACT stock management log : Inpatient register',
    'B-6-9': 'B-A_S_M_L-I_R', // 'ACT stock management log : Inpatient register',
    'C-6-9': 'C-A_S_M_L-I_R', // 'ACT stock management log : Inpatient register',
    'A-6-10': 'A-A_S_M_L-O_R', // 'ACT stock management log : OPD register',
    'B-6-10': 'B-A_S_M_L-O_R', // 'ACT stock management log : OPD register',
    'C-6-10': 'C-A_S_M_L-O_R', // 'ACT stock management log : OPD register',
    'A-6-11': 'A-A_S_M_L-T_S', // 'ACT stock management log : Tally sheet',
    'B-6-11': 'B-A_S_M_L-T_S', // 'ACT stock management log : Tally sheet',
    'C-6-11': 'C-A_S_M_L-T_S', // 'ACT stock management log : Tally sheet',
    'A-7-8': 'A-M_S_R-B_N_S_M_L', // 'Malaria surveillance reports : Bed nets stock management logs',
    'B-7-8': 'B-M_S_R-B_N_S_M_L', // 'Malaria surveillance reports : Bed nets stock management logs',
    'C-7-8': 'C-M_S_R-B_N_S_M_L', // 'Malaria surveillance reports : Bed nets stock management logs',
    'A-7-9': 'A-M_S_R-I_R', // 'Malaria surveillance reports : Inpatient register',
    'B-7-9': 'B-M_S_R-I_R', // 'Malaria surveillance reports : Inpatient register',
    'C-7-9': 'C-M_S_R-I_R', // 'Malaria surveillance reports : Inpatient register',
    'A-7-10': 'A-M_S_R-O_R', // 'Malaria surveillance reports : OPD register',
    'B-7-10': 'B-M_S_R-O_R', // 'Malaria surveillance reports : OPD register',
    'C-7-10': 'C-M_S_R-O_R', // 'Malaria surveillance reports : OPD register',
    'A-7-11': 'A-M_S_R-T_S', // 'Malaria surveillance reports : Tally sheet',
    'B-7-11': 'B-M_S_R-T_S', // 'Malaria surveillance reports : Tally sheet',
    'C-7-11': 'C-M_S_R-T_S', // 'Malaria surveillance reports : Tally sheet',
    'A-8-9': 'A-B_N_S_M_L-I_R', // 'Bed nets stock management logs : Inpatient register',
    'B-8-9': 'B-B_N_S_M_L-I_R', // 'Bed nets stock management logs : Inpatient register',
    'C-8-9': 'C-B_N_S_M_L-I_R', // 'Bed nets stock management logs : Inpatient register',
    'A-8-10': 'A-B_N_S_M_L-O_R', // 'Bed nets stock management logs : OPD register',
    'B-8-10': 'B-B_N_S_M_L-O_R', // 'Bed nets stock management logs : OPD register',
    'C-8-10': 'C-B_N_S_M_L-O_R', // 'Bed nets stock management logs : OPD register',
    'A-8-11': 'A-B_N_S_M_L-T_S', // 'Bed nets stock management logs : Tally sheet',
    'B-8-11': 'B-B_N_S_M_L-T_S', // 'Bed nets stock management logs : Tally sheet',
    'C-8-11': 'C-B_N_S_M_L-T_S', // 'Bed nets stock management logs : Tally sheet',
    'A-9-10': 'A-I_R-O_R', // 'Inpatient register : OPD register',
    'B-9-10': 'B-I_R-O_R', // 'Inpatient register : OPD register',
    'C-9-10': 'C-I_R-O_R', // 'Inpatient register : OPD register',
    'A-9-11': 'A-I_R-T_S', // 'Inpatient register : Tally sheet',
    'B-9-11': 'B-I_R-T_S', // 'Inpatient register : Tally sheet',
    'C-9-11': 'C-I_R-T_S', // 'Inpatient register : Tally sheet',
    'A-10-11': 'A-O_R-T_S', // 'OPD register : Tally sheet',
    'B-10-11': 'B-O_R-T_S', // 'OPD register : Tally sheet',
    'C-10-11': 'C-O_R-T_S', // 'OPD register : Tally sheet'
  };

  String getRemoteFromId(int id, String type) {
    String remoteId = "";
    switch (type) {
      case 'data_accuracy':
        remoteId = this.DataAccuracyMap[id];
        break;

      case 'consistency_checks':
        remoteId = this.ConsistencyChecksMap[id];
        break;

      case 'data_element_completeness':
        remoteId = this.DataElementCompletenessMap[id];
        break;

      case 'source_document_completeness':
        remoteId = this.SourceDocumentCompletenessMap[id];
        break;
    }

    return remoteId;
  }

  String getCrossChecksRemote(String type, int primaryId, int secondaryId) {
    String key = type + "-" + primaryId.toString() + "-" + secondaryId.toString();

    return this.CrossChecksMap[key];
  }

  String getSingleRemoteId(String type) {
    String remoteId = "";
    switch (type) {
      case 'data_set':
        remoteId = this.DataSetId;
        break;

      case 'completeness_monthly_report':
        remoteId = this.CompletenessMonthlyReport;
        break;

      case 'timeliness_monthly_report':
        remoteId = this.TimelinessMonthlyReport;
        break;

      case 'data_element_completeness':
        remoteId = this.DataElementCompleteness;
        break;

      case 'category_option_combos':
        remoteId = this.categoryOptionCombos;
        break;
    }

    return remoteId;
  }

  Map<String, String> getKeyValueMap(String type) {
    Map<String, String> remoteKeyValues = {};
    switch (type) {
      case 'source_document_completeness':
        remoteKeyValues = this.SourceDocumentCompleteness;
        break;

      case 'verification_factors':
        remoteKeyValues = this.VerificationFactors;
        break;

      case 'consistency_months':
        remoteKeyValues = this.ConsistencyMonths;
        break;

      case 'system_assessment':
        remoteKeyValues = this.SystemAssessment;
        break;

      case 'source_document_status':
        remoteKeyValues = this.SourceDocumentStatus;
        break;
    }

    return remoteKeyValues;
  }
}
