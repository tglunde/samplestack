/* {"app": "dbt", "dbt_version": "0.17.0", "profile_name": "exasol", "target_name": "dev", "node_id": "model.samplestack.component_metric"} */
with metrics as (
select 
    updated, ldts,
    component_name , 
    component_version , 
    COALESCE(specmetric_name, 'basemetric') as metric_group ,
    metric_name , metric_value 
    
from {{ source('PSA','xmlmetric_s_xmlinterface')}} 

), basemetrics AS (
	select 
        updated, ldts,
        component_name , 
        component_version, 
        metric_name, 
        metric_value 
        
    from metrics 
    
    where metric_group = 'basemetric'

), pivoted AS (
    
    select 
        updated, ldts,
        component_name,
        component_version,
        
  
    max(
      case
      when metric_name = 'misraConfigOpenDeviation'
        then metric_value
      else NULL
      end
    )
    
      
            as "misraConfigOpenDeviation"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxDecCov'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxDecCov"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_FulfilledWithDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_Relevant_FulfilledWithDeviations"
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignFunctions'
        then metric_value
      else NULL
      end
    )
    
      
            as "DesignFunctions"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_NotRelevant"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_Fulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_RelevantNS_Fulfilled"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinPAR'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinPAR"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport_Plan'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_TestReport_Plan"
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationDecisionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as "ConfigurationDecisionCoverage_Measured"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsNotOK'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEsNotOK"
      
    
    ,
  
    max(
      case
      when metric_name = 'CREQsWithSafetyLevel'
        then metric_value
      else NULL
      end
    )
    
      
            as "CREQsWithSafetyLevel"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_CodeMetrics'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_CodeMetrics"
      
    
    ,
  
    max(
      case
      when metric_name = 'TcasesFromVtrNotInTestSpec'
        then metric_value
      else NULL
      end
    )
    
      
            as "TcasesFromVtrNotInTestSpec"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_Fulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_Relevant_Fulfilled"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_FulfilledWithDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_RelevantNS_FulfilledWithDeviations"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport_PlanCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_TestReport_PlanCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignSubModules'
        then metric_value
      else NULL
      end
    )
    
      
            as "DesignSubModules"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_FulfilledNS'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_NotRelevant_FulfilledNS"
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplCAL'
        then metric_value
      else NULL
      end
    )
    
      
            as "ImplCAL"
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationDecisionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "ConfigurationDecisionCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfRelevantSpecItemsWithMissingFulfillment'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfRelevantSpecItemsWithMissingFulfillment"
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationFunctionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as "ConfigurationFunctionCoverage_Measured"
      
    
    ,
  
    max(
      case
      when metric_name = 'PPCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "PPCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallFunctionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "OverallFunctionCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxFctCov'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxFctCov"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxPAR'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxPAR"
      
    
    ,
  
    max(
      case
      when metric_name = 'UnjustifiedCodeMetricViolations'
        then metric_value
      else NULL
      end
    )
    
      
            as "UnjustifiedCodeMetricViolations"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfIrrelevantSpecItemsWithFulfillment'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfIrrelevantSpecItemsWithFulfillment"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_TestReport"
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallBranchCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as "OverallBranchCoverage_Measured"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_FulfilledNS'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_Relevant_FulfilledNS"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsPlanned'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEsPlanned"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_FulfilledNS'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_RelevantNS_FulfilledNS"
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplPTH'
        then metric_value
      else NULL
      end
    )
    
      
            as "ImplPTH"
      
    
    ,
  
    max(
      case
      when metric_name = 'PPCoverageQM'
        then metric_value
      else NULL
      end
    )
    
      
            as "PPCoverageQM"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_NotFulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_RelevantNS_NotFulfilled"
      
    
    ,
  
    max(
      case
      when metric_name = 'CREQsWithTraceToTCASE'
        then metric_value
      else NULL
      end
    )
    
      
            as "CREQsWithTraceToTCASE"
      
    
    ,
  
    max(
      case
      when metric_name = 'DescContainer'
        then metric_value
      else NULL
      end
    )
    
      
            as "DescContainer"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_FulfilledWithDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_NotRelevant_FulfilledWithDeviations"
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplPAR'
        then metric_value
      else NULL
      end
    )
    
      
            as "ImplPAR"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxPTH'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxPTH"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsExecutionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEsExecutionCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallFunctionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as "OverallFunctionCoverage_Measured"
      
    
    ,
  
    max(
      case
      when metric_name = 'DescParameter'
        then metric_value
      else NULL
      end
    )
    
      
            as "DescParameter"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_MISRA'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_MISRA"
      
    
    ,
  
    max(
      case
      when metric_name = 'MISRA_RuleSet'
        then metric_value
      else NULL
      end
    )
    
      
            as "MISRA_RuleSet"
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationBranchCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "ConfigurationBranchCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinPTH'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinPTH"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_Relevant"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinCYC'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinCYC"
      
    
    ,
  
    max(
      case
      when metric_name = 'misraConfigurations'
        then metric_value
      else NULL
      end
    )
    
      
            as "misraConfigurations"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxCYC'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxCYC"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEs'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEs"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsPassedOrJustified'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEsPassedOrJustified"
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallDecisionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as "OverallDecisionCoverage_Measured"
      
    
    ,
  
    max(
      case
      when metric_name = 'CReqSpecChapters'
        then metric_value
      else NULL
      end
    )
    
      
            as "CReqSpecChapters"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASESFromTestSpec'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASESFromTestSpec"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_Fulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_NotRelevant_Fulfilled"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinCAL'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinCAL"
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignFiles'
        then metric_value
      else NULL
      end
    )
    
      
            as "DesignFiles"
      
    
    ,
  
    max(
      case
      when metric_name = 'SafetyManualChapter'
        then metric_value
      else NULL
      end
    )
    
      
            as "SafetyManualChapter"
      
    
    ,
  
    max(
      case
      when metric_name = 'misraRules'
        then metric_value
      else NULL
      end
    )
    
      
            as "misraRules"
      
    
    ,
  
    max(
      case
      when metric_name = 'TcasesFromTestSpecNotInVtr'
        then metric_value
      else NULL
      end
    )
    
      
            as "TcasesFromTestSpecNotInVtr"
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplCYC'
        then metric_value
      else NULL
      end
    )
    
      
            as "ImplCYC"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_NotFulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_NotRelevant_NotFulfilled"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItemsWithMissingRelevance'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItemsWithMissingRelevance"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_RelevantNS"
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplMIF'
        then metric_value
      else NULL
      end
    )
    
      
            as "ImplMIF"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItemsWhichAreFulfilledAndHaveNoTrace'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItemsWhichAreFulfilledAndHaveNoTrace"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxCAL'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxCAL"
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationFunctionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "ConfigurationFunctionCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'misraConfigOpenNotJustyfied'
        then metric_value
      else NULL
      end
    )
    
      
            as "misraConfigOpenNotJustyfied"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsLinkedWithASILCREQ_ExecutionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEsLinkedWithASILCREQ_ExecutionCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'SafetyManualItems'
        then metric_value
      else NULL
      end
    )
    
      
            as "SafetyManualItems"
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallBranchCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "OverallBranchCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinMIF'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinMIF"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_PreprocessorCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_PreprocessorCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignDiagram'
        then metric_value
      else NULL
      end
    )
    
      
            as "DesignDiagram"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinDecCov'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinDecCov"
      
    
    ,
  
    max(
      case
      when metric_name = 'TestReportVerdict'
        then metric_value
      else NULL
      end
    )
    
      
            as "TestReportVerdict"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_RuntimeCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_RuntimeCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'MinFctCov'
        then metric_value
      else NULL
      end
    )
    
      
            as "MinFctCov"
      
    
    ,
  
    max(
      case
      when metric_name = 'Deviations_MaxOpenPerConfig'
        then metric_value
      else NULL
      end
    )
    
      
            as "Deviations_MaxOpenPerConfig"
      
    
    ,
  
    max(
      case
      when metric_name = 'misraMessages'
        then metric_value
      else NULL
      end
    )
    
      
            as "misraMessages"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItemsWhichAreFulfilledWithDeviationAndHaveNoDeviationText'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItemsWhichAreFulfilledWithDeviationAndHaveNoDeviationText"
      
    
    ,
  
    max(
      case
      when metric_name = 'vtrTCASEs'
        then metric_value
      else NULL
      end
    )
    
      
            as "vtrTCASEs"
      
    
    ,
  
    max(
      case
      when metric_name = 'OpenMajorDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as "OpenMajorDeviations"
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsTested'
        then metric_value
      else NULL
      end
    )
    
      
            as "TCASEsTested"
      
    
    ,
  
    max(
      case
      when metric_name = 'CREQs'
        then metric_value
      else NULL
      end
    )
    
      
            as "CREQs"
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxMIF'
        then metric_value
      else NULL
      end
    )
    
      
            as "MaxMIF"
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignFeatures'
        then metric_value
      else NULL
      end
    )
    
      
            as "DesignFeatures"
      
    
    ,
  
    max(
      case
      when metric_name = 'OpenRequiredDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as "OpenRequiredDeviations"
      
    
    ,
  
    max(
      case
      when metric_name = 'Deviations_MaxPerConfig'
        then metric_value
      else NULL
      end
    )
    
      
            as "Deviations_MaxPerConfig"
      
    
    ,
  
    max(
      case
      when metric_name = 'TestSpecChapters'
        then metric_value
      else NULL
      end
    )
    
      
            as "TestSpecChapters"
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationBranchCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as "ConfigurationBranchCoverage_Measured"
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport_TestResult'
        then metric_value
      else NULL
      end
    )
    
      
            as "Status_TestReport_TestResult"
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallDecisionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as "OverallDecisionCoverage"
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_NotFulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as "NrOfSpecItems_Relevant_NotFulfilled"
      
    
    
  


    from basemetrics

    group by updated,ldts,component_name, component_version

)
select * from pivoted