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
    
      
            as misraconfigopendeviation
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxDecCov'
        then metric_value
      else NULL
      end
    )
    
      
            as maxdeccov

      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_FulfilledWithDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevant_fulfilledwithdeviations
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignFunctions'
        then metric_value
      else NULL
      end
    )
    
      
            as designfunctions
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_notrelevant
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_Fulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevantns_fulfilled
      
    
    ,
  
    max(
      case
      when metric_name = 'MinPAR'
        then metric_value
      else NULL
      end
    )
    
      
            as minpar
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport_Plan'
        then metric_value
      else NULL
      end
    )
    
      
            as status_testreport_plan
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationDecisionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as configurationdecisioncoverage_measured
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsNotOK'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasesnotok
      
    
    ,
  
    max(
      case
      when metric_name = 'CREQsWithSafetyLevel'
        then metric_value
      else NULL
      end
    )
    
      
            as creqswithsafetylevel
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_CodeMetrics'
        then metric_value
      else NULL
      end
    )
    
      
            as status_codemetrics
      
    
    ,
  
    max(
      case
      when metric_name = 'TcasesFromVtrNotInTestSpec'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasesfromvtrnotintestspec
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_Fulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevant_fulfilled
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_FulfilledWithDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevantns_fulfilledwithdeviations
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport_PlanCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as status_testreport_plancoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignSubModules'
        then metric_value
      else NULL
      end
    )
    
      
            as designsubmodules
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_FulfilledNS'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_notrelevant_fulfilledns
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplCAL'
        then metric_value
      else NULL
      end
    )
    
      
            as implcal
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationDecisionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as configurationdecisioncoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfRelevantSpecItemsWithMissingFulfillment'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofrelevantspecitemswithmissingfulfillment
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationFunctionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as configurationfunctioncoverage_measured
      
    
    ,
  
    max(
      case
      when metric_name = 'PPCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as ppcoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallFunctionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as overallfunctioncoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxFctCov'
        then metric_value
      else NULL
      end
    )
    
      
            as maxfctcov
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxPAR'
        then metric_value
      else NULL
      end
    )
    
      
            as maxpar
      
    
    ,
  
    max(
      case
      when metric_name = 'UnjustifiedCodeMetricViolations'
        then metric_value
      else NULL
      end
    )
    
      
            as unjustifiedcodemetricviolations
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfIrrelevantSpecItemsWithFulfillment'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofirrelevantspecitemswithfulfillment
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport'
        then metric_value
      else NULL
      end
    )
    
      
            as status_testreport
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallBranchCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as overallbranchcoverage_measured
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_FulfilledNS'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevant_fulfilledns
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsPlanned'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasesplanned
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_FulfilledNS'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevantns_fulfilledns
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplPTH'
        then metric_value
      else NULL
      end
    )
    
      
            as implpth
      
    
    ,
  
    max(
      case
      when metric_name = 'PPCoverageQM'
        then metric_value
      else NULL
      end
    )
    
      
            as ppcoverageqm
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS_NotFulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevantns_notfulfilled
      
    
    ,
  
    max(
      case
      when metric_name = 'CREQsWithTraceToTCASE'
        then metric_value
      else NULL
      end
    )
    
      
            as creqswithtracetotcase
      
    
    ,
  
    max(
      case
      when metric_name = 'DescContainer'
        then metric_value
      else NULL
      end
    )
    
      
            as desccontainer
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_FulfilledWithDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_notrelevant_fulfilledwithdeviations
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplPAR'
        then metric_value
      else NULL
      end
    )
    
      
            as implpar
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxPTH'
        then metric_value
      else NULL
      end
    )
    
      
            as maxpth
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsExecutionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasesexecutioncoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallFunctionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as overallfunctioncoverage_measured
      
    
    ,
  
    max(
      case
      when metric_name = 'DescParameter'
        then metric_value
      else NULL
      end
    )
    
      
            as descparameter
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_MISRA'
        then metric_value
      else NULL
      end
    )
    
      
            as status_misra
      
    
    ,
  
    max(
      case
      when metric_name = 'MISRA_RuleSet'
        then metric_value
      else NULL
      end
    )
    
      
            as misra_ruleset
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationBranchCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as configurationbranchcoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'MinPTH'
        then metric_value
      else NULL
      end
    )
    
      
            as minpth
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevant
      
    
    ,
  
    max(
      case
      when metric_name = 'MinCYC'
        then metric_value
      else NULL
      end
    )
    
      
            as mincyc
      
    
    ,
  
    max(
      case
      when metric_name = 'misraConfigurations'
        then metric_value
      else NULL
      end
    )
    
      
            as misraconfigurations
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxCYC'
        then metric_value
      else NULL
      end
    )
    
      
            as maxcyc
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEs'
        then metric_value
      else NULL
      end
    )
    
      
            as tcases
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsPassedOrJustified'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasespassedorjustified
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallDecisionCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as overalldecisioncoverage_measured
      
    
    ,
  
    max(
      case
      when metric_name = 'CReqSpecChapters'
        then metric_value
      else NULL
      end
    )
    
      
            as creqspecchapters
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASESFromTestSpec'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasesfromtestspec
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_Fulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_notrelevant_fulfilled
      
    
    ,
  
    max(
      case
      when metric_name = 'MinCAL'
        then metric_value
      else NULL
      end
    )
    
      
            as mincal
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignFiles'
        then metric_value
      else NULL
      end
    )
    
      
            as designfiles
      
    
    ,
  
    max(
      case
      when metric_name = 'SafetyManualChapter'
        then metric_value
      else NULL
      end
    )
    
      
            as safetymanualchapter
      
    
    ,
  
    max(
      case
      when metric_name = 'misraRules'
        then metric_value
      else NULL
      end
    )
    
      
            as misrarules
      
    
    ,
  
    max(
      case
      when metric_name = 'TcasesFromTestSpecNotInVtr'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasesfromtestspecnotinvtr
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplCYC'
        then metric_value
      else NULL
      end
    )
    
      
            as implcyc
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_NotRelevant_NotFulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_notrelevant_notfulfilled
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItemsWithMissingRelevance'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitemswithmissingrelevance
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_RelevantNS'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevantns
      
    
    ,
  
    max(
      case
      when metric_name = 'ImplMIF'
        then metric_value
      else NULL
      end
    )
    
      
            as implmif
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItemsWhichAreFulfilledAndHaveNoTrace'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitemswhicharefulfilledandhavenotrace
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxCAL'
        then metric_value
      else NULL
      end
    )
    
      
            as maxcal
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationFunctionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as configurationfunctioncoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'misraConfigOpenNotJustyfied'
        then metric_value
      else NULL
      end
    )
    
      
            as misraconfigopennotjustyfied
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsLinkedWithASILCREQ_ExecutionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as tcaseslinkedwithasilcreq_executioncoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'SafetyManualItems'
        then metric_value
      else NULL
      end
    )
    
      
            as safetymanualitems
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallBranchCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as overallbranchcoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'MinMIF'
        then metric_value
      else NULL
      end
    )
    
      
            as minmif
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_PreprocessorCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as status_preprocessorcoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignDiagram'
        then metric_value
      else NULL
      end
    )
    
      
            as designdiagram
      
    
    ,
  
    max(
      case
      when metric_name = 'MinDecCov'
        then metric_value
      else NULL
      end
    )
    
      
            as mindeccov
      
    
    ,
  
    max(
      case
      when metric_name = 'TestReportVerdict'
        then metric_value
      else NULL
      end
    )
    
      
            as testreportverdict
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_RuntimeCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as status_runtimecoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'MinFctCov'
        then metric_value
      else NULL
      end
    )
    
      
            as minfctcov
      
    
    ,
  
    max(
      case
      when metric_name = 'Deviations_MaxOpenPerConfig'
        then metric_value
      else NULL
      end
    )
    
      
            as deviations_maxopenperconfig
      
    
    ,
  
    max(
      case
      when metric_name = 'misraMessages'
        then metric_value
      else NULL
      end
    )
    
      
            as misramessages
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItemsWhichAreFulfilledWithDeviationAndHaveNoDeviationText'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitemswhicharefulfilledwithdeviationandhavenodeviationtext
      
    
    ,
  
    max(
      case
      when metric_name = 'vtrTCASEs'
        then metric_value
      else NULL
      end
    )
    
      
            as vtrtcases
      
    
    ,
  
    max(
      case
      when metric_name = 'OpenMajorDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as openmajordeviations
      
    
    ,
  
    max(
      case
      when metric_name = 'TCASEsTested'
        then metric_value
      else NULL
      end
    )
    
      
            as tcasestested
      
    
    ,
  
    max(
      case
      when metric_name = 'CREQs'
        then metric_value
      else NULL
      end
    )
    
      
            as creqs
      
    
    ,
  
    max(
      case
      when metric_name = 'MaxMIF'
        then metric_value
      else NULL
      end
    )
    
      
            as maxmif
      
    
    ,
  
    max(
      case
      when metric_name = 'DesignFeatures'
        then metric_value
      else NULL
      end
    )
    
      
            as designfeatures
      
    
    ,
  
    max(
      case
      when metric_name = 'OpenRequiredDeviations'
        then metric_value
      else NULL
      end
    )
    
      
            as openrequireddeviations
      
    
    ,
  
    max(
      case
      when metric_name = 'Deviations_MaxPerConfig'
        then metric_value
      else NULL
      end
    )
    
      
            as deviations_maxperconfig
      
    
    ,
  
    max(
      case
      when metric_name = 'TestSpecChapters'
        then metric_value
      else NULL
      end
    )
    
      
            as testspecchapters
      
    
    ,
  
    max(
      case
      when metric_name = 'ConfigurationBranchCoverage_Measured'
        then metric_value
      else NULL
      end
    )
    
      
            as configurationbranchcoverage_measured
      
    
    ,
  
    max(
      case
      when metric_name = 'Status_TestReport_TestResult'
        then metric_value
      else NULL
      end
    )
    
      
            as status_testreport_testresult
      
    
    ,
  
    max(
      case
      when metric_name = 'OverallDecisionCoverage'
        then metric_value
      else NULL
      end
    )
    
      
            as overalldecisioncoverage
      
    
    ,
  
    max(
      case
      when metric_name = 'NrOfSpecItems_Relevant_NotFulfilled'
        then metric_value
      else NULL
      end
    )
    
      
            as nrofspecitems_relevant_notfulfilled
      
    
    
  


    from basemetrics

    group by updated,ldts,component_name, component_version

)
select * from pivoted